import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_customer/app/customer_scope.dart';
import 'package:lenlab_customer/features/auth/presentation/auth_page.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

class DeferredAuth implements CustomerAuthSource {
  final result = Completer<CustomerIdentity>();
  int logins = 0, registrations = 0;
  @override
  Future<CustomerIdentity> signIn({
    required String identity,
    required String password,
  }) {
    logins++;
    return result.future;
  }

  @override
  Future<CustomerIdentity> register({
    required String name,
    required String identity,
    required String password,
  }) {
    registrations++;
    return result.future;
  }
}

void main() {
  Future<void> open(
    WidgetTester tester,
    LenlabStore store, {
    bool register = false,
  }) async {
    tester.view.physicalSize = const Size(430, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      CustomerScope(
        store: store,
        child: MaterialApp(
          theme: P2.theme(),
          initialRoute: '/auth',
          routes: {
            '/auth': (_) => AuthPage(register: register),
            '/': (_) => const Scaffold(body: Text('Home destination')),
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    final values = register
        ? ['New Customer', 'new@example.com', 'mockpass', 'mockpass']
        : [mockCustomerB.email, 'mockpass'];
    for (var i = 0; i < values.length; i++) {
      final field = find.byType(TextFormField).at(i);
      await tester.ensureVisible(field);
      await tester.enterText(field, values[i]);
    }
    final submit = find.widgetWithText(
      ElevatedButton,
      register ? 'Đăng ký' : 'Đăng nhập',
    );
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pump();
  }

  testWidgets(
    'login uses injected identity and navigates only after completion',
    (tester) async {
      final auth = DeferredAuth();
      final store = LenlabStore(authSource: auth);
      addTearDown(store.dispose);
      final cart = List.of(store.cart);
      final orderCount = store.orders.length;
      await open(tester, store);
      expect(auth.logins, 1);
      expect(auth.registrations, 0);
      expect(store.signedIn, isFalse);
      auth.result.complete(mockCustomerB);
      await tester.pumpAndSettle();
      expect(store.userId, mockCustomerB.id);
      expect(store.cart, orderedEquals(cart));
      expect(store.orders.length, orderCount);
      expect(find.text('Home destination'), findsOneWidget);
    },
  );

  testWidgets('registration invokes its separate contract and identity', (
    tester,
  ) async {
    final auth = DeferredAuth();
    final store = LenlabStore(authSource: auth);
    addTearDown(store.dispose);
    await open(tester, store, register: true);
    expect(auth.logins, 0);
    expect(auth.registrations, 1);
    auth.result.complete(
      const CustomerIdentity(
        id: 'registered-new',
        name: 'New Customer',
        email: 'new@example.com',
      ),
    );
    await tester.pumpAndSettle();
    expect(store.userId, 'registered-new');
    expect(store.currentUser!.name, 'New Customer');
    expect(find.text('Home destination'), findsOneWidget);
  });

  testWidgets(
    'disposed login form cannot log in or navigate after late success',
    (tester) async {
      final auth = DeferredAuth();
      final store = LenlabStore(authSource: auth);
      addTearDown(store.dispose);
      await open(tester, store);
      await tester.pumpWidget(const MaterialApp(home: Text('Another screen')));
      await tester.pumpAndSettle();
      auth.result.complete(mockCustomerB);
      await tester.pumpAndSettle();
      expect(store.signedIn, isFalse);
      expect(find.text('Another screen'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('logout during login prevents late success navigation', (
    tester,
  ) async {
    final auth = DeferredAuth();
    final store = LenlabStore(authSource: auth);
    addTearDown(store.dispose);
    await open(tester, store);
    store.logout();
    auth.result.complete(mockCustomerB);
    await tester.pumpAndSettle();
    expect(store.userId, isNull);
    expect(find.byType(AuthPage), findsOneWidget);
    expect(find.text('Home destination'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
