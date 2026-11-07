import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_customer/app/customer_app.dart';
import 'package:lenlab_customer/features/cart/presentation/widgets/cart_summary.dart';
import 'package:lenlab_customer/features/checkout/presentation/widgets/order_review_products.dart';
import 'package:lenlab_customer/features/checkout/presentation/widgets/payment_method_footer.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

LenlabStore sample() =>
    LenlabStore(repository: MockLenlabRepository(latency: Duration.zero))
      ..signedIn = true
      ..coupon = 'LEN50'
      ..deliveryAddress = const Address(ownerId: mockCustomerAId);
Finder select(CartLine line) => find.byKey(ValueKey('cart-select-${line.key}'));
Finder pay() => find.widgetWithText(ElevatedButton, 'Thanh toán');

void main() {
  for (final width in [360.0, 430.0]) {
    testWidgets(
      'Selection $width text120 updates summary, blocks empty selection and survives back',
      (tester) async {
        tester.view.physicalSize = Size(width, 1000);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 1.2;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final store = sample();
        await tester.pumpWidget(
          CustomerApp(store: store, initialRoute: '/cart'),
        );
        await tester.pumpAndSettle();
        await tester.tap(select(store.cart.first));
        await tester.pump();
        expect(
          tester.widget<CartSummary>(find.byType(CartSummary)).subtotal,
          700000,
        );
        await tester.tap(select(store.cart.last));
        await tester.pump();
        expect(
          tester.widget<CartSummary>(find.byType(CartSummary)).discount,
          0,
        );
        expect(tester.widget<ElevatedButton>(pay()).onPressed, isNull);
        expect(store.cartCount, 3);
        await tester.tap(select(store.cart.last));
        await tester.pump();
        await tester.tap(pay());
        await tester.pumpAndSettle();
        expect(find.text('Địa chỉ giao hàng'), findsOneWidget);
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(store.isCartLineSelected(store.cart.first), isFalse);
        expect(store.checkoutLines.single.product.id, 'gloves');
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final route in [
    '/checkout',
    '/order-review',
    '/payment-method',
    '/bank-transfer',
  ]) {
    testWidgets(
      'Direct $route with no selection shows recovery instead of checking out other lines',
      (tester) async {
        final store = sample();
        for (final line in store.cart) {
          store.toggleCartLine(line);
        }
        await tester.pumpWidget(CustomerApp(store: store, initialRoute: route));
        await tester.pumpAndSettle();
        expect(find.text('Chưa chọn sản phẩm thanh toán'), findsOneWidget);
        expect(store.orders.length, 4);
        await tester.tap(find.text('Chọn sản phẩm'));
        await tester.pumpAndSettle();
        expect(find.text('Giỏ hàng'), findsOneWidget);
        expect(store.cartCount, 3);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'Review uses selected lines; failed COD keeps draft then retry only buys selection',
    (tester) async {
      tester.view.physicalSize = const Size(390, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = sample();
      store.toggleCartLine(store.cart.first);
      await tester.pumpWidget(
        CustomerApp(store: store, initialRoute: '/order-review'),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<OrderReviewProducts>(find.byType(OrderReviewProducts))
            .lines
            .single
            .product
            .id,
        'gloves',
      );
      final nav = tester.state<NavigatorState>(find.byType(Navigator));
      nav.pushNamed('/payment-method');
      await tester.pumpAndSettle();
      final total = tester
          .widget<PaymentMethodFooter>(find.byType(PaymentMethodFooter))
          .total;
      expect(total, 680000);
      (store.repository as MockLenlabRepository).failNext('checkout');
      await tester.tap(find.text('Đặt hàng COD'));
      await tester.pumpAndSettle();
      expect(store.cart.length, 2);
      expect(store.checkoutLines.single.product.id, 'gloves');
      await tester.ensureVisible(find.text('Thử đặt lại'));
      await tester.tap(find.text('Thử đặt lại'));
      await tester.pumpAndSettle();
      expect(store.orders.first.lines.single.product.id, 'gloves');
      expect(store.orders.first.total, total);
      expect(store.cart.single.product.id, 'sweater');
      expect(store.checkoutLines, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );
}
