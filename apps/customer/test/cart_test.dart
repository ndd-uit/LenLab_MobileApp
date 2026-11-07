import 'package:lenlab_customer/features/cart/presentation/widgets/cart_checkout_button.dart';
import 'package:lenlab_customer/features/cart/presentation/widgets/cart_item_card.dart';
import 'package:lenlab_customer/features/cart/presentation/widgets/cart_voucher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_customer/app/customer_app.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

void main() {
  for (final width in [360.0, 390.0, 430.0]) {
    testWidgets('cart $width large text updates quantities and becomes empty', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 884);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final store = LenlabStore()
        ..signedIn = true
        ..coupon = 'LEN50';
      await tester.pumpWidget(CustomerApp(initialRoute: '/cart', store: store));
      await tester.pumpAndSettle();
      expect(store.subtotal - store.discount, 1850000);
      await tester.tap(find.byTooltip('Tăng Áo Len Cổ Lọ'));
      await tester.pump();
      expect(store.subtotal - store.discount, 3050000);
      await tester.tap(find.byTooltip('Giảm Áo Len Cổ Lọ'));
      await tester.pump();
      expect(store.subtotal - store.discount, 1850000);
      await tester.tap(find.byTooltip('Xóa Áo Len Cổ Lọ'));
      await tester.pumpAndSettle();
      expect(store.subtotal, 700000);
      await tester.tap(find.byTooltip('Xóa Găng Tay Len Đan'));
      await tester.pumpAndSettle();
      expect(find.text('Giỏ hàng đang trống'), findsOneWidget);
      expect(find.byType(CartCheckoutButton), findsNothing);
      await tester.tap(find.text('Tiếp tục mua sắm'));
      await tester.pumpAndSettle();
      expect(find.text('Thú Bông Cừu Handmade Size L'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
    'Merino added variant appears in cart and checkout opens address form',
    (tester) async {
      final repo = MockLenlabRepository(latency: Duration.zero);
      final store = LenlabStore(repository: repo)
        ..signedIn = true
        ..coupon = 'LEN50'
        ..cart.clear();
      await tester.pumpWidget(CustomerApp(store: store));
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(Scaffold).last);
      Navigator.of(context).pushNamed(
        '/product',
        arguments: repo.catalog.firstWhere((p) => p.id == 'merino'),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('200cm'));
      await tester.tap(find.text('200cm'));
      await tester.tap(find.text('Thêm vào giỏ'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('variant-confirm')));
      await tester.tap(find.byKey(const ValueKey('variant-confirm')));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Giỏ hàng'));
      await tester.pumpAndSettle();
      expect(find.byType(CartItemCard), findsOneWidget);
      expect(find.text('Kem - 200cm'), findsOneWidget);
      expect(store.cart.single.total, 550000);
      await tester.tap(find.text('Thanh toán'));
      await tester.pumpAndSettle();
      expect(find.text('Địa chỉ giao hàng'), findsOneWidget);
      expect(store.orders.length, 4);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'cart stepper respects bounds and opening wallet does not apply a voucher',
    (tester) async {
      final store = LenlabStore()
        ..signedIn = true
        ..coupon = 'LEN50';
      store.cart.first.product.stock = 1;
      await tester.pumpWidget(CustomerApp(initialRoute: '/cart', store: store));
      await tester.pumpAndSettle();
      for (final label in ['Tăng Áo Len Cổ Lọ', 'Giảm Áo Len Cổ Lọ']) {
        expect(
          tester
              .widget<IconButton>(
                find.byWidgetPredicate(
                  (w) => w is IconButton && w.tooltip == label,
                ),
              )
              .onPressed,
          isNull,
        );
      }
      await tester.ensureVisible(find.byType(CartVoucher));
      await tester.tap(find.byType(CartVoucher));
      await tester.pumpAndSettle();
      expect(find.text('Voucher của tôi'), findsOneWidget);
      expect(store.voucherCandidate, isNull);
      expect(find.text('Áp dụng thành công'), findsNothing);
      expect(store.coupon, 'LEN50');
      expect(tester.takeException(), isNull);
    },
  );
}
