import '../domain/models.dart';
import 'mock_lenlab_repository.dart';
import 'lenlab_repository.dart';

class OrderReviewTotals {
  const OrderReviewTotals({
    required this.subtotal,
    required this.discount,
    required this.shipping,
  });
  final int subtotal, discount, shipping;
  int get total => subtotal - discount + shipping;
}

abstract interface class OrderReviewSource {
  Future<OrderReviewTotals> preview({
    required int subtotal,
    required int discount,
    required Address address,
  });
}

/// The shipping amount is a P2 fixture, not a production delivery rule.
class MockOrderReviewSource implements OrderReviewSource {
  MockOrderReviewSource(this.repository);
  final LenlabRepository repository;
  @override
  Future<OrderReviewTotals> preview({
    required int subtotal,
    required int discount,
    required Address address,
  }) async {
    if (repository case final MockLenlabRepository mock) {
      await mock.operation('orderReview');
    }
    return OrderReviewTotals(
      subtotal: subtotal,
      discount: discount,
      shipping: 30000,
    );
  }
}
