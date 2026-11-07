import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_admin/app.dart';
import 'package:lenlab_admin/features/auth/presentation/admin_login_page.dart';
import 'package:lenlab_admin/features/coupons/data/admin_percentage_coupon_source.dart';
import 'package:lenlab_admin/features/coupons/presentation/admin_percentage_coupon_page.dart';
import 'package:lenlab_admin/features/coupons/presentation/widgets/coupon_header_footer.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

import 'support/admin_test_session.dart';

void viewport(WidgetTester tester, {double width = 1280}) {
  tester.view.physicalSize = Size(width, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Widget host(AdminPercentageCouponSource source) => MaterialApp(
  theme: P2.theme(admin: true),
  home: Scaffold(body: AdminPercentageCouponPage(source: source)),
);

class ControlledCoupon implements AdminPercentageCouponSource {
  final result = Completer<AdminPercentageCoupon?>();
  @override
  Future<AdminPercentageCoupon?> fetch() => result.future;
}

Finder create = find.byKey(const ValueKey('coupon-create'));
Finder draft = find.byKey(const ValueKey('coupon-draft'));

void main() {
  test('P2 numbers and date are a display fixture; examples are not a saved code, limit or expiry', () async {
    final source = MockAdminPercentageCouponSource(latency: Duration.zero);
    final sample = (await source.fetch())!;
    expect(sample, same(adminPercentageCouponFixture));
    expect(sample.percentage, 20);
    expect(sample.maximumDiscount, 50000);
    expect(sample.minimumOrder, 0);
    expect(sample.startDateLabel, '12/05/2024');
    expect(sample.code, isNull);
    expect(sample.quantityLimit, isNull);
    expect(sample.expiryDateLabel, isNull);
    source.failNext = true;
    await expectLater(source.fetch(), throwsStateError);
    expect(await source.fetch(), same(sample));
    expect(
      await MockAdminPercentageCouponSource(
        latency: Duration.zero,
        example: null,
      ).fetch(),
      isNull,
    );
  });
  testWidgets(
    'Loading, exact fields/placeholders and disabled creation without editors or date picker',
    (tester) async {
      viewport(tester);
      await tester.pumpWidget(host(MockAdminPercentageCouponSource()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
      for (final value in [
        'VÍ DỤ: LENLABSALE50',
        '20',
        '50.000',
        '0',
        '12/05/2024',
        'dd/mm/yyyy',
        'Nhập số lượng mã (ví dụ: 100)',
        'Theo %',
        'Số tiền cố định',
      ]) {
        expect(find.text(value), findsOneWidget);
      }
      expect(find.byType(TextField), findsNothing);
      expect(find.byType(DatePickerDialog), findsNothing);
      expect(tester.widget<FilledButton>(draft).onPressed, isNull);
      expect(tester.widget<FilledButton>(create).onPressed, isNull);
      await tester.tap(create);
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);
      expect(find.byType(AlertDialog), findsNothing);
      expect(
        tester
            .widget<Semantics>(
              find.byKey(const ValueKey('coupon-type-percentage')),
            )
            .properties
            .selected,
        isTrue,
      );
      expect(
        tester
            .widget<Semantics>(find.byKey(const ValueKey('coupon-type-fixed')))
            .properties
            .selected,
        isFalse,
      );
    },
  );
  testWidgets(
    'Empty source, unknown fields and known zero quantities are distinct',
    (tester) async {
      viewport(tester);
      await tester.pumpWidget(
        host(MockAdminPercentageCouponSource(example: null)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Chưa có dữ liệu mẫu mã giảm giá'), findsOneWidget);
      expect(find.text('20'), findsNothing);
      await tester.pumpWidget(
        host(
          MockAdminPercentageCouponSource(
            example: const AdminPercentageCoupon(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Chưa có dữ liệu'), findsNWidgets(4));
      expect(find.text('0'), findsNothing);
      expect(find.text('50.000'), findsNothing);
      await tester.pumpWidget(
        host(
          MockAdminPercentageCouponSource(
            example: const AdminPercentageCoupon(
              code: 'MOCKONLY',
              quantityLimit: 0,
              expiryDateLabel: 'Chưa chốt định dạng',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('MOCKONLY'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(find.text('Nhập số lượng mã (ví dụ: 100)'), findsNothing);
      expect(find.text('Chưa chốt định dạng'), findsOneWidget);
      expect(tester.widget<FilledButton>(create).onPressed, isNull);
    },
  );
  testWidgets(
    'Error retry uses same source, no previous example during loading',
    (tester) async {
      viewport(tester);
      final source = MockAdminPercentageCouponSource()..failNext = true;
      await tester.pumpWidget(host(source));
      await tester.pumpAndSettle();
      expect(find.text('Không thể tải mẫu mã giảm giá'), findsOneWidget);
      await tester.tap(find.text('Thử lại'));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('20'), findsNothing);
      await tester.pumpAndSettle();
      expect(find.text('20'), findsOneWidget);
    },
  );
  testWidgets(
    'Changing source hides old data and ignores late results/errors after disposal',
    (tester) async {
      viewport(tester);
      final old = ControlledCoupon();
      final fresh = ControlledCoupon();
      await tester.pumpWidget(host(old));
      await tester.pumpWidget(host(fresh));
      fresh.result.complete(const AdminPercentageCoupon(code: 'CURRENT'));
      await tester.pumpAndSettle();
      old.result.complete(adminPercentageCouponFixture);
      await tester.pumpAndSettle();
      expect(find.text('CURRENT'), findsOneWidget);
      expect(find.text('20'), findsNothing);
      final error = ControlledCoupon();
      await tester.pumpWidget(host(error));
      await tester.pump();
      expect(find.text('CURRENT'), findsNothing);
      final current = ControlledCoupon();
      await tester.pumpWidget(host(current));
      error.result.completeError(StateError('stale'));
      current.result.complete(null);
      await tester.pumpAndSettle();
      expect(find.text('Không thể tải mẫu mã giảm giá'), findsNothing);
      expect(find.text('Chưa có dữ liệu mẫu mã giảm giá'), findsOneWidget);
      final disposed = ControlledCoupon();
      await tester.pumpWidget(host(disposed));
      await tester.pumpWidget(const SizedBox());
      disposed.result.completeError(StateError('disposed'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'Route guard, App source, Cancel/overview breadcrumb, Back and logout',
    (tester) async {
      viewport(tester);
      await tester.pumpWidget(
        const AdminApp(initialRoute: '/vouchers/percentage'),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AdminLoginPage), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(
        AdminApp(
          initialRoute: '/vouchers/percentage',
          session: await createSession(),
          percentageCouponSource: MockAdminPercentageCouponSource(
            example: const AdminPercentageCoupon(code: 'APPSOURCE'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('admin-nav-percentageCoupon')),
      );
      await tester.pumpAndSettle();
      expect(find.text('APPSOURCE'), findsOneWidget);
      expect(
        tester
            .widget<Semantics>(
              find.byKey(const ValueKey('admin-nav-percentageCoupon')),
            )
            .properties
            .selected,
        isTrue,
      );
      await tester.tap(find.byKey(const ValueKey('coupon-cancel')));
      await tester.pumpAndSettle();
      expect(find.byType(AdminPercentageCouponPage), findsNothing);
      await tester.tap(
        find.byKey(const ValueKey('admin-nav-percentageCoupon')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('coupon-parent-breadcrumb')));
      await tester.pumpAndSettle();
      expect(find.byType(AdminPercentageCouponPage), findsNothing);
      await tester.tap(
        find.byKey(const ValueKey('admin-nav-percentageCoupon')),
      );
      await tester.pumpAndSettle();
      tester.state<NavigatorState>(find.byType(Navigator)).pop();
      await tester.pumpAndSettle();
      expect(find.byType(AdminPercentageCouponPage), findsNothing);
      expect(find.byKey(const ValueKey('admin-nav-dashboard')), findsOneWidget);
      await tester.tap(find.byTooltip('Đăng xuất'));
      await tester.pumpAndSettle();
      expect(find.byType(AdminLoginPage), findsOneWidget);
      expect(find.byType(AdminPercentageCouponPage), findsNothing);
      expect(
        tester.state<NavigatorState>(find.byType(Navigator)).canPop(),
        isFalse,
      );
    },
  );
  for (final width in [390.0, 800.0, 1280.0]) {
    testWidgets(
      'Web $width text120 wrapping and fixed footer, final field reachable, Drawer navigation',
      (tester) async {
        viewport(tester, width: width);
        tester.platformDispatcher.textScaleFactorTestValue = 1.2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpWidget(
          AdminApp(
            initialRoute: '/vouchers/percentage',
            session: await createSession(),
          ),
        );
        await tester.pumpAndSettle();
        final before = tester.getRect(create);
        expect(before.right, lessThanOrEqualTo(width));
        expect(before.bottom, lessThanOrEqualTo(1400));
        await tester.ensureVisible(find.text('dd/mm/yyyy'));
        await tester.pumpAndSettle();
        expect(
          tester.getRect(find.text('dd/mm/yyyy')).bottom,
          lessThanOrEqualTo(tester.getRect(find.byType(CouponFooter)).top),
        );
        expect(tester.getRect(create), before);
        expect(find.byType(TextField), findsNothing);
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
