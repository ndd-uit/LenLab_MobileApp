import '../domain/models.dart';
import '../state/lenlab_store.dart';
import 'lenlab_repository.dart';
import 'mock_lenlab_repository.dart';

/// Customer order history. A null state includes all existing order states.
/// The authenticated backend must scope this collection to the current user.
abstract interface class OrderListSource {
  Future<List<Order>> load({OrderState? state});
}

/// Reads the same mock collection as order detail, including newly placed COD.
/// Preserves collection order without inventing a date for legacy fixtures.
class MockOrderListSource implements OrderListSource {
  MockOrderListSource(this.repository, this.orders, {required this.session})
    : ownerId = session.userId;
  final LenlabStore session;
  final String? ownerId;

  final LenlabRepository repository;
  final List<Order> orders;

  @override
  Future<List<Order>> load({OrderState? state}) async {
    session.requireCustomer();
    if (ownerId != session.userId) {
      throw const RepositoryException(
        'Nguồn đơn hàng thuộc phiên tài khoản khác.',
      );
    }
    final actor = session.captureSession();
    if (repository case final MockLenlabRepository mock) {
      await mock.operation('orderList');
    } else {
      throw const RepositoryException(
        'Chưa cấu hình nguồn danh sách đơn hàng.',
      );
    }
    session.requireSession(actor);
    return List<Order>.unmodifiable(
      orders.where(
        (order) =>
            session.ownsOrder(order) && (state == null || order.state == state),
      ),
    );
  }
}
