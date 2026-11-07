import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

const totals = OrderReviewTotals(
  subtotal: 1900000,
  discount: 50000,
  shipping: 30000,
);

void main() {
  test('concurrent COD calls share one submission and snapshot prices and quantities', () async {
    final repo = MockLenlabRepository(
      latency: const Duration(milliseconds: 20),
    );
    final store = LenlabStore(repository: repo)
      ..signedIn = true
      ..coupon = 'LEN50'
      ..deliveryAddress = const Address(ownerId: mockCustomerAId)
      ..checkoutNote = 'Gói quà';
    final first = store.submitCodOrder(totals: totals);
    final second = store.submitCodOrder(totals: totals);
    expect(identical(first, second), isTrue);
    expect(store.isSubmittingCod, isTrue);
    store.changeQuantity(store.cart.first, 1);
    store.removeFromCart(store.cart.last);
    store.addToCart(repo.catalog.first, 1, 'khác');
    // Cart editing cannot rewrite the price in an already submitted snapshot.
    store.cart.first.product.price = 1;
    final order = await first;
    expect(await second, same(order));
    expect(store.orders.length, 5);
    expect(order.lines.length, 2);
    expect(order.lines.first.quantity, 1);
    expect(order.total, 1880000);
    expect(order.note, 'Gói quà');
    expect(order.payment, PaymentState.cod);
    expect(order.state, OrderState.pending);
    expect(store.cart, isEmpty);
    expect(store.coupon, isEmpty);
    expect(store.checkoutNote, isEmpty);
    expect(store.isSubmittingCod, isFalse);
  });

  test(
    'failed COD preserves the checkout draft and retry creates one order',
    () async {
      final repo = MockLenlabRepository(latency: Duration.zero)
        ..failNext('checkout');
      final store = LenlabStore(repository: repo)
        ..signedIn = true
        ..coupon = 'LEN50'
        ..deliveryAddress = const Address(ownerId: mockCustomerAId)
        ..checkoutNote = 'Giao chiều';
      await expectLater(
        store.submitCodOrder(totals: totals),
        throwsA(isA<RepositoryException>()),
      );
      expect(store.isSubmittingCod, isFalse);
      expect(store.cartCount, 3);
      expect(store.orders.length, 4);
      expect(store.coupon, 'LEN50');
      expect(store.checkoutNote, 'Giao chiều');
      final order = await store.submitCodOrder(totals: totals);
      expect(order.note, 'Giao chiều');
      expect(order.total, 1880000);
      expect(store.orders.length, 5);
    },
  );

  test('missing address empty cart and stale totals cannot submit', () async {
    final store =
        LenlabStore(repository: MockLenlabRepository(latency: Duration.zero))
          ..signedIn = true
          ..coupon = 'LEN50';
    await expectLater(
      store.submitCodOrder(totals: totals),
      throwsA(isA<RepositoryException>()),
    );
    store.deliveryAddress = const Address(ownerId: mockCustomerAId);
    store.changeQuantity(store.cart.first, 1);
    await expectLater(
      store.submitCodOrder(totals: totals),
      throwsA(isA<RepositoryException>()),
    );
    store.cart.clear();
    await expectLater(
      store.submitCodOrder(totals: totals),
      throwsA(isA<RepositoryException>()),
    );
    expect(store.orders.length, 4);
  });
}
