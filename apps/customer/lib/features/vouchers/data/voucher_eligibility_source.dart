import 'dart:math' as math;

import 'package:lenlab_shared/lenlab_shared.dart';

import 'voucher_source.dart';

/// Mock-only evaluation, no quota mutation, checkout quote or implicit P2 rules.
class MockVoucherEligibilitySource implements VoucherEligibilitySource {
  MockVoucherEligibilitySource(
    this.store, {
    PublicCampaignSource? publicSource,
    CustomerVoucherUsageSource? usageSource,
    DateTime Function()? clock,
    Map<String, int> globalUsedCounts = const {},
    this.shippingSource,
  }) : publicSource = publicSource ?? MockPublicCampaignSource(store),
       usageSource = usageSource ?? MockCustomerVoucherUsageSource(store),
       clock = clock ?? DateTime.now,
       globalUsedCounts = Map.unmodifiable(globalUsedCounts);
  final LenlabStore store;
  final PublicCampaignSource publicSource;
  final CustomerVoucherUsageSource usageSource;
  final DateTime Function() clock;
  final Map<String, int> globalUsedCounts;
  final ShippingPreviewSource? shippingSource;

  @override
  Future<VoucherEvaluation> evaluate(
    VoucherEvaluationContext context, {
    String? campaignId,
    String? code,
  }) async {
    String? resolved;
    DateTime? validUntil;
    ShippingPreview? evaluatedShipping;
    VoucherEvaluation result(
      VoucherEligibilityStatus status,
      String reason, {
      int items = 0,
      int shipping = 0,
      int? remaining,
    }) => VoucherEvaluation(
      status: status,
      reason: reason,
      contextKey: context.key,
      campaignId: resolved,
      itemsDiscountVnd: items,
      shippingDiscountVnd: shipping,
      remainingShippingVnd: remaining,
      validUntil: validUntil,
      shippingPreview: evaluatedShipping,
    );
    VoucherEvaluation reject(String code) =>
        result(VoucherEligibilityStatus.ineligible, code);
    if ((campaignId == null) == (code == null)) {
      return reject('INVALID_SELECTION');
    }
    final campaigns = await publicSource.load();
    if (!store.isCurrentSession(context.session)) {
      throw const RepositoryException('Phiên đánh giá voucher đã thay đổi.');
    }
    final matches = campaigns
        .where(
          (c) =>
              c.publication == VoucherPublication.published &&
              (campaignId != null
                  ? c.id == campaignId
                  : c.code != null && c.code == code!.trim()),
        )
        .toList();
    if (matches.length != 1) return reject('VOUCHER_NOT_AVAILABLE');
    final campaign = matches.single;
    resolved = campaign.id;
    final r = campaign.rules;
    if (campaign.kind == WalletVoucherKind.gift ||
        campaign.kind == WalletVoucherKind.firstOrder ||
        r?.type == VoucherRuleType.gift ||
        r?.type == VoucherRuleType.firstOrder) {
      return reject('TYPE_UNSUPPORTED');
    }
    if (r == null ||
        r.minimumVnd == null ||
        r.minimumVnd! < 0 ||
        r.startsAt == null ||
        r.endsAt == null ||
        !r.startsAt!.isBefore(r.endsAt!) ||
        r.globalLimit?.valid != true ||
        r.perCustomerLimit?.valid != true) {
      return reject('CONFIG_INCOMPLETE');
    }
    final now = clock();
    validUntil = r.endsAt;
    if (now.isBefore(r.startsAt!)) return reject('NOT_STARTED');
    if (!now.isBefore(r.endsAt!)) return reject('EXPIRED');
    if (context.lines.isEmpty) {
      return result(VoucherEligibilityStatus.needsContext, 'EMPTY_SELECTION');
    }
    final catalog = await store.repository.products();
    if (!store.isCurrentSession(context.session)) {
      throw const RepositoryException('Phiên đánh giá voucher đã thay đổi.');
    }
    for (final line in context.lines) {
      final products = catalog.where((p) => p.id == line.productId).toList();
      if (products.length != 1 || !products.single.published) {
        return reject('PRODUCT_UNAVAILABLE');
      }
      final p = products.single;
      final quantity = context.lines
          .where((l) => l.productId == p.id)
          .fold(0, (sum, l) => sum + l.quantity);
      if (line.quantity <= 0 || quantity > p.stock || p.stock <= 0) {
        return reject('QUANTITY_INVALID');
      }
      if (p.price != line.unitPriceVnd || p.price < 0) {
        return reject('PRICE_CHANGED');
      }
    }
    if (context.subtotal < r.minimumVnd!) return reject('MINIMUM_NOT_MET');
    var items = 0, ship = 0;
    int? remaining;
    switch (r.type) {
      case VoucherRuleType.itemsFixed:
        if ((r.fixedAmountVnd ?? 0) <= 0) return reject('CONFIG_INCOMPLETE');
        items = math.min(r.fixedAmountVnd!, context.subtotal);
      case VoucherRuleType.itemsPercentage:
        if ((r.rateBps ?? 0) < 1 ||
            r.rateBps! > 10000 ||
            (r.maxDiscountVnd ?? 0) <= 0) {
          return reject('CONFIG_INCOMPLETE');
        }
        items = math.min(
          math.min(context.subtotal * r.rateBps! ~/ 10000, r.maxDiscountVnd!),
          context.subtotal,
        );
      case VoucherRuleType.shippingFreeFull:
      case VoucherRuleType.shippingDiscountCapped:
        if (r.type == VoucherRuleType.shippingDiscountCapped &&
            (r.shippingDiscountVnd ?? 0) <= 0) {
          return reject('CONFIG_INCOMPLETE');
        }
        final preview = evaluatedShipping =
            await shippingSource?.load(context) ??
            ShippingPreview.needsContext(
              contextKey: context.key,
              session: context.session,
              reason: 'SHIPPING_CONTEXT_REQUIRED',
            );
        if (!store.isCurrentSession(context.session) ||
            context.key != store.voucherContextKey ||
            !preview.matches(context.key, context.session)) {
          return reject('SHIPPING_CONTEXT_CHANGED');
        }
        if (preview.status == ShippingPreviewStatus.error) {
          return reject(preview.reason);
        }
        if (!context.hasAddress ||
            preview.status == ShippingPreviewStatus.needsContext) {
          return result(VoucherEligibilityStatus.needsContext, preview.reason);
        }
        if (!preview.validAt(clock())) {
          return reject('SHIPPING_PREVIEW_EXPIRED');
        }
        final shippingEnd = preview.validUntil;
        if (shippingEnd != null && shippingEnd.isBefore(validUntil!)) {
          validUntil = shippingEnd;
        }
        ship = r.type == VoucherRuleType.shippingFreeFull
            ? preview.eligibleShippingFeeVnd!
            : math.min(r.shippingDiscountVnd!, preview.eligibleShippingFeeVnd!);
        remaining = preview.grossShippingFeeVnd! - ship;
      case VoucherRuleType.gift:
      case VoucherRuleType.firstOrder:
        return reject('TYPE_UNSUPPORTED');
    }
    if (r.globalLimit!.mode == VoucherLimitMode.limited) {
      final used = globalUsedCounts[campaign.id];
      if (used == null || used < 0) return reject('CONFIG_INCOMPLETE');
      if (used >= r.globalLimit!.count!) {
        return reject('GLOBAL_QUOTA_EXHAUSTED');
      }
    }
    if (context.session.userId == null) {
      return result(
        VoucherEligibilityStatus.needsContext,
        'AUTH_REQUIRED',
        items: items,
        shipping: ship,
        remaining: remaining,
      );
    }
    final usage = await usageSource.load();
    if (!store.isCurrentSession(context.session)) {
      throw const RepositoryException('Phiên đánh giá voucher đã thay đổi.');
    }
    // An injected private source must never transfer another principal's data.
    if (usage.any(
      (u) => u.userId != context.session.userId || u.usedCount < 0,
    )) {
      return reject('USAGE_UNAVAILABLE');
    }
    final used = usage
        .where((u) => u.campaignId == campaign.id)
        .fold(0, (sum, u) => sum + u.usedCount);
    if (r.perCustomerLimit!.mode == VoucherLimitMode.limited &&
        used >= r.perCustomerLimit!.count!) {
      return reject('CUSTOMER_LIMIT_REACHED');
    }
    if (context.legacyCoupon.isNotEmpty) {
      return reject('LEGACY_COUPON_CONFLICT');
    }
    if (evaluatedShipping != null && !evaluatedShipping.validAt(clock())) {
      return reject('SHIPPING_PREVIEW_EXPIRED');
    }
    if (!clock().isBefore(r.endsAt!)) return reject('EXPIRED');
    return result(
      VoucherEligibilityStatus.eligible,
      'MOCK_PREVIEW_ONLY',
      items: items,
      shipping: ship,
      remaining: remaining,
    );
  }
}
