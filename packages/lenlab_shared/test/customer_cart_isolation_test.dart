import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

class PendingCartCod implements CodOrderSource {
  final entered = Completer<CodOrderDraft>();
  final result = Completer<Order>();
  @override
  Future<Order> submit(CodOrderDraft draft) {
    entered.complete(draft);
    return result.future;
  }

  Future<void> finish() async {
    final d = await entered.future;
    result.complete(
      Order(
        ownerId: d.ownerId,
        id: d.id,
        lines: d.lines,
        address: d.address,
        shipping: d.shipping,
        discount: d.discount,
      ),
    );
  }
}

void main() {
  late LenlabStore s;
  late MockLenlabRepository repo;
  Future<void> login(CustomerIdentity u) =>
      s.signIn(identity: u.email, password: 'mock').then((_) {});
  void add(String id, [int count = 1]) => s.addToCart(
    repo.catalog.firstWhere((p) => p.id == id),
    count,
    'test-variant',
  );
  setUp(() {
    repo = MockLenlabRepository(latency: Duration.zero);
    s = LenlabStore(repository: repo);
  });
  tearDown(() => s.dispose());

  test(
    'new Guest and B empty; fixtures belong to A without automatic coupon',
    () async {
      expect(s.cart, isEmpty);
      expect(s.coupon, isEmpty);
      await login(mockCustomerB);
      expect(s.cart, isEmpty);
      expect(s.coupon, isEmpty);
      await login(mockCustomerA);
      expect(s.cartCount, 3);
      expect(s.coupon, isEmpty);
    },
  );

  test(
    'Guest can edit and select cart while COD submit stays protected',
    () async {
      add('sheep', 2);
      final line = s.cart.single;
      s.changeQuantity(line, 1);
      expect(s.cartCount, 3);
      s.toggleCartLine(line);
      expect(s.checkoutLines, isEmpty);
      await expectLater(
        s.submitCodOrder(
          totals: const OrderReviewTotals(
            subtotal: 0,
            discount: 0,
            shipping: 30000,
          ),
        ),
        throwsA(isA<RepositoryException>()),
      );
      s.removeFromCart(line);
      expect(s.cart, isEmpty);
    },
  );

  test(
    'logout creates fresh Guest; A cart selection coupon survive in RAM',
    () async {
      await login(mockCustomerA);
      final line = s.cart.first;
      s.changeQuantity(line, 1);
      s.toggleCartLine(line);
      s.coupon = 'LEN50';
      final count = s.cartCount;
      s.logout();
      expect(s.cart, isEmpty);
      expect(s.coupon, isEmpty);
      add('carrot');
      await login(mockCustomerA);
      expect(s.cartCount, count);
      expect(s.coupon, 'LEN50');
      expect(s.isCartLineSelected(s.cart.first), isFalse);
      expect(s.pendingGuestCarts.single.single.product.id, 'carrot');
    },
  );

  test(
    'direct A B A switching isolates quantity checkbox and coupon',
    () async {
      await login(mockCustomerA);
      add('sheep', 2);
      final aLine = s.cart.last;
      s.toggleCartLine(aLine);
      s.coupon = 'LEN50';
      await login(mockCustomerB);
      add('sheep', 1);
      expect(s.cart.single, isNot(same(aLine)));
      expect(s.checkoutLines.length, 1);
      expect(s.coupon, isEmpty);
      s.changeQuantity(s.cart.single, 1);
      await login(mockCustomerA);
      expect(s.cart.last.quantity, 2);
      expect(s.isCartLineSelected(s.cart.last), isFalse);
      expect(s.coupon, 'LEN50');
      await login(mockCustomerB);
      expect(s.cartCount, 2);
    },
  );

  test(
    'retained views and callbacks cannot alter another cart or generation',
    () async {
      await login(mockCustomerA);
      final view = s.cart, line = view.first;
      await login(mockCustomerB);
      add('sheep');
      expect(() => view.clear(), throwsA(isA<RepositoryException>()));
      s.changeQuantity(line, 1);
      s.toggleCartLine(line);
      s.removeFromCart(line);
      expect(s.cartCount, 1);
      expect(s.checkoutLines.length, 1);
      await login(mockCustomerA);
      expect(() => view.clear(), throwsA(isA<RepositoryException>()));
      expect(s.cartCount, 3);
    },
  );

  test('failed auth retains Guest cart selection coupon and creates no pending merge', () async {
    add('sheep');
    final line = s.cart.single;
    s.toggleCartLine(line);
    s.coupon = 'LEN50';
    await expectLater(
      s.signIn(identity: 'unknown@example.com', password: 'mock'),
      throwsA(isA<RepositoryException>()),
    );
    expect(s.cart.single, same(line));
    expect(s.checkoutLines, isEmpty);
    expect(s.coupon, 'LEN50');
    expect(s.signedIn, isFalse);
  });

  test('successful login retains Guest separately without merge or coupon transfer', () async {
    add('sheep', 2);
    s.toggleCartLine(s.cart.single);
    s.coupon = 'LEN50';
    await login(mockCustomerB);
    expect(s.cart, isEmpty);
    expect(s.coupon, isEmpty);
    expect(s.pendingGuestCarts.single.single.quantity, 2);
    await login(mockCustomerB);
    expect(s.pendingGuestCarts.length, 1);
    await login(mockCustomerA);
    expect(s.pendingGuestCarts, isEmpty);
  });

  test(
    'registration opens empty own cart and retains Guest for later merge',
    () async {
      add('carrot');
      await s.register(
        name: 'New',
        identity: 'cart-new@example.com',
        password: 'mock',
      );
      expect(s.cart, isEmpty);
      expect(s.coupon, isEmpty);
      expect(s.pendingGuestCarts.single.single.product.id, 'carrot');
    },
  );

  test(
    'new Store has fresh RAM state without account cart persistence',
    () async {
      await login(mockCustomerB);
      add('sheep');
      final other = LenlabStore(
        repository: MockLenlabRepository(latency: Duration.zero),
      );
      addTearDown(other.dispose);
      await other.signIn(identity: mockCustomerB.email, password: 'mock');
      expect(other.cart, isEmpty);
      expect(s.cartCount, 1);
    },
  );

  test('pending COD locks A only; detached completion does not reconcile carts in 4A', () async {
    await login(mockCustomerA);
    s.deliveryAddress = s.addresses.single;
    final initial = s.cartCount;
    final source = PendingCartCod();
    final pending = s.submitCodOrder(
      totals: OrderReviewTotals(
        subtotal: s.checkoutSubtotal,
        discount: s.checkoutDiscount,
        shipping: 30000,
      ),
      source: source,
    );
    await source.entered.future;
    add('sheep');
    expect(s.cartCount, initial);
    expect(() => s.cart.clear(), throwsA(isA<RepositoryException>()));
    s.logout();
    add('carrot');
    expect(s.cartCount, 1);
    expect(s.isSubmittingCod, isFalse);
    await login(mockCustomerB);
    add('sheep');
    expect(s.cartCount, 1);
    await login(mockCustomerA);
    expect(s.isSubmittingCod, isTrue);
    add('carrot');
    expect(s.cartCount, initial);
    await source.finish();
    await pending;
    expect(s.cartCount, initial); // Batch 4C must handle purchased lines later.
    await login(mockCustomerB);
    expect(s.cartCount, 1);
  });
}
