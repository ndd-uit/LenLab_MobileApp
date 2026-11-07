import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

LenlabStore accountStore() =>
    LenlabStore(repository: MockLenlabRepository(latency: Duration.zero));
Future<void> enter(LenlabStore s, CustomerIdentity user) async {
  await s.signIn(identity: user.email, password: 'mock');
}

void main() {
  test(
    'Guest has no saved private fixture; A owns all declared seed records',
    () async {
      final s = accountStore();
      addTearDown(s.dispose);
      expect(s.profile.email, isEmpty);
      expect(s.addresses, isEmpty);
      expect(s.orders, isEmpty);
      await enter(s, mockCustomerA);
      expect(s.profile.ownerId, mockCustomerA.id);
      expect(s.orders.length, 4);
      expect(s.orders.every((o) => o.ownerId == mockCustomerA.id), isTrue);
      expect(s.addresses.single.ownerId, mockCustomerA.id);
    },
  );

  test('B logging in first never inherits A fixtures; A saved data survives switching', () async {
    final s = accountStore();
    addTearDown(s.dispose);
    await enter(s, mockCustomerB);
    expect(s.profile.name, mockCustomerB.name);
    expect(s.profile.ownerId, mockCustomerB.id);
    expect(s.orders, isEmpty);
    expect(s.addresses, isEmpty);
    s.profile.name = 'B saved';
    await enter(s, mockCustomerA);
    s.profile.name = 'A saved';
    s.logout();
    await enter(s, mockCustomerA);
    expect(s.profile.name, 'A saved');
    await enter(s, mockCustomerB);
    expect(s.profile.name, 'B saved');
    expect(s.orders, isEmpty);
  });

  test('registered identity owns its own empty account', () async {
    final s = accountStore();
    addTearDown(s.dispose);
    await s.register(
      name: 'New',
      identity: 'new@example.com',
      password: 'mock',
    );
    expect(s.profile.ownerId, s.userId);
    expect(s.profile.name, 'New');
    expect(s.profile.email, 'new@example.com');
    expect(s.profile.avatarBytes, isNull);
    expect(s.profile.birthday, isEmpty);
    expect(s.orders, isEmpty);
    expect(s.addresses, isEmpty);
  });

  test('a retained A order source cannot expose A records in B', () async {
    final s = accountStore();
    addTearDown(s.dispose);
    await enter(s, mockCustomerA);
    final aOrder = s.orders.first;
    final list = MockOrderListSource(s.repository, s.orders, session: s);
    final detail = MockOrderDetailSource(s.repository, s.orders, session: s);
    expect(await detail.load(aOrder.id), same(aOrder));
    await enter(s, mockCustomerB);
    await expectLater(list.load(), throwsA(isA<RepositoryException>()));
    await expectLater(
      detail.load(aOrder.id),
      throwsA(isA<RepositoryException>()),
    );
    expect(s.findOwnedOrder(aOrder.id), isNull);
    expect(s.ownsOrder(aOrder), isFalse);
  });

  test(
    'foreign and unknown-owner addresses cannot replace a saved address',
    () async {
      final s = accountStore();
      addTearDown(s.dispose);
      await enter(s, mockCustomerA);
      final address = s.addresses.single;
      await enter(s, mockCustomerB);
      final source = MockCheckoutAddressSource(s);
      await expectLater(
        source.save(address),
        throwsA(isA<RepositoryException>()),
      );
      await expectLater(
        source.save(const Address(), replacing: address),
        throwsA(isA<RepositoryException>()),
      );
      expect(s.addresses, isEmpty);
      await source.save(const Address(name: 'B', street: 'B street'));
      expect(s.addresses.single.ownerId, mockCustomerB.id);
      await enter(s, mockCustomerA);
      expect(s.addresses.single, same(address));
    },
  );

  test(
    'review permission and uniqueness use owner ID rather than mutable email',
    () async {
      final s = accountStore();
      addTearDown(s.dispose);
      await enter(s, mockCustomerA);
      final order = s.orders.firstWhere((o) => o.state == OrderState.delivered);
      final productId = order.lines.single.product.id;
      await enter(s, mockCustomerB);
      s.profile.email = mockCustomerA.email;
      expect(
        () => s.reviewOrder(order.id),
        throwsA(isA<RepositoryException>()),
      );
      await expectLater(
        s.submitProductReview(
          orderId: order.id,
          productId: productId,
          rating: 5,
        ),
        throwsA(isA<RepositoryException>()),
      );
      await enter(s, mockCustomerA);
      final review = await s.submitProductReview(
        orderId: order.id,
        productId: productId,
        rating: 5,
      );
      expect(review.authorId, mockCustomerA.id);
      s.profile.email = 'changed@example.com';
      expect(s.hasReviewed(order.id, productId), isTrue);
      await expectLater(
        s.submitProductReview(
          orderId: order.id,
          productId: productId,
          rating: 4,
        ),
        throwsA(isA<RepositoryException>()),
      );
      s.logout();
      expect(s.reviewsFor(productId).reviews, contains(review));
    },
  );

  test('checkout transient draft resets on switching; A cart remains in its account', () async {
    final s = accountStore();
    addTearDown(s.dispose);
    await enter(s, mockCustomerA);
    final cart = List.of(s.cart);
    s.deliveryAddress = s.addresses.single;
    s.checkoutNote = 'Private A note';
    s.bankTransferReference = 'Private A reference';
    s.checkoutPaymentMethod = CheckoutPaymentMethod.bankTransfer;
    await enter(s, mockCustomerB);
    expect(s.deliveryAddress, isNull);
    expect(s.checkoutNote, isEmpty);
    expect(s.bankTransferReference, isNull);
    expect(s.checkoutPaymentMethod, CheckoutPaymentMethod.cod);
    expect(s.cart, isEmpty);
    s.checkoutNote = 'B draft';
    s.logout();
    expect(s.checkoutNote, isEmpty);
    expect(() => s.checkoutNote = 'Guest', throwsA(isA<RepositoryException>()));
    await enter(s, mockCustomerA);
    expect(s.cart, orderedEquals(cart));
    expect(s.checkoutNote, isEmpty);
    expect(s.profile.email, mockCustomerA.email);
  });

  test(
    'favorites and Custom are scoped accounts while Guest remains public',
    () async {
      final s = accountStore();
      addTearDown(s.dispose);
      expect(s.customs, isEmpty);
      expect(s.favorites, isEmpty);
      expect(
        () => s.toggleFavorite('sheep'),
        throwsA(isA<RepositoryException>()),
      );
      await enter(s, mockCustomerA);
      s.toggleFavorite('sheep');
      expect(s.customs.every((r) => r.ownerId == mockCustomerA.id), isTrue);
      await enter(s, mockCustomerB);
      expect(s.customs, isEmpty);
      expect(s.favorites, isEmpty);
      s.toggleFavorite('carrot');
      await enter(s, mockCustomerA);
      expect(s.favorites, {'sheep'});
    },
  );

  test('unknown-owner saved records are never assigned by login or exposed by sources', () async {
    final s = accountStore();
    addTearDown(s.dispose);
    await enter(s, mockCustomerA);
    final unknown = Order(id: 'UNKNOWN', lines: [], address: const Address());
    expect(() => s.orders.add(unknown), throwsA(isA<RepositoryException>()));
    expect(
      () => s.addresses.add(const Address(name: 'Unknown owner')),
      throwsA(isA<RepositoryException>()),
    );
    expect(s.findOwnedOrder('UNKNOWN'), isNull);
    expect(
      await MockOrderListSource(s.repository, s.orders, session: s).load(),
      isNot(contains(unknown)),
    );
    expect(
      (await MockCheckoutAddressSource(
        s,
      ).load()).saved.every((a) => a.ownerId == mockCustomerA.id),
      isTrue,
    );
    s.logout();
    await enter(s, mockCustomerB);
    expect(s.orders, isEmpty);
    expect(unknown.ownerId, isNull);
  });

  test(
    'Store rejects foreign records and stale collection mutation handles',
    () async {
      final s = accountStore();
      addTearDown(s.dispose);
      await enter(s, mockCustomerA);
      final addresses = s.addresses, orders = s.orders;
      final favoriteSet = s.favorites;
      final address = addresses.single, order = orders.first;
      await enter(s, mockCustomerB);
      expect(() => addresses.clear(), throwsA(isA<RepositoryException>()));
      expect(() => orders.clear(), throwsA(isA<RepositoryException>()));
      expect(
        () => favoriteSet.add('sheep'),
        throwsA(isA<RepositoryException>()),
      );
      expect(() => s.orders.add(order), throwsA(isA<RepositoryException>()));
      expect(
        () => s.addresses.add(address),
        throwsA(isA<RepositoryException>()),
      );
      expect(s.orders, isEmpty);
      expect(s.addresses, isEmpty);
      await enter(s, mockCustomerA);
      expect(s.orders.length, 4);
      expect(s.addresses.single, same(address));
      expect(() => addresses.clear(), throwsA(isA<RepositoryException>()));
    },
  );
}
