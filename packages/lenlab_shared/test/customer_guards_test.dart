import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

class DelayedCod implements CodOrderSource {
  final started = Completer<CodOrderDraft>();
  final result = Completer<Order>();
  @override
  Future<Order> submit(CodOrderDraft draft) {
    started.complete(draft);
    return result.future;
  }
}

OrderReviewTotals totals(LenlabStore store) => OrderReviewTotals(
  subtotal: store.checkoutSubtotal,
  discount: store.checkoutDiscount,
  shipping: 30000,
);

void main() {
  LenlabStore sample() =>
      LenlabStore(repository: MockLenlabRepository(latency: Duration.zero));
  Future<bool> login(LenlabStore s, [CustomerIdentity user = mockCustomerA]) =>
      s.signIn(identity: user.email, password: 'mock');

  test(
    'Guest COD and refresh reject before any mutation; cart remains editable',
    () async {
      final s = sample();
      addTearDown(s.dispose);
      final catalog = (s.repository as MockLenlabRepository).catalog;
      s.addToCart(catalog.firstWhere((p) => p.id == 'sweater'), 1, 'Guest');
      s.addToCart(catalog.firstWhere((p) => p.id == 'gloves'), 2, 'Guest');
      final cart = List.of(s.cart);
      final source = DelayedCod();
      await expectLater(
        s.submitCodOrder(totals: totals(s), source: source),
        throwsA(isA<RepositoryException>()),
      );
      await expectLater(
        s.refreshCodCheckout(),
        throwsA(isA<RepositoryException>()),
      );
      expect(source.started.isCompleted, isFalse);
      expect(s.orders.length, 0);
      expect(s.cart, orderedEquals(cart));
      expect(s.checkoutNote, isEmpty);
      expect(s.deliveryAddress, isNull);
      expect(s.isSubmittingCod, isFalse);
      s.changeQuantity(s.cart.first, 1);
      expect(s.cart.first.quantity, 2);
      s.removeFromCart(s.cart.last);
      expect(s.cart.length, 1);
    },
  );

  test(
    'private order/address sources reject Guest and do not expose fixtures',
    () async {
      final s = sample();
      addTearDown(s.dispose);
      await expectLater(
        MockOrderListSource(s.repository, s.orders, session: s).load(),
        throwsA(isA<RepositoryException>()),
      );
      await expectLater(
        MockOrderDetailSource(
          s.repository,
          s.orders,
          session: s,
        ).load('WOOL-8823'),
        throwsA(isA<RepositoryException>()),
      );
      await expectLater(
        MockCheckoutAddressSource(s).load(),
        throwsA(isA<RepositoryException>()),
      );
      await expectLater(
        MockCheckoutAddressSource(s)
            .save(const Address(ownerId: mockCustomerAId)),
        throwsA(isA<RepositoryException>()),
      );
      expect(s.addresses, isEmpty);
    },
  );

  test(
    'new COD carries stable owner ID and still deduplicates double submit',
    () async {
      final s = sample();
      addTearDown(s.dispose);
      await login(s);
      s.deliveryAddress = s.addresses.single;
      s.checkoutNote = 'Keep';
      final source = DelayedCod();
      final first = s.submitCodOrder(totals: totals(s), source: source);
      expect(s.submitCodOrder(totals: totals(s), source: source), same(first));
      final draft = await source.started.future;
      expect(draft.ownerId, mockCustomerA.id);
      expect(draft.sessionGeneration, s.sessionGeneration);
      source.result.complete(
        Order(
          id: draft.id,
          ownerId: draft.ownerId,
          lines: draft.lines,
          address: draft.address,
        ),
      );
      final order = await first;
      expect(order.ownerId, mockCustomerA.id);
      expect(s.orders.first, same(order));
      expect(s.cart, isEmpty);
    },
  );

  test(
    'logout then B never applies old COD to shared orders or the new cart',
    () async {
      final s = sample();
      addTearDown(s.dispose);
      await login(s);
      s.deliveryAddress = s.addresses.single;
      s.checkoutNote = 'Keep';
      final source = DelayedCod();
      final pending = s.submitCodOrder(totals: totals(s), source: source);
      final draft = await source.started.future;
      final cart = List.of(s.cart);
      s.logout();
      await expectLater(
        s.submitCodOrder(totals: totals(s)),
        throwsA(isA<RepositoryException>()),
      );
      await login(s, mockCustomerB);
      await expectLater(
        s.submitCodOrder(totals: totals(s)),
        throwsA(isA<RepositoryException>()),
      );
      source.result.complete(
        Order(
          id: draft.id,
          ownerId: draft.ownerId,
          lines: draft.lines,
          address: draft.address,
        ),
      );
      final completed = await pending;
      expect(completed.ownerId, mockCustomerA.id);
      expect(s.userId, mockCustomerB.id);
      expect(s.orders.length, 0);
      expect(s.cart, isEmpty);
      expect(s.checkoutNote, isEmpty);
      expect(s.isSubmittingCod, isFalse);
      s.deliveryAddress = const Address(
        ownerId: 'customer-demo-b',
        name: 'B',
        phone: '0901234568',
      );
      s.addToCart(
        (s.repository as MockLenlabRepository).catalog.firstWhere(
          (p) => p.id == 'sheep',
        ),
        1,
        'B',
      );
      final next = await s.submitCodOrder(totals: totals(s));
      expect(next.ownerId, mockCustomerB.id);
      expect(next.id, isNot(completed.id));
      await login(s);
      expect(s.cart, orderedEquals(cart));
    },
  );

  test('source cannot return a COD receipt with no captured owner', () async {
    final s = sample();
    addTearDown(s.dispose);
    await login(s);
    s.deliveryAddress = s.addresses.single;
    final source = DelayedCod();
    final pending = s.submitCodOrder(totals: totals(s), source: source);
    final failure = expectLater(pending, throwsA(isA<RepositoryException>()));
    final draft = await source.started.future;
    source.result.complete(
      Order(id: draft.id, lines: draft.lines, address: draft.address),
    );
    await failure;
    expect(s.cart.length, 2);
    expect(s.orders.length, 4);
  });

  test(
    'private read begun in A is rejected after logout and B login',
    () async {
      final repo = MockLenlabRepository(
        latency: const Duration(milliseconds: 10),
      );
      final s = LenlabStore(
        repository: repo,
        authSource: MockCustomerAuthSource(latency: Duration.zero),
      );
      addTearDown(s.dispose);
      await login(s);
      s.deliveryAddress = s.addresses.single;
      s.checkoutNote = 'Keep';
      final pending = MockOrderListSource(repo, s.orders, session: s).load();
      final failure = expectLater(pending, throwsA(isA<RepositoryException>()));
      s.logout();
      await login(s, mockCustomerB);
      await failure;
    },
  );
}
