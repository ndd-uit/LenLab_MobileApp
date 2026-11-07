import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_customer/app/customer_app.dart';
import 'package:lenlab_customer/app/auth_return_intent.dart';
import 'package:lenlab_customer/app/customer_session_gate.dart';
import 'package:lenlab_customer/app/customer_scope.dart';
import 'package:lenlab_customer/features/auth/presentation/auth_page.dart';
import 'package:lenlab_customer/features/checkout/presentation/address_page.dart';
import 'package:lenlab_customer/features/checkout/presentation/payment_method_page.dart';
import 'package:lenlab_customer/features/orders/presentation/order_detail_page.dart';
import 'package:lenlab_customer/features/profile/presentation/profile_editor_page.dart';
import 'package:lenlab_customer/features/address_book/presentation/address_editor_page.dart';
import 'package:lenlab_customer/features/profile/data/profile_source.dart';
import 'package:lenlab_customer/features/address_book/data/address_book_source.dart';
import 'package:lenlab_customer/features/address_book/data/address_book_actions.dart';
import 'package:lenlab_customer/features/address_book/data/address_editor_source.dart';
import 'package:lenlab_customer/features/profile/data/profile_editor_source.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

void main() {
  LenlabStore sample() {
    final repo = MockLenlabRepository(latency: Duration.zero);
    final s = LenlabStore(repository: repo);
    s.addToCart(repo.catalog.firstWhere((p) => p.id == 'sheep'), 1, 'Guest');
    return s;
  }

  Future<void> open(WidgetTester tester, LenlabStore s, String route) async {
    tester.view.physicalSize = const Size(430, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(CustomerApp(store: s, initialRoute: route));
    await tester.pumpAndSettle();
  }

  NavigatorState nav(WidgetTester t) =>
      t.state<NavigatorState>(find.byType(Navigator).first);
  Future<void> authenticate(
    WidgetTester t, {
    bool register = false,
    String? identity,
  }) async {
    final values = register
        ? [
            'New Customer',
            identity ?? 'new@example.com',
            'mockpass',
            'mockpass',
          ]
        : [identity ?? mockCustomerA.email, 'mockpass'];
    for (var i = 0; i < values.length; i++) {
      final field = find.byType(TextFormField).at(i);
      await t.ensureVisible(field);
      await t.enterText(field, values[i]);
    }
    final button = find.widgetWithText(
      ElevatedButton,
      register ? 'Đăng ký' : 'Đăng nhập',
    );
    await t.ensureVisible(button);
    await t.tap(button);
    await t.pumpAndSettle();
  }

  String? route(WidgetTester t) =>
      ModalRoute.of(t.element(find.byType(Scaffold).last))!.settings.name;

  for (final target in AuthReturnIntent.privateRoutes.where(
    (r) => r != '/support',
  )) {
    testWidgets(
      'Guest direct $target shows Auth without private data; Back stays public',
      (t) async {
        final s = sample();
        addTearDown(s.dispose);
        await open(t, s, target);
        expect(find.byType(AuthPage), findsOneWidget);
        expect(find.text(mockCustomerA.email), findsNothing);
        expect(find.textContaining('WOOL-8823'), findsNothing);
        expect(s.signedIn, isFalse);
        expect(s.orders.length, 0);
        await t.binding.handlePopRoute();
        await t.pumpAndSettle();
        expect(find.byType(AuthPage), findsNothing);
        expect(s.signedIn, isFalse);
        expect(route(t), '/');
      },
    );
  }

  testWidgets(
    'MaterialPageRoute checkout, detail and editors cannot bypass the guard',
    (t) async {
      final s = sample();
      addTearDown(s.dispose);
      await open(t, s, '/');
      for (final page in <Widget>[
        const AddressPage(),
        const PaymentMethodPage(),
        const OrderDetailPage(orderId: 'WOOL-8823'),
        const ProfileEditorPage(),
        const AddressEditorPage(),
      ]) {
        nav(t).push(MaterialPageRoute<void>(builder: (_) => page));
        await t.pumpAndSettle();
        expect(find.byType(AuthPage), findsOneWidget);
        expect(find.text(mockCustomerA.email), findsNothing);
        nav(t).pop();
        await t.pumpAndSettle();
      }
    },
  );

  for (final register in [false, true]) {
    testWidgets(
      'Cart checkout Auth ${register ? 'register' : 'login'} returns to cart without submitting',
      (t) async {
        final s = sample();
        addTearDown(s.dispose);
        final cart = List.of(s.cart);
        await open(t, s, '/cart');
        await t.tap(find.text('Để sau'));
        await t.pumpAndSettle();
        await t.tap(find.widgetWithText(ElevatedButton, 'Thanh toán'));
        await t.pumpAndSettle();
        expect(find.byType(AuthPage), findsOneWidget);
        if (register) {
          final layout = find.byType(AuthPage);
          final registerButton = find
              .descendant(of: layout, matching: find.byType(TextButton))
              .last;
          await t.ensureVisible(registerButton);
          await t.tap(registerButton);
          await t.pumpAndSettle();
        }
        await authenticate(t, register: register);
        expect(route(t), '/cart');
        expect(s.signedIn, isTrue);
        expect(
          s.pendingGuestCarts.single.map((l) => l.product.id),
          cart.map((l) => l.product.id),
        );
        expect(s.cart.length, register ? 0 : 2);
        expect(s.deliveryAddress, isNull);
        expect(s.orders.length, register ? 0 : 4);
        expect(s.isSubmittingCod, isFalse);
        await t.binding.handlePopRoute();
        await t.pumpAndSettle();
        expect(route(t), '/');
      },
    );
  }

  testWidgets(
    'failed or cancelled login preserves guest cart; fresh auth has no stale intent',
    (t) async {
      final s = sample();
      addTearDown(s.dispose);
      final cart = List.of(s.cart);
      await open(t, s, '/cart');
      await t.tap(find.text('Để sau'));
      await t.pumpAndSettle();
      nav(t).pushNamed('/checkout');
      await t.pumpAndSettle();
      await authenticate(t, identity: 'unknown@example.com');
      expect(find.byType(AuthPage), findsOneWidget);
      expect(s.cart, orderedEquals(cart));
      expect(s.signedIn, isFalse);
      nav(t).pop();
      await t.pumpAndSettle();
      nav(t).pushNamed('/login');
      await t.pumpAndSettle();
      await authenticate(t);
      expect(route(t), '/');
      expect(s.cart.length, 2);
      expect(
        s.pendingGuestCarts.single.single.product.id,
        cart.single.product.id,
      );
      expect(s.orders.length, 4);
    },
  );

  testWidgets(
    'login-register-login links preserve intent to valid private route',
    (t) async {
      final s = sample();
      addTearDown(s.dispose);
      await open(t, s, '/orders');
      final intent = t.widget<AuthPage>(find.byType(AuthPage)).returnIntent;
      // Invoke the actual layout callbacks; route settings must carry the same intent.
      final registerLink = find.byType(TextButton).last;
      await t.ensureVisible(registerLink);
      await t.tap(registerLink);
      await t.pumpAndSettle();
      expect(
        t.widget<AuthPage>(find.byType(AuthPage)).returnIntent,
        same(intent),
      );
      final loginLink = find.byType(TextButton).last;
      await t.ensureVisible(loginLink);
      await t.tap(loginLink);
      await t.pumpAndSettle();
      await authenticate(t);
      expect(route(t), '/orders');
      expect(find.byType(AuthPage), findsNothing);
    },
  );

  testWidgets(
    'logout removes visible private content and Back cannot restore it',
    (t) async {
      final s = sample();
      addTearDown(s.dispose);
      await t.runAsync(
        () => s.signIn(identity: mockCustomerA.email, password: 'mock'),
      );
      await open(t, s, '/profile');
      expect(find.text(s.profile.email), findsOneWidget);
      s.logout();
      await t.pumpAndSettle();
      expect(find.text(mockCustomerA.email), findsNothing);
      expect(find.byType(AuthPage), findsOneWidget);
      await t.binding.handlePopRoute();
      await t.pumpAndSettle();
      expect(route(t), '/');
    },
  );

  testWidgets(
    'Guest profile and address source calls reject without navigation',
    (t) async {
      final s = sample();
      addTearDown(s.dispose);
      await expectLater(
        MockProfileSource(s).load(),
        throwsA(isA<RepositoryException>()),
      );
      await expectLater(
        MockAddressBookSource(s).load(),
        throwsA(isA<RepositoryException>()),
      );
      await expectLater(
        MockAddressEditorSource(s)
            .save(const Address(ownerId: mockCustomerAId)),
        throwsA(isA<RepositoryException>()),
      );
      await expectLater(
        MockAddressBookActions(s)
            .setDefault(const Address(ownerId: mockCustomerAId)),
        throwsA(isA<RepositoryException>()),
      );
      await expectLater(
        MockProfileEditorSource(s).save(
          name: 'New',
          phone: '0901234567',
          gender: 'Nam',
          birthday: '01/01/1995',
        ),
        throwsA(isA<RepositoryException>()),
      );
      expect(s.profile.name, isEmpty);
      expect(s.addresses, isEmpty);
    },
  );

  for (final target in [
    '/checkout',
    '/payment-method',
    '/bank-transfer',
    '/cod-confirmation',
  ]) {
    testWidgets('login from direct $target returns to cart for review only', (
      t,
    ) async {
      final s = sample();
      addTearDown(s.dispose);
      await open(t, s, target);
      await authenticate(t);
      expect(route(t), '/cart');
      expect(s.orders.length, 4);
      expect(s.checkoutNote, isEmpty);
      expect(s.cart.length, 2);
      expect(s.bankTransferReference, isNull);
      expect(s.checkoutPaymentMethod, CheckoutPaymentMethod.cod);
    });
  }

  testWidgets('private order detail return retains only its string ID', (
    t,
  ) async {
    final s = sample();
    addTearDown(s.dispose);
    await open(t, s, '/');
    nav(t).pushNamed('/order-detail', arguments: 'WOOL-8805');
    await t.pumpAndSettle();
    await authenticate(t);
    expect(route(t), '/order-detail');
    expect(
      t.widget<OrderDetailPage>(find.byType(OrderDetailPage)).orderId,
      'WOOL-8805',
    );
    expect(find.byType(AuthPage), findsNothing);
  });

  testWidgets('intent from an older Guest generation is discarded', (t) async {
    final s = sample();
    addTearDown(s.dispose);
    await open(t, s, '/orders');
    final intent = t.widget<AuthPage>(find.byType(AuthPage)).returnIntent;
    nav(t).pushReplacementNamed('/login', arguments: intent);
    await t.pumpAndSettle();
    s.logout();
    await t.pumpAndSettle();
    await authenticate(t);
    expect(route(t), '/');
    expect(s.orders.length, 4);
  });

  testWidgets(
    'Auth completion never mounts the blocked checkout behind the transition',
    (t) async {
      final s = sample();
      addTearDown(s.dispose);
      var privateBuilds = 0;
      await t.pumpWidget(
        CustomerScope(
          store: s,
          child: MaterialApp(
            theme: P2.theme(),
            initialRoute: '/blocked',
            routes: {
              '/': (_) => const Scaffold(body: Text('Home')),
              '/cart': (_) => const Scaffold(body: Text('Cart destination')),
              '/blocked': (_) => CustomerSessionGate(
                route: '/checkout',
                builder: (_) {
                  privateBuilds++;
                  return const Scaffold(body: Text('Private checkout'));
                },
              ),
            },
          ),
        ),
      );
      await t.pumpAndSettle();
      await authenticate(t);
      expect(find.text('Cart destination'), findsOneWidget);
      expect(privateBuilds, 0);
      expect(s.orders.length, 4);
    },
  );
}
