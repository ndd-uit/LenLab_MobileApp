import 'package:lenlab_shared/lenlab_shared.dart';

import '../../vouchers/data/voucher_source.dart';
import '../../vouchers/data/voucher_eligibility_source.dart';

class MockCheckoutQuoteSource implements CheckoutQuoteSource {
  MockCheckoutQuoteSource(
    this.store, {
    PublicCampaignSource? campaigns,
    CustomerVoucherUsageSource? usage,
    this.shippingSource,
    DateTime Function()? clock,
    this.expiresAt,
    Map<String, int> globalUsedCounts = const {},
  }) : campaigns = campaigns ?? MockPublicCampaignSource(store),
       usage = usage ?? MockCustomerVoucherUsageSource(store),
       clock = clock ?? DateTime.now,
       globalUsedCounts = Map.unmodifiable(globalUsedCounts);
  final LenlabStore store;
  final PublicCampaignSource campaigns;
  final CustomerVoucherUsageSource usage;
  final ShippingPreviewSource? shippingSource;
  final DateTime Function() clock;
  final DateTime? Function(VoucherEvaluationContext)? expiresAt;
  final Map<String, int> globalUsedCounts;
  static int _nextId = 0;

  @override
  Future<CheckoutQuote> load(CheckoutQuoteRequest request) async {
    final c = request.context;
    final id = 'mock-quote-${++_nextId}';
    int subtotal = 0;
    final lines = <VoucherEvaluationLine>[];
    int? campaignVersion, itemsDiscount, shippingDiscount, fee;
    ShippingPreview? ship;
    DateTime? expiry = expiresAt?.call(c);
    CheckoutQuote result(CheckoutQuoteStatus status, String reason) =>
        CheckoutQuote(
          id: id,
          version: 1,
          session: c.session,
          contextKey: request.key,
          lines: lines,
          status: status,
          reason: reason,
          itemsSubtotalVnd: subtotal,
          campaignId: request.campaignId,
          campaignVersion: campaignVersion,
          itemsDiscountVnd: itemsDiscount,
          shippingFeeVnd: fee,
          shippingDiscountVnd: shippingDiscount,
          expiresAt: expiry,
          shippingPreview: ship,
        );
    void check() {
      if (!store.isCurrentSession(c.session) ||
          c.key != store.voucherContextKey) {
        throw const RepositoryException('Ngữ cảnh quote đã thay đổi.');
      }
    }

    check();
    if (c.lines.isEmpty) {
      return result(CheckoutQuoteStatus.needsContext, 'EMPTY_SELECTION');
    }
    if (c.legacyCoupon.isNotEmpty) {
      return result(CheckoutQuoteStatus.error, 'LEGACY_COUPON_CONFLICT');
    }
    final catalog = await store.repository.products();
    check();
    for (final line in c.lines) {
      final matches = catalog.where((p) => p.id == line.productId).toList();
      if (matches.length != 1 || !matches.single.published) {
        return result(CheckoutQuoteStatus.error, 'PRODUCT_UNAVAILABLE');
      }
      final p = matches.single;
      final quantity = c.lines
          .where((l) => l.productId == p.id)
          .fold(0, (n, l) => n + l.quantity);
      if (line.quantity <= 0 || quantity > p.stock || p.stock <= 0) {
        return result(CheckoutQuoteStatus.error, 'QUANTITY_INVALID');
      }
      if (p.price < 0 || p.price != line.unitPriceVnd) {
        return result(CheckoutQuoteStatus.error, 'PRICE_CHANGED');
      }
      // Catalog is the mock authority; never silently update the user's cart.
      lines.add(
        VoucherEvaluationLine(
          productId: p.id,
          variant: line.variant,
          quantity: line.quantity,
          unitPriceVnd: p.price,
        ),
      );
      subtotal += p.price * line.quantity;
    }
    if (request.campaignId != null) {
      final public = await campaigns.load();
      check();
      final matching = public
          .where(
            (p) =>
                p.id == request.campaignId &&
                p.publication == VoucherPublication.published,
          )
          .toList();
      if (matching.length != 1) {
        return result(CheckoutQuoteStatus.error, 'VOUCHER_NOT_AVAILABLE');
      }
      campaignVersion = matching.single.version;
      final evaluation = await MockVoucherEligibilitySource(
        store,
        publicSource: _CampaignSnapshot(matching.single),
        usageSource: usage,
        shippingSource: shippingSource,
        globalUsedCounts: globalUsedCounts,
        clock: clock,
      ).evaluate(c, campaignId: request.campaignId);
      check();
      // Shipping vouchers carry the exact immutable fee input used for Ds.
      // Do not re-read a potentially newer fee between evaluation and quote.
      ship = evaluation.shippingPreview;
      final end = evaluation.validUntil;
      if (end != null && (expiry == null || end.isBefore(expiry))) expiry = end;
      if (evaluation.status == VoucherEligibilityStatus.ineligible) {
        return result(CheckoutQuoteStatus.error, evaluation.reason);
      }
      itemsDiscount = evaluation.itemsDiscountVnd;
      shippingDiscount = evaluation.shippingDiscountVnd;
      if (evaluation.status == VoucherEligibilityStatus.needsContext) {
        return result(CheckoutQuoteStatus.needsContext, evaluation.reason);
      }
    } else {
      itemsDiscount = shippingDiscount = 0;
    }
    ship ??=
        await shippingSource?.load(c) ??
        ShippingPreview.needsContext(
          contextKey: c.key,
          session: c.session,
          reason: 'SHIPPING_CONTEXT_REQUIRED',
        );
    check();
    if (!ship.matches(c.key, c.session)) {
      return result(CheckoutQuoteStatus.error, 'SHIPPING_CONTEXT_CHANGED');
    }
    if (ship.status == ShippingPreviewStatus.error) {
      return result(CheckoutQuoteStatus.error, ship.reason);
    }
    if (!c.hasAddress || ship.status == ShippingPreviewStatus.needsContext) {
      return result(CheckoutQuoteStatus.needsContext, ship.reason);
    }
    if (!ship.validAt(clock())) {
      return result(CheckoutQuoteStatus.stale, 'SHIPPING_PREVIEW_EXPIRED');
    }
    fee = ship.grossShippingFeeVnd;
    final shippingEnd = ship.validUntil;
    if (shippingEnd != null && (expiry == null || shippingEnd.isBefore(expiry))) {
      expiry = shippingEnd;
    }
    if (expiry != null && !clock().isBefore(expiry)) {
      return result(CheckoutQuoteStatus.stale, 'QUOTE_EXPIRED');
    }
    return result(CheckoutQuoteStatus.ready, 'MOCK_QUOTE_ONLY');
  }
}

class _CampaignSnapshot implements PublicCampaignSource {
  const _CampaignSnapshot(this.campaign);
  final PublicVoucherCampaign campaign;
  @override
  Future<List<PublicVoucherCampaign>> load() async => [campaign];
}
