import '../domain/models.dart';
import 'lenlab_repository.dart';
import 'order_review_data.dart';

enum CodValidationReason {
  empty,
  missing,
  duplicate,
  hidden,
  unavailable,
  quantity,
  stock,
  priceChanged,
  stockChanged,
  totalsChanged,
}

class CodValidationException extends RepositoryException {
  const CodValidationException(super.message, this.reason);
  final CodValidationReason reason;
  bool get requiresReview =>
      reason == CodValidationReason.priceChanged ||
      reason == CodValidationReason.stockChanged ||
      reason == CodValidationReason.totalsChanged;
}

/// Mock-only check. No inventory is reserved, deducted, or restored here.
List<CartLine> validateCodLines(
  List<CartLine> lines,
  List<Product> catalog, {
  bool acceptUpdatedInformation = false,
}) {
  if (lines.isEmpty) {
    throw const CodValidationException(
      'Chưa chọn sản phẩm thanh toán.',
      CodValidationReason.empty,
    );
  }
  final quantities = <String, int>{};
  final keys = <String>{};
  final resolved = <CartLine>[];
  for (final line in lines) {
    final id = line.product.id;
    final matches = catalog.where((p) => p.id == id).toList();
    if (id.trim().isEmpty || matches.isEmpty) {
      throw CodValidationException(
        '${line.product.name}: sản phẩm không còn trong danh mục. Vui lòng xem lại giỏ hàng.',
        CodValidationReason.missing,
      );
    }
    if (matches.length != 1 || !keys.add(line.key)) {
      throw CodValidationException(
        '${line.product.name}: dữ liệu sản phẩm bị trùng. Vui lòng xem lại giỏ hàng.',
        CodValidationReason.duplicate,
      );
    }
    final current = matches.single;
    if (!current.published) {
      throw CodValidationException(
        '${current.name}: sản phẩm đã bị ẩn, không còn được bán.',
        CodValidationReason.hidden,
      );
    }
    if (current.price <= 0) {
      throw CodValidationException(
        '${current.name}: giá bán không hợp lệ, chưa thể đặt hàng.',
        CodValidationReason.unavailable,
      );
    }
    if (line.quantity <= 0) {
      throw CodValidationException(
        '${current.name}: số lượng mua phải lớn hơn 0.',
        CodValidationReason.quantity,
      );
    }
    if (current.stock <= 0) {
      throw CodValidationException(
        '${current.name}: sản phẩm đã hết hàng.',
        CodValidationReason.stock,
      );
    }
    final quantity = (quantities[id] ?? 0) + line.quantity;
    quantities[id] = quantity;
    if (quantity > current.stock) {
      throw CodValidationException(
        '${current.name}: số lượng đặt vượt tồn kho hiện có (${current.stock}). Vui lòng sửa giỏ hàng.',
        CodValidationReason.quantity,
      );
    }
    if (!acceptUpdatedInformation && current.price != line.product.price) {
      throw CodValidationException(
        '${current.name}: giá đã thay đổi từ ${money(line.product.price)} sang ${money(current.price)}. Vui lòng cập nhật thông tin và xem lại tổng tiền.',
        CodValidationReason.priceChanged,
      );
    }
    if (!acceptUpdatedInformation && current.stock != line.product.stock) {
      throw CodValidationException(
        '${current.name}: tồn kho đã thay đổi từ ${line.product.stock} sang ${current.stock}. Vui lòng cập nhật thông tin và xem lại tổng tiền.',
        CodValidationReason.stockChanged,
      );
    }
    resolved.add(
      CartLine(current, quantity: line.quantity, variant: line.variant),
    );
  }
  return List.unmodifiable(resolved);
}

void validateCodTotals(
  List<CartLine> lines,
  String coupon,
  OrderReviewTotals totals,
) {
  final subtotal = lines.fold(0, (sum, line) => sum + line.total);
  // Preserve the existing LEN50 and 30,000 shipping fixtures, not new rules.
  final discount = coupon == 'LEN50' && subtotal >= 50000 ? 50000 : 0;
  if (totals.subtotal != subtotal ||
      totals.discount != discount ||
      totals.shipping != 30000 ||
      totals.total != subtotal - discount + 30000) {
    throw const CodValidationException(
      'Tổng tiền đã thay đổi hoặc không hợp lệ. Vui lòng xem lại tổng tiền trước khi đặt đơn.',
      CodValidationReason.totalsChanged,
    );
  }
}
