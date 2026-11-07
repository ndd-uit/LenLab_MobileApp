import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_customer/app/customer_app.dart';
import 'package:lenlab_customer/features/auth/presentation/auth_page.dart';
import 'package:lenlab_customer/features/profile/presentation/profile_page.dart';
import 'package:lenlab_customer/shared/navigation/customer_drawer.dart';
import 'package:lenlab_customer/shared/layout/pending_page.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

void main() {
  Future<void> open(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Mở menu'));
    await tester.pumpAndSettle();
  }

  for (final width in [360.0, 390.0, 430.0]) {
    // Compact viewports cover both session states below.
    for (final signedIn in [false, true]) {
      testWidgets(
        'drawer $width text120 ${signedIn ? 'member' : 'guest'} scroll and close safely',
        (tester) async {
          tester.view.physicalSize = Size(width, 640);
          tester.view.devicePixelRatio = 1;
          tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
          tester.platformDispatcher.textScaleFactorTestValue = 1.2;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.view.resetPadding);
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          final store = LenlabStore(
            repository: MockLenlabRepository(latency: Duration.zero),
          )..signedIn = signedIn;
          await tester.pumpWidget(CustomerApp(store: store));
          await tester.pumpAndSettle();
          await open(tester);
          expect(find.text('Menu'), findsOneWidget);
          expect(
            find.text(signedIn ? 'Đăng xuất' : 'Chào mừng bạn!'),
            findsOneWidget,
          );
          expect(
            find.text(signedIn ? 'Chào mừng bạn!' : 'Đăng xuất'),
            findsNothing,
          );
          await tester.ensureVisible(find.text('Hỗ trợ'));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await tester.tap(find.byTooltip('Đóng menu'));
          await tester.pumpAndSettle();
          expect(
            tester
                .state<ScaffoldState>(find.byType(Scaffold).first)
                .isDrawerOpen,
            isFalse,
          );
          await open(tester);
          await tester.tapAt(Offset(width - 8, 300));
          await tester.pumpAndSettle();
          expect(
            tester
                .state<ScaffoldState>(find.byType(Scaffold).first)
                .isDrawerOpen,
            isFalse,
          );
          expect(store.signedIn, signedIn);
          expect(store.cartCount, signedIn ? 3 : 0);
          expect(store.orders.length, signedIn ? 4 : 0);
        },
      );
    }
  }
  for (final label in ['Đăng nhập', 'Đăng ký']) {
    testWidgets('guest drawer $label opens correct auth route', (tester) async {
      await tester.pumpWidget(CustomerApp());
      await tester.pumpAndSettle();
      await open(tester);
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      expect(
        tester.widget<AuthPage>(find.byType(AuthPage)).register,
        label == 'Đăng ký',
      );
      expect(find.text('Chào mừng bạn!'), findsNothing);
    });
  }
  testWidgets(
    'member profile opens from identity; logout only changes session',
    (tester) async {
      final store =
          LenlabStore(repository: MockLenlabRepository(latency: Duration.zero))
            ..signedIn = true
            ..coupon = 'LEN50';
      store.profile.name = 'Nguyễn Văn B';
      await tester.pumpWidget(CustomerApp(store: store));
      await tester.pumpAndSettle();
      await open(tester);
      await tester.tap(find.text('Xin chào, B'));
      await tester.pumpAndSettle();
      expect(find.byType(ProfilePage), findsOneWidget);
      tester.state<NavigatorState>(find.byType(Navigator).first).pop();
      await tester.pumpAndSettle();
      await open(tester);
      await tester.tap(find.text('Đăng xuất'));
      await tester.pumpAndSettle();
      expect(store.signedIn, isFalse);
      expect(store.cartCount, 0);
      expect(store.orders, isEmpty);
      expect(store.coupon, isEmpty);
      await open(tester);
      expect(find.text('Chào mừng bạn!'), findsOneWidget);
      expect(find.text('Xin chào, B'), findsNothing);
    },
  );
  testWidgets(
    'six P2 entries preserve route destinations; terms stay pending',
    (tester) async {
      for (final item in [
        ('Trang chủ', '/'),
        ('Sản phẩm', '/products'),
        ('Về chúng tôi', '/about'),
        ('Hỗ trợ', '/faq'),
        ('Điều khoản', '/policies'),
      ]) {
        await tester.pumpWidget(const SizedBox());
        await tester.pumpWidget(
          CustomerApp(
            store: LenlabStore(
              repository: MockLenlabRepository(latency: Duration.zero),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await open(tester);
        final target = find.descendant(
          of: find.byType(CustomerDrawer),
          matching: find.text(item.$1),
        );
        await tester.ensureVisible(target);
        await tester.tap(target);
        await tester.pumpAndSettle();
        final scaffold = find.byType(Scaffold).last;
        expect(ModalRoute.of(tester.element(scaffold))!.settings.name, item.$2);
        if (item.$2 == '/policies') {
          expect(find.byType(PendingPage), findsOneWidget);
        }
      }
    },
  );
  testWidgets('native back closes drawer before leaving catalog', (
    tester,
  ) async {
    await tester.pumpWidget(CustomerApp(initialRoute: '/products'));
    await tester.pumpAndSettle();
    await open(tester);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(
      tester.state<ScaffoldState>(find.byType(Scaffold).last).isDrawerOpen,
      isFalse,
    );
    expect(
      ModalRoute.of(tester.element(find.byType(Scaffold).last))!.settings.name,
      '/products',
    );
  });
}
