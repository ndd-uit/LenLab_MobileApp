import '../domain/models.dart';
import 'lenlab_repository.dart';
import 'mock_lenlab_repository.dart';
import 'cod_checkout_validation.dart';
import 'order_review_data.dart';

/// A checkout snapshot, not a live reference to the editable cart.
class CodOrderDraft {
  CodOrderDraft({
    required this.ownerId,
    required this.sessionGeneration,
    required this.id,
    required List<CartLine> lines,
    required this.address,
    required this.shipping,
    required this.discount,
    required this.note,
    this.coupon = '',
  }) : lines = List.unmodifiable(
         lines.map(
           (line) => CartLine(
             line.product,
             quantity: line.quantity,
             variant: line.variant,
           ),
         ),
       );
  final String id, note, coupon;
  final String ownerId;
  final int sessionGeneration;
  final List<CartLine> lines;
  final Address address;
  final int shipping, discount;
}

abstract interface class CodOrderSource {
  Future<Order> submit(CodOrderDraft draft);
}

/// Local P2 fixture only. Replace with an API adapter and server idempotency.
class MockCodOrderSource implements CodOrderSource {
  MockCodOrderSource(this.repository);
  final LenlabRepository repository;
  @override
  Future<Order> submit(CodOrderDraft draft) async {
    if (draft.ownerId.trim().isEmpty || draft.sessionGeneration < 1) {
      throw const RepositoryException(
        'Đơn COD cần danh tính tài khoản hợp lệ.',
      );
    }
    if (repository case final MockLenlabRepository mock) {
      await mock.operation('checkout');
    } else {
      throw const RepositoryException('Chưa cấu hình dịch vụ đặt đơn.');
    }
    final lines = validateCodLines(draft.lines, await repository.products());
    validateCodTotals(
      lines,
      draft.coupon,
      OrderReviewTotals(
        subtotal: draft.lines.fold(0, (sum, line) => sum + line.total),
        discount: draft.discount,
        shipping: draft.shipping,
      ),
    );
    return Order(
      ownerId: draft.ownerId,
      id: draft.id,
      lines: lines,
      address: draft.address,
      shipping: draft.shipping,
      discount: draft.discount,
      note: draft.note,
      deliveryEstimate: '24 - 26 Tháng 10',
      createdAt: DateTime.now(),
    );
  }
}
