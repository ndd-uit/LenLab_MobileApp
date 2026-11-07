import '../domain/customer_identity.dart';
import 'voucher_evaluation.dart';
import 'order_review_data.dart';
import 'shipping_preview.dart';

enum CheckoutQuoteStatus { loading, ready, needsContext, error, stale }

class CheckoutQuoteRequest {
  const CheckoutQuoteRequest({
    required this.context,
    required this.key,
    this.campaignId,
  });
  final VoucherEvaluationContext context;
  final String key;
  final String? campaignId;
}

/// Immutable mock pricing snapshot. READY reserves neither stock nor quota.
class CheckoutQuote {
  CheckoutQuote({
    required this.id,
    required this.version,
    required this.session,
    required this.contextKey,
    required List<VoucherEvaluationLine> lines,
    required this.status,
    required this.reason,
    required this.itemsSubtotalVnd,
    this.campaignId,
    this.campaignVersion,
    this.itemsDiscountVnd,
    this.shippingFeeVnd,
    this.shippingDiscountVnd,
    this.expiresAt,
    this.shippingPreview,
  }) : lines = List.unmodifiable(lines);
  final String id, contextKey, reason;
  final int version, itemsSubtotalVnd;
  final CustomerSessionStamp session;
  final List<VoucherEvaluationLine> lines;
  final CheckoutQuoteStatus status;
  final String? campaignId;
  final int? campaignVersion,
      itemsDiscountVnd,
      shippingFeeVnd,
      shippingDiscountVnd;
  final DateTime? expiresAt;
  final ShippingPreview? shippingPreview;
  int? get itemsPayableVnd =>
      itemsDiscountVnd == null ? null : itemsSubtotalVnd - itemsDiscountVnd!;
  int? get shippingPayableVnd =>
      shippingFeeVnd == null || shippingDiscountVnd == null
      ? null
      : shippingFeeVnd! - shippingDiscountVnd!;
  bool get consistent =>
      itemsSubtotalVnd >= 0 &&
      lines.fold<int>(0, (sum, l) => sum + l.quantity * l.unitPriceVnd) ==
          itemsSubtotalVnd &&
      lines.every((l) => l.quantity > 0 && l.unitPriceVnd >= 0) &&
      itemsDiscountVnd != null &&
      itemsDiscountVnd! >= 0 &&
      itemsDiscountVnd! <= itemsSubtotalVnd &&
      shippingFeeVnd != null &&
      shippingFeeVnd! >= 0 &&
      shippingDiscountVnd != null &&
      shippingDiscountVnd! >= 0 &&
      shippingDiscountVnd! <= shippingFeeVnd!;
  int? get grandTotalVnd => status == CheckoutQuoteStatus.ready && consistent
      ? itemsPayableVnd! + shippingPayableVnd!
      : null;
  OrderReviewTotals get reviewTotals {
    if (grandTotalVnd == null) throw StateError('Quote is not ready');
    // P2 has one shipping row: show net shipping there, keep gross/discount
    // separately in this quote. Legacy totals/COD formula remains unchanged.
    return OrderReviewTotals(
      subtotal: itemsSubtotalVnd,
      discount: itemsDiscountVnd!,
      shipping: shippingPayableVnd!,
    );
  }

  CheckoutQuote asStale(String reason) => CheckoutQuote(
    id: id,
    version: version,
    session: session,
    contextKey: contextKey,
    lines: lines,
    status: CheckoutQuoteStatus.stale,
    reason: reason,
    itemsSubtotalVnd: itemsSubtotalVnd,
    campaignId: campaignId,
    campaignVersion: campaignVersion,
    expiresAt: expiresAt,
  );
}

abstract interface class CheckoutQuoteSource {
  Future<CheckoutQuote> load(CheckoutQuoteRequest request);
}
