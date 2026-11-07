import 'support/admin_test_session.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_admin/app.dart';
import 'package:lenlab_admin/app/admin_destination.dart';
import 'package:lenlab_admin/shared/layout/admin_shell.dart';
import 'package:lenlab_admin/shared/layout/admin_header.dart';
import 'package:lenlab_admin/shared/layout/admin_sidebar.dart';
import 'package:lenlab_admin/features/products/presentation/widgets/products_header.dart';
import 'package:lenlab_admin/features/orders/presentation/widgets/orders_header.dart';
import 'package:lenlab_admin/features/customers/presentation/widgets/customers_header.dart';

Finder adminPageHeader() => find.byWidgetPredicate(
  (widget) =>
      widget is AdminHeader ||
      widget is ProductsHeader ||
      widget is OrdersHeader ||
      widget is CustomersHeader,
);

void main() {
  testWidgets(
    'Section switches and Back do not animate or duplicate web shell',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(AdminApp(session: await createSession()));
      await tester.pumpAndSettle();
      final headerPosition = tester.getTopLeft(adminPageHeader());
      final sidebarPosition = tester.getTopLeft(find.byType(AdminSidebar));
      for (final target in [
        AdminDestination.products,
        AdminDestination.orders,
      ]) {
        await tester.tap(find.byKey(ValueKey('admin-nav-${target.name}')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 16));
        expect(find.byType(AdminShell), findsOneWidget);
        expect(find.byType(AdminSidebar), findsOneWidget);
        expect(tester.getTopLeft(adminPageHeader()), headerPosition);
        expect(tester.getTopLeft(find.byType(AdminSidebar)), sidebarPosition);
        final route = ModalRoute.of(tester.element(find.byType(AdminShell)))!;
        expect(route.settings.name, target.path);
        expect(route.transitionDuration, Duration.zero);
        expect(route.reverseTransitionDuration, Duration.zero);
      }
      tester.state<NavigatorState>(find.byType(Navigator)).pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      expect(
        tester.widget<AdminShell>(find.byType(AdminShell)).destination,
        AdminDestination.products,
      );
      expect(find.byType(AdminShell), findsOneWidget);
      expect(tester.getTopLeft(adminPageHeader()), headerPosition);
      expect(tester.getTopLeft(find.byType(AdminSidebar)), sidebarPosition);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('Desktop sidebar navigates to named placeholders and back', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 1024);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(AdminApp(session: await createSession()));
    await tester.pumpAndSettle();
    for (final target in [
      AdminDestination.products,
      AdminDestination.orders,
      AdminDestination.customers,
      AdminDestination.percentageCoupon,
      AdminDestination.settings,
    ]) {
      await tester.tap(find.byKey(ValueKey('admin-nav-${target.name}')));
      await tester.pumpAndSettle();
      expect(
        tester.widget<AdminShell>(find.byType(AdminShell)).destination,
        target,
      );
      expect(
        ModalRoute.of(tester.element(find.byType(AdminShell)))!.settings.name,
        target.path,
      );
      expect(
        tester
            .widget<Semantics>(find.byKey(ValueKey('admin-nav-${target.name}')))
            .properties
            .selected,
        isTrue,
      );
      if (target == AdminDestination.products) {
        expect(find.text('Danh sách sản phẩm'), findsOneWidget);
        expect(find.text('MK-MEO-\n001'), findsOneWidget);
      } else if (target == AdminDestination.orders) {
        expect(find.text('Danh sách đơn hàng'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('order-id-ORD-202501')),
          findsOneWidget,
        );
      } else if (target == AdminDestination.customers) {
        expect(find.text('Quản lý người dùng'), findsOneWidget);
        expect(find.text('huy.nguyen@example.com'), findsOneWidget);
      } else if (target == AdminDestination.percentageCoupon) {
        expect(find.text('Chi tiết mã'), findsOneWidget);
      } else if (target == AdminDestination.settings) {
        expect(find.text('Cấu hình hệ thống'), findsOneWidget);
        expect(find.text('Lenlab Official'), findsOneWidget);
      } else {
        expect(
          find.text('${target.title} chưa được triển khai'),
          findsOneWidget,
        );
      }
      tester.state<NavigatorState>(find.byType(Navigator)).pop();
      await tester.pumpAndSettle();
      expect(
        tester.widget<AdminShell>(find.byType(AdminShell)).destination,
        AdminDestination.dashboard,
      );
    }
    await tester.tap(find.text('Giao diện'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<AdminShell>(find.byType(AdminShell)).destination,
      AdminDestination.appearance,
    );
    expect(tester.takeException(), isNull);
  });
  for (final width in [390.0, 800.0]) {
    testWidgets('Narrow web $width text120 menu navigates and closes', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(AdminApp(session: await createSession()));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Mở menu quản trị'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('admin-nav-orders')));
      await tester.pumpAndSettle();
      expect(
        tester.widget<AdminShell>(find.byType(AdminShell)).destination,
        AdminDestination.orders,
      );
      expect(find.byType(Drawer), findsNothing);
      await tester.tap(find.byTooltip('Mở menu quản trị'));
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(Drawer), findsNothing);
      expect(
        tester.widget<AdminShell>(find.byType(AdminShell)).destination,
        AdminDestination.orders,
      );
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
    'Header actions disclose pending functionality without accepting data',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(AdminApp(session: await createSession()));
      await tester.pumpAndSettle();
      final theme = Theme.of(tester.element(find.byType(AdminShell)))
          .brightness;
      for (final finder in [
        find.text('Tìm kiếm sản phẩm, đơn hàng...'),
        find.byTooltip('Thông báo'),
        find.byTooltip('Đổi giao diện'),
      ]) {
        await tester.tap(finder);
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.byType(TextField), findsNothing);
        await tester.tap(find.text('Đóng'));
        await tester.pumpAndSettle();
        expect(
          tester.widget<AdminShell>(find.byType(AdminShell)).destination,
          AdminDestination.dashboard,
        );
      }
      expect(
        Theme.of(tester.element(find.byType(AdminShell))).brightness,
        theme,
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('Direct route and unknown page retain the shell', (tester) async {
    await tester.pumpWidget(
      AdminApp(initialRoute: '/customers', session: await createSession()),
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<AdminShell>(find.byType(AdminShell)).destination,
      AdminDestination.customers,
    );
    tester.state<NavigatorState>(find.byType(Navigator)).pushNamed('/unknown');
    await tester.pumpAndSettle();
    expect(find.text('Trang không tồn tại'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
