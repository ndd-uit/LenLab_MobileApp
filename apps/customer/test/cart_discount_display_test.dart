import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_customer/app/customer_app.dart';
import 'package:lenlab_customer/features/cart/presentation/widgets/cart_summary.dart';
import 'package:lenlab_customer/features/cart/presentation/widgets/cart_voucher.dart';
import 'package:lenlab_customer/features/checkout/presentation/widgets/order_review_totals.dart';
import 'package:lenlab_customer/features/checkout/presentation/widgets/payment_method_footer.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

LenlabStore sample({bool coupon = true}) {
  final s = LenlabStore(
    repository: MockLenlabRepository(latency: Duration.zero),
  )..signedIn = true;
  s.cart.clear();
  if (coupon) s.coupon = 'LEN50';
  s.deliveryAddress = s.addresses.single;
  return s;
}

void add(LenlabStore s, String id, [int quantity = 1]) {
  final repo = s.repository as MockLenlabRepository;
  s.addToCart(repo.catalog.singleWhere((p) => p.id == id), quantity, 'test');
}

Future<void> open(WidgetTester t, LenlabStore s) async {
  t.view.physicalSize = const Size(430, 1800);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  addTearDown(s.dispose);
  await t.pumpWidget(CustomerApp(store: s, initialRoute: '/cart'));
  await t.pumpAndSettle();
}

void expectCart(
  WidgetTester t, {
  required int subtotal,
  required int discount,
}) {
  final summary = t.widget<CartSummary>(find.byType(CartSummary));
  expect(summary.subtotal, subtotal);
  expect(summary.discount, discount);
  expect(
    find.descendant(
      of: find.byType(CartVoucher),
      matching: find.text(
        discount > 0 ? 'LEN50 · Giảm ${money(discount)}' : 'Chọn mã giảm giá',
      ),
    ),
    findsOneWidget,
  );
  expect(
    find.descendant(
      of: find.byType(CartSummary),
      matching: find.text('${discount > 0 ? '-' : ''}${money(discount)}'),
    ),
    findsWidgets,
  );
}

Future<void> expectCheckout(
  WidgetTester t, {
  required int subtotal,
  required int discount,
}) async {
  final nav = t.state<NavigatorState>(find.byType(Navigator));
  nav.pushNamed('/order-review');
  await t.pumpAndSettle();
  final totals = t
      .widget<OrderReviewPaymentDetails>(find.byType(OrderReviewPaymentDetails))
      .totals;
  expect(totals.subtotal, subtotal);
  expect(totals.discount, discount);
  expect(totals.shipping, 30000);
  expect(totals.total, subtotal - discount + 30000);
  nav.pushNamed('/payment-method');
  await t.pumpAndSettle();
  expect(
    t.widget<PaymentMethodFooter>(find.byType(PaymentMethodFooter)).total,
    subtotal - discount + 30000,
  );
  expect(t.takeException(), isNull);
}

void main() {
  testWidgets(
    'eligible selected lines agree across voucher summary and checkout',
    (t) async {
      final s = sample();
      add(s, 'carrot', 2);
      await open(t, s);
      expectCart(t, subtotal: 90000, discount: 50000);
      await expectCheckout(t, subtotal: 90000, discount: 50000);
    },
  );

  testWidgets(
    'deselecting eligible line leaves selected subtotal below threshold',
    (t) async {
      final s = sample();
      add(s, 'carrot');
      add(s, 'sheep');
      await open(t, s);
      expectCart(t, subtotal: 295000, discount: 50000);
      await t.tap(find.byKey(ValueKey('cart-select-${s.cart.last.key}')));
      await t.pumpAndSettle();
      expect(
        s.discount,
        50000,
      ); // Whole-cart discount must not drive the label.
      expectCart(t, subtotal: 45000, discount: 0);
      await expectCheckout(t, subtotal: 45000, discount: 0);
    },
  );

  testWidgets(
    'quantity changes cross the discount threshold in both directions',
    (t) async {
      final s = sample();
      add(s, 'carrot');
      await open(t, s);
      expectCart(t, subtotal: 45000, discount: 0);
      s.changeQuantity(s.cart.single, 1);
      await t.pumpAndSettle();
      expectCart(t, subtotal: 90000, discount: 50000);
      s.changeQuantity(s.cart.single, -1);
      await t.pumpAndSettle();
      expectCart(t, subtotal: 45000, discount: 0);
    },
  );

  testWidgets(
    'no selected lines never advertise a discount and disable checkout',
    (t) async {
      final s = sample();
      add(s, 'sheep');
      await open(t, s);
      s.toggleCartLine(s.cart.single);
      await t.pumpAndSettle();
      expect(s.discount, 50000);
      expectCart(t, subtotal: 0, discount: 0);
      expect(
        t
            .widget<ElevatedButton>(
              find.widgetWithText(ElevatedButton, 'Thanh toán'),
            )
            .onPressed,
        isNull,
      );
    },
  );

  testWidgets(
    'no coupon gives no discount even with eligible selected subtotal',
    (t) async {
      final s = sample(coupon: false);
      add(s, 'sheep');
      await open(t, s);
      expect(s.coupon, isEmpty);
      expectCart(t, subtotal: 250000, discount: 0);
      await expectCheckout(t, subtotal: 250000, discount: 0);
    },
  );

  testWidgets('removing eligible line updates voucher and summary together', (
    t,
  ) async {
    final s = sample();
    add(s, 'carrot');
    add(s, 'sheep');
    await open(t, s);
    s.removeFromCart(s.cart.last);
    await t.pumpAndSettle();
    expectCart(t, subtotal: 45000, discount: 0);
    await expectCheckout(t, subtotal: 45000, discount: 0);
  });

  testWidgets(
    'notified cart price changes use the same selected discount at the boundary',
    (t) async {
      final s = sample();
      add(s, 'carrot');
      await open(t, s);
      s.cart.single.product.price = 50000;
      s.changed();
      await t.pumpAndSettle();
      expectCart(t, subtotal: 50000, discount: 50000);
      s.cart.single.product.price = 49999;
      s.changed();
      await t.pumpAndSettle();
      expectCart(t, subtotal: 49999, discount: 0);
    },
  );

  testWidgets(
    'catalog changes preserve snapshot until explicit P0-03 refresh',
    (t) async {
      final s = sample();
      add(s, 'carrot');
      await open(t, s);
      final catalog = (s.repository as MockLenlabRepository).catalog;
      catalog.singleWhere((p) => p.id == 'carrot').price = 60000;
      s.changed();
      await t.pumpAndSettle();
      expectCart(t, subtotal: 45000, discount: 0);
      await t.runAsync(s.refreshCodCheckout);
      await t.pumpAndSettle();
      expectCart(t, subtotal: 60000, discount: 50000);
      await expectCheckout(t, subtotal: 60000, discount: 50000);
    },
  );
}
