import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_admin/app.dart';
import 'package:lenlab_admin/features/auth/presentation/admin_login_page.dart';
import 'package:lenlab_admin/features/customers/data/admin_customers_source.dart';
import 'package:lenlab_admin/features/customers/data/admin_customer_detail.dart';
import 'package:lenlab_admin/features/customers/presentation/admin_customer_detail_page.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

import 'support/admin_test_session.dart';

class ControlledCustomerDetail extends MockAdminCustomersSource {
  final requests = <(String, Completer<AdminCustomerDetail?>)>[];
  @override
  Future<AdminCustomerDetail?> detail(String id) {
    final request = Completer<AdminCustomerDetail?>();
    requests.add((id, request));
    return request.future;
  }
}

Widget host(String? id, AdminCustomersSource source) => MaterialApp(
  theme: P2.theme(admin: true),
  home: Scaffold(
    body: AdminCustomerDetailPage(id: id, source: source),
  ),
);
void viewport(WidgetTester tester, {double width = 1280}) {
  tester.view.physicalSize = Size(width, 1500);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  test('Every detail uses exact list record; no unrelated P2 supplement is assigned', () async {
    final source = MockAdminCustomersSource(latency: Duration.zero);
    for (var page = 1; page <= 3; page++) {
      final list = await source.fetch(AdminCustomersQuery(page: page));
      for (final customer in list.items) {
        final detail = (await source.detail(customer.id))!;
        expect(identical(customer, detail.customer), isTrue);
        expect(detail.joinedAt, isNull);
        expect(detail.totalSpent, isNull);
        expect(detail.membership, isNull);
        expect(detail.defaultAddress, isNull);
      }
    }
    expect(await source.detail('unknown'), isNull);
    expect(await source.detail(''), isNull);
  });
  testWidgets(
    'Loading error retry displays source identity and explicit missing metadata',
    (tester) async {
      viewport(tester);
      final source = MockAdminCustomersSource()..failNext = true;
      await tester.pumpWidget(host('USR-001', source));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('Không thể tải chi tiết người dùng'), findsOneWidget);
      await tester.tap(find.text('Thử lại'));
      await tester.pumpAndSettle();
      expect(find.text('huy.nguyen@example.com'), findsOneWidget);
      expect(find.text('0912 345 678'), findsOneWidget);
      expect(find.text('Chưa có dữ liệu'), findsNWidgets(4));
      expect(find.text('Nguyễn Văn A'), findsNothing);
      expect(find.text('Gold Member'), findsNothing);
      expect(find.text('12.540.000₫'), findsNothing);
      expect(
        find.textContaining('Chưa có dữ liệu lịch sử mua hàng liên kết'),
        findsOneWidget,
      );
      expect(find.text('#ORD-2023-1001'), findsNothing);
      final save = find.ancestor(
        of: find.text('Lưu thay đổi'),
        matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
      );
      expect(tester.widget<ButtonStyleButton>(save).onPressed, isNull);
      final toggle = tester.widget<Switch>(find.byType(Switch));
      expect(toggle.value, isFalse);
      expect(toggle.onChanged, isNull);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'Missing ID, unknown ID and mismatched result never show another profile',
    (tester) async {
      final source = ControlledCustomerDetail();
      await tester.pumpWidget(host(null, source));
      await tester.pumpAndSettle();
      expect(source.requests, isEmpty);
      expect(find.text('Thiếu mã người dùng'), findsOneWidget);
      await tester.pumpWidget(host('unknown', source));
      source.requests.last.$2.complete(null);
      await tester.pumpAndSettle();
      expect(find.text('Không tìm thấy người dùng'), findsOneWidget);
      await tester.pumpWidget(host('USR-003', source));
      source.requests.last.$2.complete(
        AdminCustomerDetail(customer: adminCustomerFixtures.first),
      );
      await tester.pumpAndSettle();
      expect(find.text('Dữ liệu người dùng không khớp mã'), findsOneWidget);
      expect(find.text('huy.nguyen@example.com'), findsNothing);
    },
  );
  testWidgets('Changing ID and disposal ignore old results and late errors', (
    tester,
  ) async {
    final source = ControlledCustomerDetail();
    await tester.pumpWidget(host('USR-001', source));
    await tester.pumpWidget(host('USR-003', source));
    source.requests.last.$2.complete(
      AdminCustomerDetail(customer: adminCustomerFixtures[2]),
    );
    await tester.pumpAndSettle();
    source.requests.first.$2.complete(
      AdminCustomerDetail(customer: adminCustomerFixtures.first),
    );
    await tester.pumpAndSettle();
    expect(find.text('tuananh.le@example.com'), findsOneWidget);
    expect(find.text('huy.nguyen@example.com'), findsNothing);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
    expect(tester.widget<Switch>(find.byType(Switch)).onChanged, isNull);
    await tester.pumpWidget(host('USR-004', source));
    await tester.pumpWidget(const SizedBox());
    source.requests.last.$2.completeError(StateError('Late error'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'List navigation uses injected source and Back retains query and page',
    (tester) async {
      viewport(tester);
      final active = await createSession();
      await tester.pumpWidget(
        AdminApp(
          session: active,
          initialRoute: '/customers',
          customersSource: MockAdminCustomersSource(
            customers: [
              ...adminCustomerFixtures,
              const AdminCustomer(
                id: 'shared-only',
                name: 'Người dùng riêng',
                email: 'shared-only@example.com',
                phone: 'Chưa có SĐT',
                role: AdminCustomerRole.customer,
                status: AdminCustomerStatus.active,
                initials: 'NR',
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Trang 2'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('customer-detail-DEMO-USR-005')),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AdminCustomerDetailPage), findsOneWidget);
      expect(find.text('demo5@example.com'), findsOneWidget);
      await tester.tap(find.text('Quay lại'));
      await tester.pumpAndSettle();
      expect(find.text('Hiển thị 5-8 trong số 11 người dùng'), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('customers-search')),
        'linh.tran',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('customer-detail-USR-002')));
      await tester.pumpAndSettle();
      expect(find.text('Vai trò: Nhân viên'), findsOneWidget);
      await tester.ensureVisible(find.text('Đóng'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Đóng'));
      await tester.pumpAndSettle();
      expect(find.text('Hiển thị 1-1 trong số 1 người dùng'), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('customers-search')),
        'shared-only@example.com',
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('customer-detail-shared-only')),
      );
      await tester.pumpAndSettle();
      expect(find.text('shared-only@example.com'), findsOneWidget);
    },
  );
  testWidgets(
    'Direct URL returns to list; unauthenticated profile remains guarded',
    (tester) async {
      viewport(tester);
      final active = await createSession();
      await tester.pumpWidget(
        AdminApp(session: active, initialRoute: '/customers/detail?id=USR-004'),
      );
      await tester.pumpAndSettle();
      expect(find.text('mai.pham@example.com'), findsOneWidget);
      await tester.tap(find.text('Quay lại'));
      await tester.pumpAndSettle();
      expect(find.text('Quản lý người dùng'), findsOneWidget);
      active.signOut();
      await tester.pumpAndSettle();
      tester
          .state<NavigatorState>(find.byType(Navigator))
          .pushNamed('/customers/detail?id=USR-004');
      await tester.pumpAndSettle();
      expect(find.byType(AdminLoginPage), findsOneWidget);
      expect(find.byType(AdminCustomerDetailPage), findsNothing);
    },
  );
  for (final width in [390.0, 800.0, 1280.0]) {
    testWidgets('Customer detail at $width / 120% text remains usable', (
      tester,
    ) async {
      viewport(tester, width: width);
      tester.platformDispatcher.textScaleFactorTestValue = 1.2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(host('USR-001', MockAdminCustomersSource()));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Lưu thay đổi'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
