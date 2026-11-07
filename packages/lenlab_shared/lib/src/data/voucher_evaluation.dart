import '../domain/customer_identity.dart';
import 'shipping_preview.dart';

enum VoucherRuleType {
  itemsFixed,
  itemsPercentage,
  shippingFreeFull,
  shippingDiscountCapped,
  gift,
  firstOrder,
}

enum VoucherLimitMode { limited, unlimited }

class VoucherLimit {
  const VoucherLimit.unlimited()
    : mode = VoucherLimitMode.unlimited,
      count = null;
  const VoucherLimit.limited(this.count) : mode = VoucherLimitMode.limited;
  final VoucherLimitMode mode;
  final int? count;
  bool get valid =>
      mode == VoucherLimitMode.unlimited || (count != null && count! > 0);
}

/// Explicit mock configuration; never constructed by parsing card copy.
class VoucherRules {
  const VoucherRules({
    required this.type,
    this.minimumVnd,
    this.startsAt,
    this.endsAt,
    this.globalLimit,
    this.perCustomerLimit,
    this.fixedAmountVnd,
    this.rateBps,
    this.maxDiscountVnd,
    this.shippingDiscountVnd,
  });
  final VoucherRuleType type;
  final int? minimumVnd,
      fixedAmountVnd,
      rateBps,
      maxDiscountVnd,
      shippingDiscountVnd;
  final DateTime? startsAt, endsAt;
  final VoucherLimit? globalLimit, perCustomerLimit;
}

enum VoucherEligibilityStatus { eligible, ineligible, needsContext }

class VoucherEvaluationLine {
  const VoucherEvaluationLine({
    required this.productId,
    required this.variant,
    required this.quantity,
    required this.unitPriceVnd,
  });
  final String productId, variant;
  final int quantity, unitPriceVnd;
}

/// Detached snapshot: no mutable Product or CartLine references.
class VoucherEvaluationContext {
  VoucherEvaluationContext({
    required this.session,
    required this.key,
    required List<VoucherEvaluationLine> lines,
    required this.hasAddress,
    required this.legacyCoupon,
  }) : lines = List.unmodifiable(lines);
  final CustomerSessionStamp session;
  final String key, legacyCoupon;
  final List<VoucherEvaluationLine> lines;
  final bool hasAddress;
  int get subtotal =>
      lines.fold(0, (sum, line) => sum + line.unitPriceVnd * line.quantity);
}

class VoucherEvaluation {
  const VoucherEvaluation({
    required this.status,
    required this.reason,
    required this.contextKey,
    this.campaignId,
    this.itemsDiscountVnd = 0,
    this.shippingDiscountVnd = 0,
    this.remainingShippingVnd,
    this.validUntil,
    this.shippingPreview,
  });
  final VoucherEligibilityStatus status;
  final String reason, contextKey;
  final String? campaignId;
  final int itemsDiscountVnd, shippingDiscountVnd;
  final int? remainingShippingVnd;
  final DateTime? validUntil;
  final ShippingPreview? shippingPreview;
}

abstract interface class VoucherEligibilitySource {
  Future<VoucherEvaluation> evaluate(
    VoucherEvaluationContext context, {
    String? campaignId,
    String? code,
  });
}
