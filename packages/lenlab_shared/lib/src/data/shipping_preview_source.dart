import 'shipping_preview.dart';
import 'voucher_evaluation.dart';

abstract interface class ShippingPreviewSource {
  Future<ShippingPreview> load(
    VoucherEvaluationContext context, {
    bool force = false,
  });
}
