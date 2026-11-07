import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

void main() {
  late MockLenlabRepository repository;
  late LenlabStore store;
  setUp(() {
    repository = MockLenlabRepository(latency: Duration.zero);
    store = LenlabStore(repository: repository)
      ..signedIn = true
      ..coupon = 'LEN50';
  });
  test(
    'seed cart computes P2 subtotal, discount and shipping consistently',
    () async {
      expect(store.subtotal, 1900000);
      expect(store.discount, 50000);
      store.deliveryAddress = const Address(ownerId: mockCustomerAId);
      final order = await store.submitCodOrder(
        totals: const OrderReviewTotals(
          subtotal: 1900000,
          discount: 50000,
          shipping: 30000,
        ),
      );
      expect(order.total, 1880000);
      expect(order.payment, PaymentState.cod);
      expect(store.cart, isEmpty);
      expect(order.lines.length, 2);
    },
  );
  test(
    'different variants stay separate; quantity changes preserve bounds',
    () {
      final p = repository.catalog.first;
      store.cart.clear();
      store.addToCart(p, 1, 'Kem · 180cm');
      store.addToCart(p, 2, 'Kem · 200cm');
      store.addToCart(p, 3, 'Kem · 180cm');
      expect(store.cart.length, 2);
      expect(store.cart.first.quantity, 4);
      store.changeQuantity(store.cart.last, -2);
      expect(store.cart.last.quantity, 2);
    },
  );
}
