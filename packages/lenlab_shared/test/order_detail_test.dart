import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

void main() {
  test('detail source resolves exact id including newly submitted COD and missing id', () async {
    final repository = MockLenlabRepository(latency: Duration.zero);
    final store = LenlabStore(repository: repository)
      ..signedIn = true
      ..coupon = 'LEN50'
      ..deliveryAddress = const Address(ownerId: mockCustomerAId);
    final source = MockOrderDetailSource(
      repository,
      store.orders,
      session: store,
    );
    expect(await source.load('missing'), isNull);
    expect(await source.load('WOOL-8805'), same(store.orders[1]));
    final order = await store.submitCodOrder(
      totals: const OrderReviewTotals(
        subtotal: 1900000,
        discount: 50000,
        shipping: 30000,
      ),
    );
    expect(await source.load(order.id), same(order));
    expect(order.createdAt, isNotNull);
    expect(order.payment, PaymentState.cod);
  });
  test('detail source failure is retryable and read-only', () async {
    final repository = MockLenlabRepository(latency: Duration.zero)
      ..failNext('orderDetail');
    final store = LenlabStore(repository: repository)
      ..signedIn = true
      ..coupon = 'LEN50';
    final source = MockOrderDetailSource(
      repository,
      store.orders,
      session: store,
    );
    await expectLater(
      source.load('WOOL-8823'),
      throwsA(isA<RepositoryException>()),
    );
    expect((await source.load('WOOL-8823'))!.state, OrderState.shipping);
    expect(store.orders.length, 4);
    expect(store.cartCount, 3);
  });
}
