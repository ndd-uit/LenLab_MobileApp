import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

void main() {
  late MockLenlabRepository repository;
  late LenlabStore store;
  late MockOrderListSource source;

  setUp(() {
    repository = MockLenlabRepository(latency: Duration.zero);
    store = LenlabStore(repository: repository)
      ..signedIn = true
      ..coupon = 'LEN50';
    source = MockOrderListSource(repository, store.orders, session: store);
  });

  test(
    'all and each status return actual orders without changing order',
    () async {
      expect(await source.load(), orderedEquals(store.orders));
      for (final state in OrderState.values) {
        expect(
          await source.load(state: state),
          orderedEquals(store.orders.where((order) => order.state == state)),
        );
      }
    },
  );

  test(
    'empty collection and status without matches return an empty list',
    () async {
      final empty = MockOrderListSource(repository, [], session: store);
      expect(await empty.load(), isEmpty);
      final single = MockOrderListSource(repository, [
        store.orders.first,
      ], session: store);
      expect(await single.load(state: OrderState.cancelled), isEmpty);
    },
  );

  test(
    'failure can be retried without changing orders, stock or cart',
    () async {
      final ids = store.orders.map((order) => order.id).toList();
      final states = store.orders.map((order) => order.state).toList();
      final payments = store.orders.map((order) => order.payment).toList();
      final stocks = store.cart.map((line) => line.product.stock).toList();
      final cartCount = store.cartCount;
      repository.failNext('orderList');
      await expectLater(source.load(), throwsA(isA<RepositoryException>()));
      expect((await source.load()).map((order) => order.id), ids);
      expect(store.orders.map((order) => order.state), states);
      expect(store.orders.map((order) => order.payment), payments);
      expect(store.cart.map((line) => line.product.stock), stocks);
      expect(store.cartCount, cartCount);
    },
  );

  test(
    'list cannot modify the store collection and reload reads current state',
    () async {
      final result = await source.load();
      expect(() => result.clear(), throwsUnsupportedError);
      final order = store.orders.first;
      order.state = OrderState.cancelled;
      expect(
        await source.load(state: OrderState.cancelled),
        contains(same(order)),
      );
      final detail = MockOrderDetailSource(
        repository,
        store.orders,
        session: store,
      );
      expect(await detail.load(order.id), same(order));
      expect(store.orders.length, result.length);
    },
  );

  test(
    'existing source sees newly submitted COD with matching detail and total',
    () async {
      store.deliveryAddress = const Address(ownerId: mockCustomerAId);
      final order = await store.submitCodOrder(
        totals: const OrderReviewTotals(
          subtotal: 1900000,
          discount: 50000,
          shipping: 30000,
        ),
      );
      final result = await source.load(state: OrderState.pending);
      expect(result, contains(same(order)));
      final detail = await MockOrderDetailSource(
        repository,
        store.orders,
        session: store,
      ).load(order.id);
      expect(detail, same(order));
      expect(detail!.total, 1880000);
      expect(detail.payment, PaymentState.cod);
      expect(store.orders.where((item) => item.id == order.id), hasLength(1));
    },
  );
}
