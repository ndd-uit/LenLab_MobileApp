import '../domain/models.dart';
import '../state/lenlab_store.dart';
import 'lenlab_repository.dart';
import 'mock_lenlab_repository.dart';

abstract interface class OrderDetailSource {
  Future<Order?> load(String id);
}

/// Reads the current in-memory order collection, including newly created COD.
class MockOrderDetailSource implements OrderDetailSource {
  MockOrderDetailSource(this.repository, this.orders, {required this.session})
    : ownerId = session.userId;
  final LenlabStore session;
  final String? ownerId;
  final LenlabRepository repository;
  final List<Order> orders;
  @override
  Future<Order?> load(String id) async {
    session.requireCustomer();
    if (ownerId != session.userId) {
      throw const RepositoryException(
        'Nguồn đơn hàng thuộc phiên tài khoản khác.',
      );
    }
    final actor = session.captureSession();
    if (repository case final MockLenlabRepository mock) {
      await mock.operation('orderDetail');
    } else {
      throw const RepositoryException('Chưa cấu hình nguồn chi tiết đơn hàng.');
    }
    session.requireSession(actor);
    return orders
        .where((order) => order.id == id && session.ownsOrder(order))
        .firstOrNull;
  }
}
