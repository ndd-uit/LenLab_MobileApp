import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_admin/app.dart';
import 'package:lenlab_admin/features/auth/presentation/admin_login_page.dart';
import 'package:lenlab_admin/features/coupons/data/admin_fixed_coupon_source.dart';
import 'package:lenlab_admin/features/coupons/data/admin_percentage_coupon_source.dart';
import 'package:lenlab_admin/features/coupons/presentation/admin_fixed_coupon_page.dart';
import 'package:lenlab_admin/features/coupons/presentation/admin_percentage_coupon_page.dart';
import 'package:lenlab_admin/features/coupons/presentation/widgets/coupon_header_footer.dart';
import 'package:lenlab_admin/features/coupons/presentation/widgets/coupon_readonly_field.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

import 'support/admin_test_session.dart';

void viewport(WidgetTester tester, {double width = 1280}) {
  tester.view.physicalSize = Size(width, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Widget host(AdminFixedCouponSource source) => MaterialApp(
  theme: P2.theme(admin: true),
  home: Scaffold(body: AdminFixedCouponPage(source: source)),
);

class ControlledFixedCoupon implements AdminFixedCouponSource {
  final result = Completer<AdminFixedCoupon?>();
  @override
  Future<AdminFixedCoupon?> fetch() => result.future;
}

void main() {
  test(
    'Fixed fixture preserves unknowns, zero minimum and retry/empty source',
    () async {
      final source = MockAdminFixedCouponSource(latency: Duration.zero);
      final example = (await source.fetch())!;
      expect(example.amount, 50000);
      expect(example.minimumOrder, 0);
      expect(example.startDateLabel, '12/05/2024');
      expect(example.code, isNull);
      expect(example.quantityLimit, isNull);
      expect(example.expiryDateLabel, isNull);
      source.failNext = true;
      await expectLater(source.fetch(), throwsStateError);
      expect(await source.fetch(), same(example));
      expect(
        await MockAdminFixedCouponSource(
          latency: Duration.zero,
          example: null,
        ).fetch(),
        isNull,
      );
    },
  );

  testWidgets(
    'Fixed P2 preview: full-width amount, no percent cap or editors, creation disabled',
    (tester) async {
      viewport(tester);
      await tester.pumpWidget(host(MockAdminFixedCouponSource()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
      for (final text in [
        '50.000',
        'đ',
        '0',
        '12/05/2024',
        'dd/mm/yyyy',
        'VÍ DỤ: LENLABSALE50',
        'Nhập số lượng mã (ví dụ: 100)',
      ]) {
        expect(find.text(text), findsOneWidget);
      }
      expect(find.text('Giảm tối đa (nếu theo %)'), findsNothing);
      expect(find.text('20'), findsNothing);
      expect(find.byType(TextField), findsNothing);
      expect(find.byType(DatePickerDialog), findsNothing);
      final fields = tester.widgetList<CouponReadonlyField>(
        find.byType(CouponReadonlyField),
      );
      final amount = fields.firstWhere(
        (field) => field.label == 'Giá trị giảm *',
      );
      final code = fields.firstWhere((field) => field.label == 'Mã giảm giá');
      expect(
        tester.getSize(find.byWidget(amount)).width,
        greaterThan(tester.getSize(find.byWidget(code)).width),
      );
      expect(
        tester
            .widget<Semantics>(find.byKey(const ValueKey('coupon-type-fixed')))
            .properties
            .selected,
        isTrue,
      );
      expect(
        tester
            .widget<Semantics>(
              find.byKey(const ValueKey('coupon-type-percentage')),
            )
            .properties
            .selected,
        isFalse,
      );
      for (final key in ['coupon-create', 'coupon-draft']) {
        final button = find.byKey(ValueKey(key));
        expect(tester.widget<FilledButton>(button).onPressed, isNull);
        await tester.tap(button);
      }
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);
      expect(find.byType(AlertDialog), findsNothing);
    },
  );

  testWidgets(
    'Empty, unknown and explicit zero are distinct; same-source error retries',
    (tester) async {
      viewport(tester);
      await tester.pumpWidget(host(MockAdminFixedCouponSource(example: null)));
      await tester.pumpAndSettle();
      expect(find.text('Chưa có dữ liệu mẫu mã giảm giá'), findsOneWidget);
      await tester.pumpWidget(
        host(MockAdminFixedCouponSource(example: const AdminFixedCoupon())),
      );
      await tester.pumpAndSettle();
      expect(find.text('Chưa có dữ liệu'), findsNWidgets(3));
      expect(find.text('50.000'), findsNothing);
      expect(find.text('0'), findsNothing);
      await tester.pumpWidget(
        host(
          MockAdminFixedCouponSource(
            example: const AdminFixedCoupon(amount: 0, quantityLimit: 0),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('0'), findsNWidgets(2));
      expect(find.text('Nhập số lượng mã (ví dụ: 100)'), findsNothing);
      final retry = MockAdminFixedCouponSource()..failNext = true;
      await tester.pumpWidget(host(retry));
      await tester.pumpAndSettle();
      expect(find.text('Không thể tải mẫu mã giảm giá'), findsOneWidget);
      await tester.tap(find.text('Thử lại'));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('50.000'), findsNothing);
      await tester.pumpAndSettle();
      expect(find.text('50.000'), findsOneWidget);
    },
  );

  testWidgets('Source replacement and disposal ignore stale success/error', (
    tester,
  ) async {
    viewport(tester);
    final old = ControlledFixedCoupon();
    final fresh = ControlledFixedCoupon();
    await tester.pumpWidget(host(old));
    await tester.pumpWidget(host(fresh));
    fresh.result.complete(const AdminFixedCoupon(code: 'FRESH'));
    await tester.pumpAndSettle();
    old.result.complete(adminFixedCouponFixture);
    await tester.pumpAndSettle();
    expect(find.text('FRESH'), findsOneWidget);
    expect(find.text('50.000'), findsNothing);
    final stale = ControlledFixedCoupon();
    await tester.pumpWidget(host(stale));
    expect(find.text('FRESH'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    stale.result.completeError(StateError('disposed'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Guard, two-way preview navigation without route stacking, injected sources and Cancel/logout',
    (tester) async {
      viewport(tester);
      await tester.pumpWidget(const AdminApp(initialRoute: '/vouchers/fixed'));
      await tester.pumpAndSettle();
      expect(find.byType(AdminLoginPage), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(
        AdminApp(
          initialRoute: '/vouchers/percentage',
          session: await createSession(),
          fixedCouponSource: MockAdminFixedCouponSource(
            example: const AdminFixedCoupon(code: 'FIXEDAPP', amount: 75000),
          ),
          percentageCouponSource: MockAdminPercentageCouponSource(
            example: const AdminPercentageCoupon(
              code: 'PERCENTAPP',
              percentage: 15,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('admin-nav-percentageCoupon')),
      );
      await tester.pumpAndSettle();
      expect(find.text('PERCENTAPP'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('coupon-type-fixed')));
      await tester.pumpAndSettle();
      expect(find.byType(AdminFixedCouponPage), findsOneWidget);
      expect(find.text('FIXEDAPP'), findsOneWidget);
      expect(find.text('75.000'), findsOneWidget);
      expect(
        tester
            .widget<Semantics>(
              find.byKey(const ValueKey('admin-nav-percentageCoupon')),
            )
            .properties
            .selected,
        isTrue,
      );
      await tester.tap(find.byKey(const ValueKey('coupon-type-percentage')));
      await tester.pumpAndSettle();
      expect(find.text('PERCENTAPP'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('coupon-type-fixed')));
      await tester.pumpAndSettle();
      tester.state<NavigatorState>(find.byType(Navigator)).pop();
      await tester.pumpAndSettle();
      expect(find.byType(AdminPercentageCouponPage), findsNothing);
      expect(find.byKey(const ValueKey('admin-nav-dashboard')), findsOneWidget);
      await tester.tap(
        find.byKey(const ValueKey('admin-nav-percentageCoupon')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('coupon-type-fixed')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('coupon-cancel')));
      await tester.pumpAndSettle();
      expect(find.byType(AdminPercentageCouponPage), findsNothing);
      expect(find.byType(AdminFixedCouponPage), findsNothing);
      await tester.tap(find.byTooltip('Đăng xuất'));
      await tester.pumpAndSettle();
      expect(find.byType(AdminLoginPage), findsOneWidget);
      expect(
        tester.state<NavigatorState>(find.byType(Navigator)).canPop(),
        isFalse,
      );
    },
  );

  for (final width in [390.0, 800.0, 1280.0]) {
    testWidgets(
      'Fixed coupon $width text120 final field reachable, fixed footer and Drawer',
      (tester) async {
        viewport(tester, width: width);
        tester.platformDispatcher.textScaleFactorTestValue = 1.2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpWidget(
          AdminApp(
            initialRoute: '/vouchers/fixed',
            session: await createSession(),
          ),
        );
        await tester.pumpAndSettle();
        final button = find.byKey(const ValueKey('coupon-create'));
        final before = tester.getRect(button);
        expect(before.right, lessThanOrEqualTo(width));
        await tester.ensureVisible(find.text('dd/mm/yyyy'));
        await tester.pumpAndSettle();
        expect(
          tester.getRect(find.text('dd/mm/yyyy')).bottom,
          lessThanOrEqualTo(tester.getRect(find.byType(CouponFooter)).top),
        );
        expect(tester.getRect(button), before);
        if (width < 960) {
          await tester.tap(find.byTooltip('Mở menu quản trị'));
          await tester.pumpAndSettle();
          final target = find.byKey(const ValueKey('admin-nav-orders'));
          await tester.ensureVisible(target);
          await tester.tap(target);
          await tester.pumpAndSettle();
          expect(find.byType(Drawer), findsNothing);
        }
        expect(tester.takeException(), isNull);
      },
    );
  }
}
