import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_admin/app.dart';
import 'package:lenlab_admin/app/admin_session.dart';
import 'package:lenlab_admin/app/admin_destination.dart';
import 'package:lenlab_admin/features/auth/data/admin_auth_source.dart';
import 'package:lenlab_admin/features/auth/presentation/admin_login_page.dart';
import 'package:lenlab_admin/shared/layout/admin_shell.dart';

Future<void> enterDemo(WidgetTester tester) async {
  await tester.enterText(
    find.byKey(const ValueKey('admin-email')),
    MockAdminAuthSource.demoEmail,
  );
  await tester.enterText(
    find.byKey(const ValueKey('admin-password')),
    MockAdminAuthSource.demoPassword,
  );
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text('Đăng nhập ngay'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Explicit login submits with Enter and redirects to dashboard', (
    tester,
  ) async {
    final session = AdminSession(source: MockAdminAuthSource());
    addTearDown(session.dispose);
    await tester.pumpWidget(AdminApp(session: session, initialRoute: '/login'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('admin-email')),
      MockAdminAuthSource.demoEmail,
    );
    await tester.enterText(
      find.byKey(const ValueKey('admin-password')),
      MockAdminAuthSource.demoPassword,
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.byType(AdminShell), findsOneWidget);
    expect(
      ModalRoute.of(tester.element(find.byType(AdminShell)))!.settings.name,
      '/',
    );
    expect(tester.takeException(), isNull);
  });
  for (final width in [390.0, 800.0, 1280.0]) {
    testWidgets(
      'Blue admin login $width text120 error retry and protected destination',
      (tester) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 1.2;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final source = MockAdminAuthSource();
        final active = AdminSession(source: source);
        addTearDown(active.dispose);
        await tester.pumpWidget(
          AdminApp(session: active, initialRoute: '/orders'),
        );
        await tester.pumpAndSettle();
        expect(find.byType(AdminShell), findsNothing);
        await tester.ensureVisible(find.text('Đăng nhập ngay'));
        await tester.tap(find.text('Đăng nhập ngay'));
        await tester.pumpAndSettle();
        expect(find.text('Vui lòng nhập email hợp lệ.'), findsOneWidget);
        expect(find.text('Vui lòng nhập mật khẩu.'), findsOneWidget);
        await enterDemo(tester);
        source.failNext = true;
        await tester.tap(find.text('Đăng nhập ngay'));
        await tester.pump(const Duration(milliseconds: 20));
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(active.busy, isTrue);
        await tester.pumpAndSettle();
        expect(
          find.textContaining('Không thể đăng nhập lúc này'),
          findsOneWidget,
        );
        expect(active.signedIn, isFalse);
        expect(
          tester
              .widget<TextFormField>(find.byKey(const ValueKey('admin-email')))
              .controller!
              .text,
          MockAdminAuthSource.demoEmail,
        );
        await tester.ensureVisible(find.text('Đăng nhập ngay'));
        await tester.tap(find.text('Đăng nhập ngay'));
        await tester.pumpAndSettle();
        expect(
          tester.widget<AdminShell>(find.byType(AdminShell)).destination,
          AdminDestination.orders,
        );
        expect(active.signedIn, isTrue);
        expect(find.byType(AdminLoginPage), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'Wrong credentials stay outside shell; logout clears history and protected pages',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final active = AdminSession(source: MockAdminAuthSource());
      addTearDown(active.dispose);
      await tester.pumpWidget(AdminApp(session: active));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('admin-email')),
        'other@example.com',
      );
      await tester.enterText(
        find.byKey(const ValueKey('admin-password')),
        'wrong',
      );
      await tester.ensureVisible(find.text('Đăng nhập ngay'));
      await tester.tap(find.text('Đăng nhập ngay'));
      await tester.pumpAndSettle();
      expect(find.text('Email hoặc mật khẩu không đúng.'), findsOneWidget);
      await enterDemo(tester);
      await tester.tap(find.text('Đăng nhập ngay'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('admin-nav-products')));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Đăng xuất'));
      await tester.pumpAndSettle();
      expect(find.byType(AdminLoginPage), findsOneWidget);
      expect(active.signedIn, isFalse);
      final nav = tester.state<NavigatorState>(find.byType(Navigator));
      expect(nav.canPop(), isFalse);
      nav.pushNamed('/customers');
      await tester.pumpAndSettle();
      expect(find.byType(AdminShell), findsNothing);
      expect(find.byKey(const ValueKey('admin-password')), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'Forgot and remember are honest placeholders; keyboard keeps form reachable',
    (tester) async {
      tester.view.physicalSize = const Size(390, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpWidget(const AdminApp());
      await tester.pumpAndSettle();
      for (final title in ['Quên mật khẩu?', 'Ghi nhớ đăng nhập']) {
        await tester.ensureVisible(find.text(title));
        await tester.tap(find.text(title));
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsOneWidget);
        await tester.tap(find.text('Đóng'));
        await tester.pumpAndSettle();
      }
      await tester.enterText(
        find.byKey(const ValueKey('admin-password')),
        'draft',
      );
      tester.view.viewInsets = const FakeViewPadding(bottom: 320);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Đăng nhập ngay'));
      await tester.pumpAndSettle();
      expect(tester.getRect(find.text('Đăng nhập ngay')).bottom, lessThan(480));
      expect(
        tester
            .widget<TextField>(
              find.descendant(
                of: find.byKey(const ValueKey('admin-password')),
                matching: find.byType(TextField),
              ),
            )
            .obscureText,
        isTrue,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
