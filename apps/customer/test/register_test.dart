import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_customer/app/customer_app.dart';
import 'package:lenlab_customer/app/customer_scope.dart';
import 'package:lenlab_customer/features/auth/presentation/auth_page.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

void main() {
  Future<void> fill(
    WidgetTester tester, {
    String confirmation = 'khacmatkhau',
  }) async {
    final fields = find.byType(TextFormField);
    for (final entry in [
      'Nguyễn Văn A',
      'khach@example.com',
      'matkhau',
      confirmation,
    ].asMap().entries) {
      await tester.ensureVisible(fields.at(entry.key));
      await tester.enterText(fields.at(entry.key), entry.value);
    }
    await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Đăng ký'));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'mismatch blocks registration and updates when either password changes',
    (tester) async {
      final store = LenlabStore(
        repository: MockLenlabRepository(latency: Duration.zero),
      );
      await tester.pumpWidget(
        CustomerApp(initialRoute: '/register', store: store),
      );
      await tester.pumpAndSettle();
      await fill(tester);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Đăng ký'));
      await tester.pumpAndSettle();
      expect(
        find.text('Mật khẩu xác nhận chưa khớp. Nhập lại mật khẩu.'),
        findsOneWidget,
      );
      expect(store.signedIn, isFalse);
      await tester.ensureVisible(find.byType(TextFormField).last);
      await tester.enterText(find.byType(TextFormField).last, 'matkhau');
      await tester.pumpAndSettle();
      expect(
        find.text('Mật khẩu xác nhận chưa khớp. Nhập lại mật khẩu.'),
        findsNothing,
      );
      await tester.ensureVisible(find.byType(TextFormField).at(2));
      await tester.enterText(find.byType(TextFormField).at(2), 'matkhaumoi');
      await tester.pumpAndSettle();
      expect(
        find.text('Mật khẩu xác nhận chưa khớp. Nhập lại mật khẩu.'),
        findsOneWidget,
      );
      await tester.tap(find.byTooltip('Hiện mật khẩu'));
      await tester.pump();
      expect(
        tester
            .widget<EditableText>(find.byType(EditableText).at(2))
            .obscureText,
        isFalse,
      );
      expect(
        tester.widget<EditableText>(find.byType(EditableText).last).obscureText,
        isFalse,
      );
      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField).last)
            .controller!
            .text,
        'matkhau',
      );
      expect(tester.takeException(), isNull);
    },
  );
  for (final width in [360.0, 390.0, 430.0]) {
    testWidgets(
      'register $width at 120% text and keyboard keeps confirmation accessible',
      (tester) async {
        tester.view.physicalSize = Size(width, 844);
        tester.view.devicePixelRatio = 1;
        tester.view.viewInsets = const FakeViewPadding(bottom: 320);
        tester.platformDispatcher.textScaleFactorTestValue = 1.2;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetViewInsets);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpWidget(CustomerApp(initialRoute: '/register'));
        await tester.pumpAndSettle();
        await fill(tester, confirmation: 'matkhau');
        final last = find.byType(TextFormField).last;
        await tester.ensureVisible(last);
        await tester.tap(last);
        await tester.pumpAndSettle();
        expect(tester.getBottomRight(last).dy, lessThanOrEqualTo(524));
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'mock registration preserves form after network error and succeeds on retry',
    (tester) async {
      final repo = MockLenlabRepository(
        latency: const Duration(milliseconds: 300),
      )..failNext('register');
      final store = LenlabStore(repository: repo);
      await tester.pumpWidget(
        CustomerScope(
          store: store,
          child: MaterialApp(
            theme: P2.theme(),
            initialRoute: '/register',
            routes: {
              '/register': (_) => const AuthPage(register: true),
              '/': (_) => const Scaffold(body: Text('Đăng ký thành công')),
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      await fill(tester, confirmation: 'matkhau');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Đăng ký'));
      await tester.pump();
      expect(
        tester
            .widget<ElevatedButton>(
              find.widgetWithText(ElevatedButton, 'Đang đăng ký…'),
            )
            .onPressed,
        isNull,
      );
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      expect(find.text('Không thể kết nối. Vui lòng thử lại.'), findsOneWidget);
      expect(store.signedIn, isFalse);
      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField).first)
            .controller!
            .text,
        'Nguyễn Văn A',
      );
      final submit = find.widgetWithText(ElevatedButton, 'Đăng ký');
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      expect(store.signedIn, isTrue);
      expect(store.profile.name, 'Nguyễn Văn A');
      expect(find.text('Đăng ký thành công'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
