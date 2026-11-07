import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

class PendingAuth implements CustomerAuthSource {
  final requests = <Completer<CustomerIdentity>>[];
  @override
  Future<CustomerIdentity> signIn({
    required String identity,
    required String password,
  }) {
    final request = Completer<CustomerIdentity>();
    requests.add(request);
    return request.future;
  }

  @override
  Future<CustomerIdentity> register({
    required String name,
    required String identity,
    required String password,
  }) => signIn(identity: identity, password: password);
}

void main() {
  MockCustomerAuthSource source() =>
      MockCustomerAuthSource(latency: Duration.zero);
  Future<bool> login(
    LenlabStore store, [
    String email = 'nguyenvan.a@example.com',
  ]) => store.signIn(identity: email, password: 'mock');

  test('demo identities are stable across email and phone aliases', () async {
    final auth = source();
    final a = await auth.signIn(
      identity: ' NGUYENVAN.A@example.com ',
      password: 'mock',
    );
    final phone = await auth.signIn(
      identity: '0901234567',
      password: 'different',
    );
    final b = await auth.signIn(
      identity: mockCustomerB.email,
      password: 'mock',
    );
    expect(a.id, mockCustomerAId);
    expect(phone.id, a.id);
    expect(b.id, isNot(a.id));
    expect(LenlabStore.fixtureOwnerId, mockCustomerAId);
  });

  test(
    'unknown login does not implicitly register and validates credentials',
    () async {
      final auth = source();
      for (final entry in [
        ('new@example.com', 'mock'),
        ('bad', 'mock'),
        (mockCustomerA.email, ''),
      ]) {
        await expectLater(
          auth.signIn(identity: entry.$1, password: entry.$2),
          throwsA(isA<RepositoryException>()),
        );
      }
    },
  );

  test(
    'registration creates a distinct RAM identity and can log in again',
    () async {
      final auth = source();
      final account = await auth.register(
        name: ' New Customer ',
        identity: 'NEW@example.com',
        password: 'mock',
      );
      expect(account.id, isNot(mockCustomerA.id));
      expect(account.id, isNot(mockCustomerB.id));
      expect(account.name, 'New Customer');
      expect(
        (await auth.signIn(identity: 'new@example.com', password: 'other')).id,
        account.id,
      );
      await expectLater(
        auth.register(
          name: 'Duplicate',
          identity: 'NEW@example.com',
          password: 'mock',
        ),
        throwsA(isA<RepositoryException>()),
      );
      final phone = await auth.register(
        name: 'Phone',
        identity: '0912345678',
        password: 'mock',
      );
      expect(phone.id, isNot(account.id));
      expect(phone.phone, '0912345678');
    },
  );

  test('injected identities need unique stable IDs and login aliases', () {
    expect(
      () => MockCustomerAuthSource(accounts: [mockCustomerA, mockCustomerA]),
      throwsArgumentError,
    );
    expect(
      () => MockCustomerAuthSource(
        accounts: [
          mockCustomerA,
          CustomerIdentity(
            id: 'other',
            name: 'Other',
            email: mockCustomerA.email,
          ),
        ],
      ),
      throwsArgumentError,
    );
    expect(
      () => MockCustomerAuthSource(
        accounts: [
          const CustomerIdentity(
            id: '',
            name: 'Invalid',
            email: 'a@example.com',
          ),
        ],
      ),
      throwsArgumentError,
    );
  });

  test('register and login use separate operations; failed registration is retryable', () async {
    final operations = <String>[];
    var fail = true;
    final auth = MockCustomerAuthSource(
      operation: (operation) async {
        operations.add(operation);
        if (fail) throw const RepositoryException('offline');
      },
    );
    await expectLater(
      auth.register(name: 'New', identity: 'new@example.com', password: 'mock'),
      throwsA(isA<RepositoryException>()),
    );
    fail = false;
    final created = await auth.register(
      name: 'New',
      identity: 'new@example.com',
      password: 'mock',
    );
    expect(
      (await auth.signIn(identity: created.email, password: 'mock')).id,
      created.id,
    );
    expect(operations, ['register', 'register', 'login']);
  });

  test('concurrent registration cannot create duplicate aliases', () async {
    final auth = source();
    final first = auth.register(
      name: 'First',
      identity: 'new@example.com',
      password: 'mock',
    );
    final second = auth.register(
      name: 'Second',
      identity: 'NEW@example.com',
      password: 'mock',
    );
    final failure = expectLater(second, throwsA(isA<RepositoryException>()));
    expect((await first).name, 'First');
    await failure;
  });

  test('generation changes on login logout and same-user login', () async {
    final store = LenlabStore(authSource: source());
    addTearDown(store.dispose);
    expect(store.userId, isNull);
    expect(store.sessionGeneration, 0);
    final guest = store.captureSession();
    expect(await login(store), isTrue);
    final a = store.captureSession();
    expect(store.userId, mockCustomerA.id);
    expect(store.isCurrentSession(guest), isFalse);
    store.logout();
    expect(store.signedIn, isFalse);
    expect(store.isCurrentSession(a), isFalse);
    await login(store);
    expect(store.userId, a.userId);
    expect(store.sessionGeneration, greaterThan(a.generation));
    expect(store.isCurrentSession(a), isFalse);
    await login(store, mockCustomerB.email);
    expect(store.currentUser, mockCustomerB);
  });

  test('failed login preserves guest cart and current identity', () async {
    final store = LenlabStore(authSource: source());
    addTearDown(store.dispose);
    final cart = List.of(store.cart);
    await expectLater(
      login(store, 'unknown@example.com'),
      throwsA(isA<RepositoryException>()),
    );
    expect(store.cart, orderedEquals(cart));
    expect(store.sessionGeneration, 0);
    await login(store);
    final stamp = store.captureSession();
    await expectLater(
      login(store, 'unknown@example.com'),
      throwsA(isA<RepositoryException>()),
    );
    expect(store.isCurrentSession(stamp), isTrue);
  });

  test('latest login wins and stale error is ignored', () async {
    final auth = PendingAuth();
    final store = LenlabStore(authSource: auth);
    addTearDown(store.dispose);
    final old = login(store);
    final recent = login(store, mockCustomerB.email);
    auth.requests[1].complete(mockCustomerB);
    expect(await recent, isTrue);
    auth.requests[0].completeError(const RepositoryException('late failure'));
    expect(await old, isFalse);
    expect(store.userId, mockCustomerB.id);
  });

  test(
    'logout invalidates pending login without resurrecting session',
    () async {
      final auth = PendingAuth();
      final store = LenlabStore(authSource: auth);
      addTearDown(store.dispose);
      final request = login(store);
      store.logout();
      auth.requests.single.complete(mockCustomerA);
      expect(await request, isFalse);
      expect(store.userId, isNull);
    },
  );

  test('A logout A rejects a request from the earlier generation', () async {
    final auth = PendingAuth();
    final store = LenlabStore(authSource: auth);
    addTearDown(store.dispose);
    final first = login(store);
    auth.requests[0].complete(mockCustomerA);
    await first;
    final stale = login(store, mockCustomerB.email);
    store.logout();
    final fresh = login(store);
    auth.requests[2].complete(mockCustomerA);
    await fresh;
    final stamp = store.captureSession();
    auth.requests[1].complete(mockCustomerB);
    expect(await stale, isFalse);
    expect(store.isCurrentSession(stamp), isTrue);
  });

  test('disposed auth form cannot apply success', () async {
    final auth = PendingAuth();
    final store = LenlabStore(authSource: auth);
    addTearDown(store.dispose);
    var mounted = true;
    final request = store.signIn(
      identity: mockCustomerA.email,
      password: 'mock',
      canApply: () => mounted,
    );
    mounted = false;
    auth.requests.single.complete(mockCustomerA);
    expect(await request, isFalse);
    expect(store.signedIn, isFalse);
  });

  test(
    'disposing store ignores late auth without notifying listeners',
    () async {
      final auth = PendingAuth();
      final store = LenlabStore(authSource: auth);
      var notifications = 0;
      store.addListener(() => notifications++);
      final request = login(store);
      store.dispose();
      auth.requests.single.complete(mockCustomerA);
      expect(await request, isFalse);
      expect(notifications, 0);
    },
  );

  test(
    'store registration activates its own identity instead of demo A',
    () async {
      final store = LenlabStore(authSource: source());
      addTearDown(store.dispose);
      expect(
        await store.register(
          name: 'Independent',
          identity: 'new@example.com',
          password: 'mock',
        ),
        isTrue,
      );
      expect(store.currentUser!.name, 'Independent');
      expect(store.userId, isNot(LenlabStore.fixtureOwnerId));
    },
  );
}
