import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

LenlabStore sample() =>
    LenlabStore(repository: MockLenlabRepository(latency: Duration.zero))
      ..signedIn = true
      ..coupon = 'LEN50'
      ..deliveryAddress = const Address(ownerId: mockCustomerAId);
OrderReviewTotals totals(LenlabStore store) => OrderReviewTotals(
  subtotal: store.checkoutSubtotal,
  discount: store.checkoutDiscount,
  shipping: 30000,
);

void main() {
  test('Selection keeps cart intact, computes existing fixture discount on selected subtotal', () {
    final store = sample();
    expect(store.checkoutLines.length, 2);
    store.toggleCartLine(store.cart.first);
    expect(store.checkoutSubtotal, 700000);
    expect(store.checkoutDiscount, 50000);
    expect(store.subtotal, 1900000);
    expect(store.cartCount, 3);
    store.changeQuantity(store.cart.first, 1);
    expect(store.checkoutSubtotal, 700000);
    store.toggleCartLine(store.cart.last);
    expect(store.checkoutSubtotal, 0);
    expect(store.checkoutDiscount, 0);
    expect(store.cart.length, 2);
    final cheap = Product(
      id: 'test',
      name: 'Test',
      price: 45000,
      image: '',
      category: '',
    );
    store.addToCart(cheap, 1, 'A');
    expect(store.checkoutSubtotal, 45000);
    expect(store.checkoutDiscount, 0);
  });

  test('Variant keys are independent; remove/re-add selects the new line', () {
    final store = sample();
    final p = store.cart.first.product;
    store.addToCart(p, 1, 'Other variant');
    final first = store.cart.first;
    store.toggleCartLine(first);
    expect(store.isCartLineSelected(store.cart.last), isTrue);
    store.removeFromCart(first);
    store.addToCart(p, 1, first.variant);
    expect(store.isCartLineSelected(store.cart.last), isTrue);
    expect(() => store.checkoutLines.clear(), throwsUnsupportedError);
  });

  test('No selection or stale totals cannot create COD; failure keeps selection and cart', () async {
    final store = sample();
    final previous = totals(store);
    store.toggleCartLine(store.cart.first);
    await expectLater(
      store.submitCodOrder(totals: previous),
      throwsA(isA<RepositoryException>()),
    );
    (store.repository as MockLenlabRepository).failNext('checkout');
    await expectLater(
      store.submitCodOrder(totals: totals(store)),
      throwsA(isA<RepositoryException>()),
    );
    expect(store.cart.length, 2);
    expect(store.checkoutLines.single.product.id, 'gloves');
    expect(store.orders.length, 4);
    store.toggleCartLine(store.cart.last);
    await expectLater(
      store.submitCodOrder(totals: totals(store)),
      throwsA(isA<RepositoryException>()),
    );
    expect(store.orders.length, 4);
  });

  test('In-flight selection is locked; success buys only selected variant and retains others', () async {
    final store = sample();
    final unselected = store.cart.first;
    store.toggleCartLine(unselected);
    final selected = store.cart.last;
    final request = store.submitCodOrder(totals: totals(store));
    store.toggleCartLine(unselected);
    store.toggleCartLine(selected);
    expect(store.checkoutLines.single, same(selected));
    expect(
      identical(store.submitCodOrder(totals: totals(store)), request),
      isTrue,
    );
    final order = await request;
    expect(order.lines.single.product.id, 'gloves');
    expect(order.lines.single.quantity, 2);
    expect(order.total, 680000);
    expect(store.cart.single, same(unselected));
    expect(store.isCartLineSelected(unselected), isFalse);
    expect(store.checkoutLines, isEmpty);
    expect(store.orders.length, 5);
  });
}
