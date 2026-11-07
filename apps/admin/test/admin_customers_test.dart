import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_admin/app.dart';
import 'package:lenlab_admin/features/auth/presentation/admin_login_page.dart';
import 'package:lenlab_admin/features/customers/data/admin_customers_source.dart';
import 'package:lenlab_admin/features/customers/data/admin_customer_detail.dart';
import 'package:lenlab_admin/features/customers/presentation/admin_customers_content.dart';
import 'package:lenlab_admin/features/customers/presentation/widgets/customers_header.dart';
import 'package:lenlab_admin/features/customers/presentation/widgets/customers_table.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

Widget host(AdminCustomersSource source) => MaterialApp(
  theme: P2.theme(admin: true),
  home: Scaffold(
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: AdminCustomersContent(source: source),
    ),
  ),
);

class ControlledCustomers implements AdminCustomersSource {
  @override
  Future<AdminCustomerDetail?> detail(String id) async => null;
  final requests = <Completer<AdminCustomersResult>>[];
  @override
  Future<AdminCustomersResult> fetch(AdminCustomersQuery query) {
    final request = Completer<AdminCustomersResult>();
    requests.add(request);
    return request.future;
  }
}

void viewport(WidgetTester tester, {double width = 1280, double scale = 1}) {
  tester.view.physicalSize = Size(width, 1400);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

void main() {
  test(
    'Source filters name/email/phone with role/status before pagination',
    () async {
      final source = MockAdminCustomersSource(latency: Duration.zero);
      final first = await source.fetch(const AdminCustomersQuery());
      final second = await source.fetch(const AdminCustomersQuery(page: 2));
      expect(first.total, 10);
      expect(first.start, 1);
      expect(first.end, 4);
      expect(first.pages, 3);
      expect(first.items[1].orderCount, isNull);
      expect(second.start, 5);
      expect(second.end, 8);
      expect(
        first.items
            .map((c) => c.id)
            .toSet()
            .intersection(second.items.map((c) => c.id).toSet()),
        isEmpty,
      );
      final last = await source.fetch(const AdminCustomersQuery(page: 100));
      expect(last.page, 3);
      expect(last.end, 10);
      for (final search in [
        '  LÊ TUẤN ANH ',
        'TUANANH.LE@EXAMPLE.COM',
        '0909000111',
        '0909-000-111',
      ]) {
        final result = await source.fetch(
          AdminCustomersQuery(
            search: search,
            role: AdminCustomerRole.customer,
            status: AdminCustomerStatus.blocked,
          ),
        );
        expect(result.items.single.id, 'USR-003');
      }
      final empty = await source.fetch(
        const AdminCustomersQuery(
          search: 'tuananh',
          role: AdminCustomerRole.staff,
        ),
      );
      expect(empty.total, 0);
      expect(empty.start, 0);
      expect(empty.end, 0);
      expect(() => first.items.clear(), throwsUnsupportedError);
    },
  );
  testWidgets('Loading, paging reset, combined filters and clear no matches', (
    tester,
  ) async {
    viewport(tester);
    await tester.pumpWidget(host(MockAdminCustomersSource()));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('Hiển thị 1-4 trong số 10 người dùng'), findsOneWidget);
    await tester.tap(find.byTooltip('Trang 2'));
    await tester.pumpAndSettle();
    expect(find.text('Hiển thị 5-8 trong số 10 người dùng'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('customers-search')),
      '0909000111',
    );
    await tester.pumpAndSettle();
    expect(find.text('Hiển thị 1-1 trong số 1 người dùng'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('customers-role')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nhân viên').last);
    await tester.pumpAndSettle();
    expect(find.text('Không có người dùng'), findsOneWidget);
    await tester.tap(find.text('Xóa bộ lọc'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('customers-role')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nhân viên').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('customers-status')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bị khóa').last);
    await tester.pumpAndSettle();
    expect(find.text('Người dùng minh họa 9'), findsOneWidget);
    expect(find.text('Trần Thị Linh'), findsNothing);
    expect(find.text('Hiển thị 1-1 trong số 1 người dùng'), findsOneWidget);
  });
  testWidgets(
    'Retry keeps requested page and search; last page disables next',
    (tester) async {
      viewport(tester);
      final source = MockAdminCustomersSource();
      await tester.pumpWidget(host(source));
      await tester.pumpAndSettle();
      source.failNext = true;
      await tester.tap(find.byTooltip('Trang 2'));
      await tester.pumpAndSettle();
      expect(find.text('Không thể tải danh sách người dùng'), findsOneWidget);
      expect(find.byType(CustomersTable), findsNothing);
      await tester.tap(find.text('Thử lại'));
      await tester.pumpAndSettle();
      expect(find.text('Hiển thị 5-8 trong số 10 người dùng'), findsOneWidget);
      await tester.tap(find.byTooltip('Trang sau'));
      await tester.pumpAndSettle();
      expect(find.text('Hiển thị 9-10 trong số 10 người dùng'), findsOneWidget);
      expect(
        tester
            .widget<OutlinedButton>(
              find.descendant(
                of: find.byTooltip('Trang sau'),
                matching: find.byType(OutlinedButton),
              ),
            )
            .onPressed,
        isNull,
      );
      source.failNext = true;
      await tester.enterText(
        find.byKey(const ValueKey('customers-search')),
        'mai.pham',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Thử lại'));
      await tester.pumpAndSettle();
      expect(find.text('Phạm Thị Mai'), findsOneWidget);
    },
  );
  testWidgets('Latest search wins over late success and error', (tester) async {
    viewport(tester);
    final source = ControlledCustomers();
    await tester.pumpWidget(host(source));
    await tester.enterText(
      find.byKey(const ValueKey('customers-search')),
      'Linh',
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(
      find.byKey(const ValueKey('customers-search')),
      'Huy',
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(source.requests.length, 3);
    source.requests.last.complete(
      AdminCustomersResult(
        items: [adminCustomerFixtures.first],
        total: 1,
        page: 1,
      ),
    );
    await tester.pumpAndSettle();
    source.requests[1].completeError(StateError('Old error'));
    source.requests.first.complete(
      AdminCustomersResult(
        items: [adminCustomerFixtures[1]],
        total: 1,
        page: 1,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Nguyễn Văn Huy'), findsOneWidget);
    expect(find.text('Trần Thị Linh'), findsNothing);
    expect(find.text('Không thể tải danh sách người dùng'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Empty source and disposal with pending debounce are safe', (
    tester,
  ) async {
    await tester.pumpWidget(host(MockAdminCustomersSource(customers: [])));
    await tester.pumpAndSettle();
    expect(find.text('Danh sách người dùng hiện đang trống.'), findsOneWidget);
    final source = ControlledCustomers();
    await tester.pumpWidget(host(source));
    await tester.enterText(
      find.byKey(const ValueKey('customers-search')),
      'ABC',
    );
    await tester.pumpWidget(const SizedBox());
    source.requests.single.completeError(StateError('Late error'));
    await tester.pumpAndSettle();
    expect(source.requests.length, 1);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Read-only toolbar, Enter/Escape and unauthenticated guard', (
    tester,
  ) async {
    viewport(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: P2.theme(admin: true),
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                const CustomersHeader(),
                AdminCustomersContent(source: MockAdminCustomersSource()),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final add = find.ancestor(
      of: find.text('Thêm người dùng'),
      matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
    );
    expect(tester.widget<ButtonStyleButton>(add).onPressed, isNull);
    expect(find.byType(Switch), findsNothing);
    await tester.enterText(
      find.byKey(const ValueKey('customers-search')),
      'linh.tran',
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Trần Thị Linh'), findsOneWidget);
    expect(find.text('0 đơn'), findsNothing);
    await tester.tap(find.byTooltip('Bộ lọc người dùng đang áp dụng'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    await tester.pumpWidget(const AdminApp(initialRoute: '/customers'));
    await tester.pumpAndSettle();
    expect(find.byType(AdminLoginPage), findsOneWidget);
    expect(find.byType(CustomersTable), findsNothing);
  });
  for (final width in [390.0, 800.0, 1280.0]) {
    testWidgets('Customer table at $width with 120% text', (tester) async {
      viewport(tester, width: width, scale: 1.2);
      await tester.pumpWidget(host(MockAdminCustomersSource()));
      await tester.pumpAndSettle();
      final horizontal = find.descendant(
        of: find.byType(CustomersTable),
        matching: find.byWidgetPredicate(
          (w) =>
              w is SingleChildScrollView &&
              w.scrollDirection == Axis.horizontal,
        ),
      );
      await tester.drag(horizontal, const Offset(-900, 0));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
