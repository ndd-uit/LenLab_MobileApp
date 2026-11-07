import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_admin/app.dart';
import 'package:lenlab_admin/app/admin_access_page.dart';
import 'package:lenlab_admin/app/admin_destination.dart';
import 'package:lenlab_admin/app/admin_scope.dart';
import 'package:lenlab_admin/features/coupons/presentation/admin_fixed_coupon_page.dart';
import 'package:lenlab_admin/features/coupons/presentation/admin_percentage_coupon_page.dart';
import 'package:lenlab_admin/shared/layout/admin_shell.dart';

import 'support/admin_test_session.dart';

void viewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1280, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

NavigatorState navigator(WidgetTester tester) =>
    tester.state<NavigatorState>(find.byType(Navigator).first);

void expectOverview(WidgetTester tester) {
  final shell = find.byType(AdminShell);
  expect(
    tester.widget<AdminShell>(shell).destination,
    AdminDestination.dashboard,
  );
  expect(ModalRoute.of(tester.element(shell))!.settings.name, '/');
  expect(find.byType(AdminPercentageCouponPage), findsNothing);
  expect(find.byType(AdminFixedCouponPage), findsNothing);
  expect(navigator(tester).canPop(), isFalse);
  expect(tester.takeException(), isNull);
}

void main() {
  for (final path in ['/vouchers/percentage', '/vouchers/fixed']) {
    testWidgets('$path platform URL Back skips the missing intermediate page', (
      tester,
    ) async {
      viewport(tester);
      tester.platformDispatcher.defaultRouteNameTestValue = path;
      addTearDown(tester.platformDispatcher.clearDefaultRouteNameTestValue);
      await tester.pumpWidget(AdminApp(session: await createSession()));
      await tester.pumpAndSettle();
      expect(
        ModalRoute.of(tester.element(find.byType(AdminShell)))!.settings.name,
        path,
      );
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expectOverview(tester);
    });
    for (final entry in ['sidebar', 'direct-url', 'no-history']) {
      for (final action in ['coupon-cancel', 'coupon-parent-breadcrumb']) {
        testWidgets('$path $entry $action returns to overview', (tester) async {
          viewport(tester);
          final session = await createSession();
          if (entry == 'no-history') {
            // A single initial route deliberately omits '/', unlike Flutter's
            // default initial route expansion. The fallback must still work.
            Route<void> route(RouteSettings settings) => PageRouteBuilder<void>(
              settings: settings,
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
              pageBuilder: (_, _, _) => AdminAccessPage(path: settings.name!),
            );
            await tester.pumpWidget(
              AdminScope(
                session: session,
                child: MaterialApp(
                  onGenerateInitialRoutes: (_) => [
                    route(RouteSettings(name: path)),
                  ],
                  onGenerateRoute: route,
                ),
              ),
            );
          } else {
            await tester.pumpWidget(
              AdminApp(
                session: session,
                initialRoute: entry == 'direct-url' ? path : '/',
              ),
            );
            await tester.pumpAndSettle();
            if (entry == 'sidebar') {
              await tester.tap(find.byKey(const ValueKey('admin-nav-orders')));
              await tester.pumpAndSettle();
              await tester.tap(
                find.byKey(const ValueKey('admin-nav-percentageCoupon')),
              );
              await tester.pumpAndSettle();
              if (path.endsWith('/fixed')) {
                await tester.tap(
                  find.byKey(const ValueKey('coupon-type-fixed')),
                );
              }
            }
          }
          await tester.pumpAndSettle();
          final breadcrumb = find.byKey(
            const ValueKey('coupon-parent-breadcrumb'),
          );
          expect(
            find.descendant(of: breadcrumb, matching: find.text('Tổng quan')),
            findsOneWidget,
          );
          final existingParent = entry == 'no-history'
              ? null
              : ModalRoute.of(tester.element(find.byType(AdminShell).first));
            if (entry == 'no-history') {
            expect(navigator(tester).canPop(), isFalse);
            }
          await tester.tap(find.byKey(ValueKey(action)));
          await tester.pumpAndSettle();
          expectOverview(tester);
          if (existingParent != null) {
            // Cancel must remove the current form, rather than replace its
            // contents with a different voucher type under the same URL.
            expect(existingParent.isActive, isFalse);
          }
        });
      }
    }
    testWidgets('$path Back returns without a duplicate form', (tester) async {
      viewport(tester);
      await tester.pumpWidget(
        AdminApp(session: await createSession(), initialRoute: path),
      );
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expectOverview(tester);
    });
  }

  testWidgets('Repeated type switches retain the original overview route', (
    tester,
  ) async {
    viewport(tester);
    await tester.pumpWidget(AdminApp(session: await createSession()));
    await tester.pumpAndSettle();
    final parent = ModalRoute.of(tester.element(find.byType(AdminShell)))!;
    await tester.tap(find.byKey(const ValueKey('admin-nav-percentageCoupon')));
    await tester.pumpAndSettle();
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.byKey(const ValueKey('coupon-type-fixed')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('coupon-type-percentage')));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.byKey(const ValueKey('coupon-cancel')));
    await tester.pumpAndSettle();
    expectOverview(tester);
    expect(
      ModalRoute.of(tester.element(find.byType(AdminShell))),
      same(parent),
    );
    await tester.tap(find.byKey(const ValueKey('admin-nav-percentageCoupon')));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expectOverview(tester);
  });
}
