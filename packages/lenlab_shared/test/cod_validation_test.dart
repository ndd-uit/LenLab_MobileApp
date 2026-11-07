import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

OrderReviewTotals quote(LenlabStore store) => OrderReviewTotals(
  subtotal: store.checkoutSubtotal,
  discount: store.checkoutDiscount,
  shipping: 30000,
);

LenlabStore storeFor(MockLenlabRepository repository) =>
    LenlabStore(repository: repository)
      ..signedIn = true
      ..coupon = 'LEN50'
      ..deliveryAddress = const Address(ownerId: mockCustomerAId)
      ..checkoutNote = 'Giữ ghi chú';

class CountingSource implements CodOrderSource {
  CountingSource(this.repository);
  final MockLenlabRepository repository;
  int calls = 0;
  @override
  Future<Order> submit(CodOrderDraft draft) {
    calls++;
    return MockCodOrderSource(repository).submit(draft);
  }
}

class ChangingRepository extends MockLenlabRepository {
  ChangingRepository() : super(latency: Duration.zero);
  void Function()? duringCheckout;
  @override
  Future<void> operation(String name) async {
    await super.operation(name);
    if (name == 'checkout') duringCheckout?.call();
  }
}

void expectPreserved(
  LenlabStore store,
  List<CartLine> original,
  Address address,
) {
  expect(store.cart, orderedEquals(original));
  expect(store.orders, hasLength(4));
  expect(store.deliveryAddress, same(address));
  expect(store.checkoutNote, 'Giữ ghi chú');
  expect(store.coupon, 'LEN50');
  expect(store.isSubmittingCod, isFalse);
}

void main() {
  final invalid = <String, CodValidationReason>{
    'removed': CodValidationReason.missing,
    'duplicate-id': CodValidationReason.duplicate,
    'hidden': CodValidationReason.hidden,
    'out-of-stock': CodValidationReason.stock,
    'zero-quantity': CodValidationReason.quantity,
    'negative-quantity': CodValidationReason.quantity,
    'exceeds-stock': CodValidationReason.quantity,
    'invalid-price': CodValidationReason.unavailable,
    'new-price': CodValidationReason.priceChanged,
    'new-stock': CodValidationReason.stockChanged,
  };
  for (final entry in invalid.entries) {
    test(
      '${entry.key} blocks creation and preserves the selected checkout',
      () async {
        final repository = MockLenlabRepository(latency: Duration.zero);
        final store = storeFor(repository);
        final original = List.of(store.cart);
        final address = store.deliveryAddress!;
        final product = repository.catalog.singleWhere(
          (p) => p.id == original.first.product.id,
        );
        switch (entry.key) {
          case 'removed':
            repository.catalog.remove(product);
          case 'duplicate-id':
            repository.catalog.add(Product.snapshot(product));
          case 'hidden':
            product.published = false;
          case 'out-of-stock':
            product.stock = 0;
          case 'zero-quantity':
            original.first.quantity = 0;
          case 'negative-quantity':
            original.first.quantity = -1;
          case 'exceeds-stock':
            original.first.quantity = product.stock + 1;
          case 'invalid-price':
            product.price = 0;
          case 'new-price':
            product.price += 50000;
          case 'new-stock':
            product.stock += 1;
        }
        final source = CountingSource(repository);
        await expectLater(
          store.submitCodOrder(totals: quote(store), source: source),
          throwsA(
            isA<CodValidationException>().having(
              (e) => e.reason,
              'reason',
              entry.value,
            ),
          ),
        );
        expect(source.calls, 0);
        expectPreserved(store, original, address);
      },
    );
  }

  test(
    'Quantities are aggregated across variants of the same product',
    () async {
      final repository = MockLenlabRepository(latency: Duration.zero);
      final store = storeFor(repository);
      final product = repository.catalog.first;
      store.cart.clear();
      store.addToCart(product, 30, 'A');
      store.addToCart(product, 20, 'B');
      await expectLater(
        store.submitCodOrder(totals: quote(store)),
        throwsA(
          isA<CodValidationException>().having(
            (e) => e.reason,
            'reason',
            CodValidationReason.quantity,
          ),
        ),
      );
      expect(store.cart.map((l) => l.quantity), [30, 20]);
      expect(product.stock, 45);
    },
  );

  test('Duplicate cart keys cannot create repeated order lines', () async {
    final repository = MockLenlabRepository(latency: Duration.zero);
    final store = storeFor(repository);
    store.cart.add(
      CartLine(store.cart.first.product, variant: store.cart.first.variant),
    );
    await expectLater(
      store.submitCodOrder(totals: quote(store)),
      throwsA(isA<CodValidationException>()),
    );
    expect(store.orders, hasLength(4));
  });

  for (final field in ['subtotal', 'discount', 'shipping', 'stale-shipping']) {
    test('Tampered $field cannot reach the order source', () async {
      final repository = MockLenlabRepository(latency: Duration.zero);
      final store = storeFor(repository);
      final source = CountingSource(repository);
      final valid = quote(store);
      final invalid = OrderReviewTotals(
        subtotal: valid.subtotal + (field == 'subtotal' ? 1 : 0),
        discount: valid.discount + (field == 'discount' ? 1 : 0),
        shipping: field == 'shipping'
            ? -1
            : field == 'stale-shipping'
            ? 15000
            : valid.shipping,
      );
      await expectLater(
        store.submitCodOrder(totals: invalid, source: source),
        throwsA(
          isA<CodValidationException>().having(
            (e) => e.requiresReview,
            'review required',
            isTrue,
          ),
        ),
      );
      expect(source.calls, 0);
      expect(store.cartCount, 3);
      expect(store.orders, hasLength(4));
    });
  }

  test('No selected lines cannot create an order', () async {
    final store = storeFor(MockLenlabRepository(latency: Duration.zero));
    for (final line in store.cart) {
      store.toggleCartLine(line);
    }
    await expectLater(
      store.submitCodOrder(totals: quote(store)),
      throwsA(isA<RepositoryException>()),
    );
    expect(store.cartCount, 3);
    expect(store.checkoutLines, isEmpty);
    expect(store.orders, hasLength(4));
  });

  test(
    'Catalog load failure preserves the draft and retry is possible',
    () async {
      final repository = MockLenlabRepository(latency: Duration.zero)
        ..failNext('products');
      final store = storeFor(repository);
      final original = List.of(store.cart);
      final address = store.deliveryAddress!;
      await expectLater(
        store.submitCodOrder(totals: quote(store)),
        throwsA(isA<RepositoryException>()),
      );
      expectPreserved(store, original, address);
      final order = await store.submitCodOrder(totals: quote(store));
      expect(order.total, 1880000);
    },
  );

  test('Price is frozen until explicit review; success retains an independent snapshot', () async {
    final repository = MockLenlabRepository(latency: Duration.zero);
    final store = storeFor(repository);
    final unselected = store.cart.last;
    store.toggleCartLine(unselected);
    final selected = store.cart.first;
    final product = repository.catalog.singleWhere(
      (p) => p.id == selected.product.id,
    );
    final oldPrice = selected.product.price;
    product.price += 50000;
    expect(selected.product.price, oldPrice);
    expect(store.checkoutSubtotal, oldPrice);
    await expectLater(
      store.submitCodOrder(totals: quote(store)),
      throwsA(isA<CodValidationException>()),
    );
    await store.refreshCodCheckout();
    expect(store.checkoutLines.single.product.price, product.price);
    expect(store.checkoutLines.single.quantity, selected.quantity);
    expect(store.cart.last, same(unselected));
    expect(store.isCartLineSelected(unselected), isFalse);
    expect(store.checkoutNote, 'Giữ ghi chú');
    expect(store.orders, hasLength(4));
    final first = store.submitCodOrder(totals: quote(store));
    expect(store.submitCodOrder(totals: quote(store)), same(first));
    final order = await first;
    expect(order.lines.single.product.price, oldPrice + 50000);
    expect(order.lines.single.product.id, selected.product.id);
    expect(order.lines.single.product.name, product.name);
    expect(order.lines.single.quantity, 1);
    expect(store.cart.single, same(unselected));
    expect(repository.catalog.singleWhere((p) => p.id == product.id).stock, 45);
    product.price = 1;
    product.name = 'Changed later';
    selected.quantity = 20;
    expect(order.lines.single.product.price, oldPrice + 50000);
    expect(order.lines.single.product.name, isNot(product.name));
    expect(order.lines.single.quantity, 1);
  });

  test(
    'Explicit review is atomic when another selected product becomes invalid',
    () async {
      final repository = MockLenlabRepository(latency: Duration.zero);
      final store = storeFor(repository);
      final original = List.of(store.cart);
      repository.catalog
              .singleWhere((p) => p.id == original.first.product.id)
              .price +=
          50000;
      repository.catalog
              .singleWhere((p) => p.id == original.last.product.id)
              .published =
          false;
      await expectLater(
        store.refreshCodCheckout(),
        throwsA(isA<CodValidationException>()),
      );
      expectPreserved(store, original, store.deliveryAddress!);
      expect(original.first.product.price, 1200000);
    },
  );

  test('Stock change requires review even if remaining stock still covers quantity', () async {
    final repository = MockLenlabRepository(latency: Duration.zero);
    final store = storeFor(repository);
    final product = repository.catalog.singleWhere(
      (p) => p.id == store.cart.first.product.id,
    );
    product.stock = 20;
    await expectLater(
      store.submitCodOrder(totals: quote(store)),
      throwsA(
        isA<CodValidationException>().having(
          (e) => e.reason,
          'reason',
          CodValidationReason.stockChanged,
        ),
      ),
    );
    await store.refreshCodCheckout();
    final order = await store.submitCodOrder(totals: quote(store));
    expect(order.lines.first.product.stock, 20);
    expect(product.stock, 20);
  });

  test(
    'Invalid unselected items are kept but do not block selected valid lines',
    () async {
      final repository = MockLenlabRepository(latency: Duration.zero);
      final store = storeFor(repository);
      final unselected = store.cart.first;
      store.toggleCartLine(unselected);
      repository.catalog.removeWhere((p) => p.id == unselected.product.id);
      final order = await store.submitCodOrder(totals: quote(store));
      expect(order.lines.single.product.id, 'gloves');
      expect(store.cart.single, same(unselected));
      expect(store.checkoutLines, isEmpty);
      expect(store.isCartLineSelected(unselected), isFalse);
    },
  );

  for (final mutation in ['price', 'stock', 'removed', 'hidden']) {
    test(
      '$mutation during the submit delay is revalidated before creation',
      () async {
        final repository = ChangingRepository();
        final store = storeFor(repository);
        final original = List.of(store.cart);
        final product = repository.catalog.singleWhere(
          (p) => p.id == original.first.product.id,
        );
        repository.duringCheckout = () {
          switch (mutation) {
            case 'price':
              product.price++;
            case 'stock':
              product.stock = 0;
            case 'removed':
              repository.catalog.remove(product);
            case 'hidden':
              product.published = false;
          }
        };
        await expectLater(
          store.submitCodOrder(totals: quote(store)),
          throwsA(isA<CodValidationException>()),
        );
        expectPreserved(store, original, store.deliveryAddress!);
      },
    );
  }
}
