import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_customer/app/customer_app.dart';
import 'package:lenlab_customer/features/cart/presentation/widgets/guest_cart_prompt.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

void main() {
  for (final width in [360.0, 390.0, 430.0]) {
    testWidgets(
      'Guest cart $width large text later dismisses without mutation',
      (tester) async {
        tester.view.physicalSize = Size(width, 800);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 1.2;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final store = LenlabStore();
        final catalog = (store.repository as MockLenlabRepository).catalog;
        store.addToCart(
          catalog.firstWhere((p) => p.id == 'sweater'),
          1,
          'Guest',
        );
        store.addToCart(
          catalog.firstWhere((p) => p.id == 'gloves'),
          2,
          'Guest',
        );
        await tester.pumpWidget(
          CustomerApp(store: store, initialRoute: '/cart'),
        );
        await tester.pumpAndSettle();
        expect(find.byType(GuestCartPrompt), findsOneWidget);
        await tester.ensureVisible(find.text('Để sau'));
        await tester.tap(find.text('Để sau'));
        await tester.pumpAndSettle();
        expect(find.byType(GuestCartPrompt), findsNothing);
        expect(store.cartCount, 3);
        expect(store.orders.length, 0);
        expect(store.signedIn, isFalse);
        store.changed();
        await tester.pumpAndSettle();
        expect(find.byType(GuestCartPrompt), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'Guest auth entry and back keep cart; close and system back dismiss; member bypasses',
    (tester) async {
      final store = LenlabStore();
      final catalog = (store.repository as MockLenlabRepository).catalog;
      store.addToCart(catalog.firstWhere((p) => p.id == 'sweater'), 1, 'Guest');
      store.addToCart(catalog.firstWhere((p) => p.id == 'gloves'), 2, 'Guest');
      await tester.pumpWidget(CustomerApp(store: store, initialRoute: '/cart'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Đăng nhập / Đăng ký'));
      await tester.pumpAndSettle();
      expect(find.byType(GuestCartPrompt), findsNothing);
      final nav = tester.state<NavigatorState>(find.byType(Navigator));
      nav.pop();
      await tester.pumpAndSettle();
      expect(find.byType(GuestCartPrompt), findsOneWidget);
      await tester.tap(find.byTooltip('Đóng nhắc đăng nhập'));
      await tester.pumpAndSettle();
      expect(find.byType(GuestCartPrompt), findsNothing);
      nav.pushNamed('/cart');
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(GuestCartPrompt), findsNothing);
      store.signedIn = true;
      store.coupon = 'LEN50';
      store.changed();
      nav.pushNamed('/cart');
      await tester.pumpAndSettle();
      expect(find.byType(GuestCartPrompt), findsNothing);
      expect(store.cartCount, 3);
      expect(tester.takeException(), isNull);
    },
  );
}
