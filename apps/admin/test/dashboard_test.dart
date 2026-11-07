import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_admin/features/dashboard/data/dashboard_source.dart';
import 'package:lenlab_admin/features/dashboard/presentation/dashboard_content.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

Widget host(DashboardSource source) => MaterialApp(
  theme: P2.theme(admin: true),
  home: Scaffold(
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: DashboardContent(source: source),
    ),
  ),
);

void main() {
  testWidgets('Loading, error, retry and basic metrics share snapshot', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 1024);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final source = MockDashboardSource()..failNext = true;
    await tester.pumpWidget(host(source));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('Không thể tải thống kê'), findsOneWidget);
    await tester.tap(find.text('Thử lại'));
    await tester.pumpAndSettle();
    expect(find.text('45.2M ₫'), findsOneWidget);
    expect(find.text('Sản phẩm đang bán'), findsOneWidget);
    for (final preview in dashboardProductFixtures) {
      expect(find.text(preview.name), findsOneWidget);
    }
    await tester.tap(find.text('Tạo đơn hàng mới'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tạo đơn chưa được triển khai.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Đóng'));
    await tester.pumpAndSettle();
    expect(find.text('128'), findsOneWidget);
  });

  testWidgets('Missing snapshot has empty state and reload', (tester) async {
    await tester.pumpWidget(host(MockDashboardSource(empty: true)));
    await tester.pumpAndSettle();
    expect(find.text('Chưa có dữ liệu thống kê'), findsOneWidget);
    expect(find.text('45.2M ₫'), findsNothing);
    await tester.tap(find.text('Tải lại'));
    await tester.pumpAndSettle();
    expect(find.text('Chưa có dữ liệu thống kê'), findsOneWidget);
  });

  for (final width in [390.0, 800.0, 1280.0]) {
    testWidgets('Dashboard adapts at $width with 120% text', (tester) async {
      tester.view.physicalSize = Size(width, 1100);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(host(MockDashboardSource()));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Sản phẩm đang bán'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
