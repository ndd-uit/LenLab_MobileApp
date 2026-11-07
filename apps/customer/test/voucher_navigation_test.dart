import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_customer/app/customer_app.dart';
import 'package:lenlab_customer/features/auth/presentation/auth_page.dart';
import 'package:lenlab_customer/features/cart/presentation/cart_page.dart';
import 'package:lenlab_customer/features/cart/presentation/widgets/cart_voucher.dart';
import 'package:lenlab_customer/features/vouchers/presentation/voucher_page.dart';
import 'package:lenlab_customer/features/vouchers/presentation/widgets/voucher_card.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

LenlabStore sample({bool guest = false}) {
  final s = LenlabStore(
    repository: MockLenlabRepository(latency: Duration.zero),
    authSource: MockCustomerAuthSource(latency: Duration.zero),
  );
  if (!guest) s.signedIn = true;
  return s;
}

Future<void> open(
  WidgetTester t,
  LenlabStore s, [
  String route = '/cart',
]) async {
  t.view.physicalSize = const Size(430, 1600);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  addTearDown(s.dispose);
  await t.pumpWidget(CustomerApp(store: s, initialRoute: route));
  await t.pumpAndSettle();
}

NavigatorState nav(WidgetTester t) =>
    t.state<NavigatorState>(find.byType(Navigator));

Future<void> wallet(WidgetTester t) async {
  await t.ensureVisible(find.byType(CartVoucher));
  await t.tap(find.byType(CartVoucher));
  await t.pumpAndSettle();
}

Finder card(String id) => find.byWidgetPredicate(
  (widget) => widget is VoucherCard && widget.voucher.id == id,
);

Future<void> choose(WidgetTester t, String id) async {
  final button = find.descendant(
    of: card(id),
    matching: find.text('Dùng ngay'),
  );
  await t.ensureVisible(button);
  await t.tap(button);
  await t.pumpAndSettle();
}

Map<String, Object?> snapshot(LenlabStore s) => {
  'lines': s.cart.map((l) => (l.key, l.quantity, l.product.price)).toList(),
  'selected': s.checkoutLines.map((l) => l.key).toList(),
  'address': s.deliveryAddress,
  'note': s.checkoutNote,
  'payment': s.checkoutPaymentMethod,
  'coupon': s.coupon,
  'totals': [s.checkoutSubtotal, s.checkoutDiscount, s.discount],
  'orders': s.orders.map((o) => o.id).toList(),
};

Future<void> login(WidgetTester t, String identity) async {
  await t.enterText(find.byType(TextFormField).first, identity);
  await t.enterText(find.byType(TextFormField).at(1), 'mockpass');
  final button = find.widgetWithText(ElevatedButton, 'Đăng nhập');
  await t.ensureVisible(button);
  await t.tap(button);
  await t.pumpAndSettle();
}

void main() {
  testWidgets(
    'Cart wallet Cart preserves route, cart, draft, coupon and totals',
    (t) async {
      final s = sample();
      s.coupon = 'LEN50';
      s.toggleCartLine(s.cart.first);
      s.deliveryAddress = s.addresses.single;
      s.checkoutNote = 'Keep checkout draft';
      final before = snapshot(s);
      await open(t, s);
      final cartState = t.state(find.byType(CartPage));
      await wallet(t);
      expect(find.byType(VoucherPage), findsOneWidget);
      await choose(t, 'p2-len20');
      expect(find.byType(CartPage), findsOneWidget);
      expect(t.state(find.byType(CartPage)), same(cartState));
      expect(s.voucherCandidate?.campaignId, 'p2-len20');
      expect(snapshot(s), before);
      expect(find.text('Áp dụng thành công'), findsNothing);
      expect(s.isSubmittingCod, isFalse);
      await t.binding.handlePopRoute();
      await t.pumpAndSettle();
      expect(find.byType(VoucherPage), findsNothing);
      expect(find.byType(CartPage), findsNothing);
    },
  );

  testWidgets(
    'no-code campaign selects by exact ID without code or evaluation',
    (t) async {
      final s = sample();
      await open(t, s);
      await wallet(t);
      final gift = t.widget<VoucherCard>(card('p2-gift'));
      expect(gift.voucher.code, isNull);
      await choose(t, 'p2-gift');
      expect(s.voucherCandidate?.campaignId, 'p2-gift');
      expect(s.coupon, isEmpty);
      expect(s.checkoutDiscount, 0);
      expect(find.byType(CartPage), findsOneWidget);
      expect(s.orders, hasLength(4));
    },
  );

  testWidgets('zero selected lines returns to Cart without selecting any', (
    t,
  ) async {
    final s = sample()..coupon = 'LEN50';
    for (final line in s.cart) {
      s.toggleCartLine(line);
    }
    final before = snapshot(s);
    await open(t, s);
    await wallet(t);
    await choose(t, 'p2-len20');
    expect(s.voucherCandidate?.campaignId, 'p2-len20');
    expect(s.checkoutLines, isEmpty);
    expect(s.checkoutDiscount, 0);
    expect(snapshot(s), before);
    expect(find.byType(CartPage), findsOneWidget);
  });

  testWidgets('system and header Back cancel without replacing prior intent', (
    t,
  ) async {
    final s = sample()..coupon = 'LEN50';
    s.selectVoucherCandidate('previous-intent', session: s.captureSession());
    final previous = s.voucherCandidate;
    final before = snapshot(s);
    await open(t, s);
    await wallet(t);
    await t.enterText(find.byType(TextField), 'unverified-draft');
    await t.binding.handlePopRoute();
    await t.pumpAndSettle();
    expect(s.voucherCandidate, same(previous));
    await wallet(t);
    expect(
      t.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
    await t.tap(find.byTooltip('Quay lại'));
    await t.pumpAndSettle();
    expect(s.voucherCandidate, same(previous));
    expect(snapshot(s), before);
    expect(find.byType(CartPage), findsOneWidget);
  });

  testWidgets('Guest public wallet and cancelled auth preserve Guest cart', (
    t,
  ) async {
    final s = sample(guest: true);
    final repo = s.repository as MockLenlabRepository;
    s.addToCart(repo.catalog.firstWhere((p) => p.id == 'carrot'), 2, 'Guest');
    s.dismissGuestCartPrompt();
    final before = snapshot(s);
    await open(t, s);
    await wallet(t);
    expect(find.byType(AuthPage), findsNothing);
    expect(find.text('LEN20'), findsOneWidget);
    expect(s.voucherCandidate, isNull);
    nav(t).pushNamed('/login');
    await t.pumpAndSettle();
    await login(t, 'unknown@example.com');
    expect(find.byType(AuthPage), findsOneWidget);
    expect(snapshot(s), before);
    await t.binding.handlePopRoute();
    await t.pumpAndSettle();
    expect(find.byType(VoucherPage), findsOneWidget);
    await t.binding.handlePopRoute();
    await t.pumpAndSettle();
    expect(find.byType(CartPage), findsOneWidget);
    expect(snapshot(s), before);
  });

  testWidgets(
    'Guest login opens wallet without replaying Use or creating order',
    (t) async {
      final s = sample(guest: true);
      final repo = s.repository as MockLenlabRepository;
      s.addToCart(repo.catalog.firstWhere((p) => p.id == 'carrot'), 1, 'Guest');
      s.dismissGuestCartPrompt();
      await open(t, s);
      await wallet(t);
      nav(t).pushNamed('/login');
      await t.pumpAndSettle();
      await login(t, mockCustomerA.email);
      expect(find.byType(VoucherPage), findsNothing);
      expect(s.voucherCandidate, isNull);
      expect(s.coupon, isEmpty);
      expect(s.orders, hasLength(4));
      expect(s.pendingGuestCarts.single.single.variant, 'Guest');
      expect(s.cart, hasLength(2));
      nav(t).pushNamed('/vouchers');
      await t.pumpAndSettle();
      await choose(t, 'p2-len20');
      expect(find.byType(CartPage), findsOneWidget);
      expect(s.voucherCandidate?.session.userId, mockCustomerAId);
      expect(s.orders, hasLength(4));
    },
  );

  testWidgets('stale Use before rebuild cannot select or navigate B or new A', (
    t,
  ) async {
    final s = sample();
    await open(t, s);
    await wallet(t);
    final oldUse = t.widget<VoucherCard>(card('p2-len20')).onUse;
    await t.runAsync(
      () => s.signIn(identity: mockCustomerB.email, password: 'mock'),
    );
    oldUse();
    expect(s.voucherCandidate, isNull);
    await t.pumpAndSettle();
    expect(find.byType(VoucherPage), findsOneWidget);
    expect(find.text('Đã dùng'), findsNothing);
    final useB = t.widget<VoucherCard>(card('p2-len20')).onUse;
    s.logout();
    useB();
    expect(s.voucherCandidate, isNull);
    await t.pumpAndSettle();
    expect(find.byType(AuthPage), findsNothing);
    expect(find.byType(VoucherPage), findsOneWidget);
    await t.runAsync(
      () => s.signIn(identity: mockCustomerA.email, password: 'mock'),
    );
    oldUse();
    useB();
    await t.pumpAndSettle();
    expect(s.voucherCandidate, isNull);
    expect(s.orders, hasLength(4));
    expect(t.takeException(), isNull);
  });

  testWidgets(
    'covered and disposed wallet callbacks do not replay navigation',
    (t) async {
      final s = sample();
      await open(t, s);
      await wallet(t);
      final oldUse = t.widget<VoucherCard>(card('p2-len20')).onUse;
      nav(t).pushNamed('/about');
      await t.pumpAndSettle();
      oldUse();
      expect(s.voucherCandidate, isNull);
      nav(t).pop();
      await t.pumpAndSettle();
      nav(t).pop();
      await t.pumpAndSettle();
      oldUse();
      expect(s.voucherCandidate, isNull);
      expect(find.byType(CartPage), findsOneWidget);
      expect(t.takeException(), isNull);
    },
  );

  testWidgets('Profile wallet Use falls back to existing Cart route', (
    t,
  ) async {
    final s = sample();
    final before = snapshot(s);
    await open(t, s, '/profile');
    await t.tap(find.text('Voucher của tôi'));
    await t.pumpAndSettle();
    await choose(t, 'p2-len20');
    expect(find.byType(CartPage), findsOneWidget);
    expect(snapshot(s), before);
    expect(s.voucherCandidate?.campaignId, 'p2-len20');
  });

  testWidgets(
    'manual input stays unverified; loading error retry preserves Cart',
    (t) async {
      final s = sample()..coupon = 'LEN50';
      (s.repository as MockLenlabRepository).failNext('vouchers');
      final before = snapshot(s);
      await open(t, s);
      await wallet(t);
      expect(find.text('Không thể tải voucher'), findsOneWidget);
      await t.tap(find.text('Thử lại'));
      await t.pumpAndSettle();
      await t.enterText(find.byType(TextField), ' LEN50 ');
      await t.tap(find.text('Áp dụng'));
      await t.pumpAndSettle();
      expect(s.voucherCandidate, isNull);
      expect(snapshot(s), before);
      expect(find.text('Áp dụng thành công'), findsNothing);
      await t.binding.handlePopRoute();
      await t.pumpAndSettle();
      expect(snapshot(s), before);
      expect(t.takeException(), isNull);
    },
  );
}
