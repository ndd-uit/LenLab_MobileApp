import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_customer/app/customer_app.dart';
import 'package:lenlab_customer/app/customer_scope.dart';
import 'package:lenlab_customer/features/auth/presentation/auth_page.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

void main() {
  for (final width in [360.0, 390.0, 430.0]) {
    testWidgets('login at $width preserves text and input with 120% scaling', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(CustomerApp(initialRoute: '/login'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextFormField).first,
        'nguyenvan.a@example.com',
      );
      await tester.ensureVisible(find.byType(TextFormField).last);
      await tester.enterText(find.byType(TextFormField).last, 'matkhau');
      await tester.pumpAndSettle();
      final submit = find.widgetWithText(ElevatedButton, 'Đăng nhập');
      await tester.ensureVisible(submit);
      expect(tester.widget<ElevatedButton>(submit).onPressed, isNotNull);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
    'login disables submit during loading then allows retry after failure',
    (tester) async {
      tester.view.physicalSize = const Size(390, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repo = MockLenlabRepository(
        latency: const Duration(milliseconds: 300),
      )..failNext('login');
      final store = LenlabStore(repository: repo);
      await tester.pumpWidget(
        CustomerScope(
          store: store,
          child: MaterialApp(
            theme: P2.theme(),
            initialRoute: '/login',
            routes: {
              '/login': (_) => const AuthPage(),
              '/': (_) => const Scaffold(body: Text('Đăng nhập thành công')),
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextFormField).first,
        'nguyenvan.a@example.com',
      );
      await tester.enterText(find.byType(TextFormField).last, 'matkhau');
      final submit = find.widgetWithText(ElevatedButton, 'Đăng nhập');
      await tester.tap(submit);
      await tester.pump();
      expect(
        tester
            .widget<ElevatedButton>(
              find.widgetWithText(ElevatedButton, 'Đang đăng nhập…'),
            )
            .onPressed,
        isNull,
      );
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      expect(find.text('Không thể kết nối. Vui lòng thử lại.'), findsOneWidget);
      expect(store.signedIn, isFalse);
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      expect(store.signedIn, isTrue);
      expect(find.text('Đăng nhập thành công'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('login validates fields and exposes password visibility', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(CustomerApp(initialRoute: '/login'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Đăng nhập'));
    await tester.pump();
    expect(
      find.text('Số điện thoại gồm 10 chữ số, bắt đầu bằng 0.'),
      findsOneWidget,
    );
    expect(find.text('Vui lòng nhập mật khẩu.'), findsOneWidget);
    await tester.tap(find.byTooltip('Hiện mật khẩu'));
    await tester.pump();
    expect(find.byTooltip('Ẩn mật khẩu'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  for (final width in [360.0, 390.0, 430.0]) {
    testWidgets('catalog at $width supports 120% text and empty search', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.platformDispatcher.textScaleFactorTestValue = 1.2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(
        CustomerApp(
          initialRoute: '/products',
          store: LenlabStore(
            repository: MockLenlabRepository(latency: Duration.zero),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Thú Bông Cừu Handmade Size L'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'khong-ton-tai');
      await tester.pumpAndSettle();
      expect(find.text('Không có kết quả'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('catalog error offers a working retry', (tester) async {
    final repo = MockLenlabRepository(latency: Duration.zero)
      ..failNext('products');
    await tester.pumpWidget(
      CustomerApp(
        initialRoute: '/products',
        store: LenlabStore(repository: repo),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Không thể tải sản phẩm'), findsOneWidget);
    await tester.tap(find.text('Thử lại'));
    await tester.pumpAndSettle();
    expect(find.text('Thú Bông Cừu Handmade Size L'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
