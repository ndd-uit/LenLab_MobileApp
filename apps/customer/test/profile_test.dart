import 'package:lenlab_customer/features/auth/presentation/auth_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_customer/app/customer_app.dart';
import 'package:lenlab_customer/features/orders/presentation/order_list_page.dart';
import 'package:lenlab_customer/features/home/presentation/home_page.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

void main() {
  for (final width in [360.0, 390.0, 430.0]) {
    testWidgets('profile $width large text reads store and scrolls to logout', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final store =
          LenlabStore(repository: MockLenlabRepository(latency: Duration.zero))
            ..signedIn = true
            ..coupon = 'LEN50';
      store.profile.name = 'Khách hàng LENLAB với tên dài';
      await tester.pumpWidget(
        CustomerApp(store: store, initialRoute: '/profile'),
      );
      await tester.pumpAndSettle();
      expect(find.text(store.profile.name), findsOneWidget);
      expect(find.text(store.profile.email), findsOneWidget);
      await tester.ensureVisible(find.text('Đăng xuất'));
      await tester.tap(find.text('Đăng xuất'));
      await tester.pumpAndSettle();
      expect(store.signedIn, isFalse);
      expect(find.byType(HomePage), findsOneWidget);
      expect(store.cartCount, 0);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
    'profile loading and failure retry then orders opens correct route',
    (tester) async {
      final repo = MockLenlabRepository(
        latency: const Duration(milliseconds: 200),
      )..failNext('profile');
      final store = LenlabStore(repository: repo)
        ..signedIn = true
        ..coupon = 'LEN50';
      await tester.pumpWidget(
        CustomerApp(store: store, initialRoute: '/profile'),
      );
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('Không thể tải hồ sơ'), findsOneWidget);
      await tester.tap(find.text('Thử lại'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Đơn hàng của tôi'));
      await tester.pumpAndSettle();
      expect(find.byType(OrderListPage), findsOneWidget);
      expect(store.orders, hasLength(4));
    },
  );
  testWidgets(
    'guest does not load profile and missing fields show empty state',
    (tester) async {
      final store = LenlabStore(
        repository: MockLenlabRepository(latency: Duration.zero),
      );
      await tester.pumpWidget(
        CustomerApp(store: store, initialRoute: '/profile'),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AuthPage), findsOneWidget);
      expect(find.text(mockCustomerA.email), findsNothing);
      store.signedIn = true;
      store.coupon = 'LEN50';
      store.profile.name = '';
      store.profile.email = '';
      store.changed();
      // Start an authenticated page explicitly; a blocked route stays in Auth
      // until the Auth flow consumes its return intent.
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(
        CustomerApp(store: store, initialRoute: '/profile'),
      );
      await tester.pumpAndSettle();
      expect(find.text('Chưa có thông tin hồ sơ'), findsOneWidget);
    },
  );
  testWidgets(
    'unimplemented shortcuts disclose limitation without changing checkout',
    (tester) async {
      final store =
          LenlabStore(repository: MockLenlabRepository(latency: Duration.zero))
            ..signedIn = true
            ..coupon = 'LEN50';
      await tester.pumpWidget(
        CustomerApp(store: store, initialRoute: '/profile'),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Cài đặt tài khoản'));
      await tester.tap(find.text('Cài đặt tài khoản'));
      await tester.pumpAndSettle();
      expect(find.textContaining('chưa có đủ đặc tả'), findsOneWidget);
      expect(store.deliveryAddress, isNull);
      expect(store.cartCount, 3);
    },
  );
}
