import 'dart:async';

import 'support/admin_test_session.dart';

import 'package:lenlab_admin/app.dart';
import 'package:lenlab_admin/features/orders/data/admin_order_detail.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_admin/features/orders/data/admin_orders_source.dart';
import 'package:lenlab_admin/features/orders/presentation/admin_orders_content.dart';
import 'package:lenlab_admin/features/orders/presentation/widgets/orders_table.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

Widget host(AdminOrdersSource source) => MaterialApp(
  theme: P2.theme(admin: true),
  home: Scaffold(
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: AdminOrdersContent(source: source),
    ),
  ),
);

class ControlledOrders implements AdminOrdersSource {
  @override
  Future<AdminOrderDetail?> detail(String id) async => null;
  final requests = <(AdminOrdersQuery, Completer<AdminOrdersResult>)>[];
  @override
  Future<AdminOrdersResult> fetch(AdminOrdersQuery query) {
    final completer = Completer<AdminOrdersResult>();
    requests.add((query, completer));
    return completer.future;
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
  test('Source combines ID/name, status and payment before paging; preserves fixtures', () async {
    final source = MockAdminOrdersSource(latency: Duration.zero);
    final first = await source.fetch(const AdminOrdersQuery());
    final second = await source.fetch(const AdminOrdersQuery(page: 2));
    expect(first.total, 12);
    expect(first.start, 1);
    expect(first.end, 5);
    expect(first.pages, 3);
    expect(first.items.first.placedAt, DateTime(2023, 10, 20));
    expect(second.start, 6);
    expect(second.end, 10);
    expect(
      first.items
          .map((o) => o.id)
          .toSet()
          .intersection(second.items.map((o) => o.id).toSet()),
      isEmpty,
    );
    final last = await source.fetch(const AdminOrdersQuery(page: 100));
    expect(last.page, 3);
    expect(last.end, 12);
    final named = await source.fetch(
      const AdminOrdersQuery(
        search: '  TRẦN THỊ B ',
        status: AdminOrderStatus.shipping,
        payment: AdminOrderPayment.bankTransfer,
      ),
    );
    expect(named.items.single.id, 'ORD-202502');
    final id = await source.fetch(
      const AdminOrdersQuery(search: '#ORD-202502'),
    );
    // Displayed IDs include a #; the mock supports copying that identifier.
    expect(id.items.single.id, 'ORD-202502');
    final empty = await source.fetch(
      const AdminOrdersQuery(
        search: 'ORD-202502',
        payment: AdminOrderPayment.cod,
      ),
    );
    expect(empty.total, 0);
    expect(empty.start, 0);
    expect(empty.end, 0);
    expect(() => first.items.clear(), throwsUnsupportedError);
  });

  testWidgets(
    'Loading, search and combined filters reset pagination and clear no matches',
    (tester) async {
      viewport(tester);
      await tester.pumpWidget(host(MockAdminOrdersSource()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('Hiển thị 1-5 trong số 12 đơn hàng'), findsOneWidget);
      await tester.tap(find.byTooltip('Trang 2'));
      await tester.pumpAndSettle();
      expect(find.text('Hiển thị 6-10 trong số 12 đơn hàng'), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('orders-search')),
        'ORD-2025',
      );
      await tester.pumpAndSettle();
      expect(find.text('Hiển thị 1-5 trong số 5 đơn hàng'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('orders-status')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Đang giao').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('orders-payment')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('CK').last);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('order-id-ORD-202502')), findsOneWidget);
      expect(find.byKey(const ValueKey('order-id-ORD-202501')), findsNothing);
      await tester.tap(find.byKey(const ValueKey('orders-payment')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('COD').last);
      await tester.pumpAndSettle();
      expect(find.text('Không có đơn hàng'), findsOneWidget);
      await tester.tap(find.text('Xóa bộ lọc'));
      await tester.pumpAndSettle();
      expect(find.text('Hiển thị 1-5 trong số 12 đơn hàng'), findsOneWidget);
    },
  );

  testWidgets('Retry preserves page and filters; last page has no next', (
    tester,
  ) async {
    viewport(tester);
    final source = MockAdminOrdersSource();
    await tester.pumpWidget(host(source));
    await tester.pumpAndSettle();
    source.failNext = true;
    await tester.tap(find.byTooltip('Trang 2'));
    await tester.pumpAndSettle();
    expect(find.text('Không thể tải danh sách đơn hàng'), findsOneWidget);
    expect(find.byType(OrdersTable), findsNothing);
    await tester.tap(find.text('Thử lại'));
    await tester.pumpAndSettle();
    expect(find.text('Hiển thị 6-10 trong số 12 đơn hàng'), findsOneWidget);
    expect(find.text('Chưa có ngày đặt'), findsWidgets);
    await tester.tap(find.byTooltip('Trang sau'));
    await tester.pumpAndSettle();
    expect(find.text('Hiển thị 11-12 trong số 12 đơn hàng'), findsOneWidget);
    final next = find.descendant(
      of: find.byTooltip('Trang sau'),
      matching: find.byType(OutlinedButton),
    );
    expect(tester.widget<OutlinedButton>(next).onPressed, isNull);
    source.failNext = true;
    await tester.enterText(
      find.byKey(const ValueKey('orders-search')),
      '202503',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Thử lại'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('order-id-ORD-202503')), findsOneWidget);
  });

  testWidgets('Newer query wins over old success and error', (tester) async {
    viewport(tester);
    final source = ControlledOrders();
    await tester.pumpWidget(host(source));
    await tester.enterText(find.byKey(const ValueKey('orders-search')), 'Trần');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(
      find.byKey(const ValueKey('orders-search')),
      'Nguyễn',
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(source.requests.length, 3);
    source.requests.last.$2.complete(
      AdminOrdersResult(items: [adminOrderFixtures.first], total: 1, page: 1),
    );
    await tester.pumpAndSettle();
    source.requests[1].$2.completeError(StateError('Old error'));
    source.requests.first.$2.complete(
      AdminOrdersResult(items: [adminOrderFixtures[1]], total: 1, page: 1),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('order-id-ORD-202501')), findsOneWidget);
    expect(find.byKey(const ValueKey('order-id-ORD-202502')), findsNothing);
    expect(find.text('Không thể tải danh sách đơn hàng'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Empty source is explicit and pending request is safe on disposal',
    (tester) async {
      await tester.pumpWidget(host(MockAdminOrdersSource(orders: [])));
      await tester.pumpAndSettle();
      expect(find.text('Danh sách đơn hàng hiện đang trống.'), findsOneWidget);
      final source = ControlledOrders();
      await tester.pumpWidget(host(source));
      await tester.enterText(
        find.byKey(const ValueKey('orders-search')),
        'ABC',
      );
      await tester.pumpWidget(const SizedBox());
      source.requests.single.$2.completeError(StateError('Late error'));
      await tester.pumpAndSettle();
      expect(source.requests.length, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Detail opens selected ID and Back retains list search without proof or writes',
    (tester) async {
      viewport(tester);
      await tester.pumpWidget(
        AdminApp(session: await createSession(), initialRoute: '/orders'),
      );
      await tester.pumpAndSettle();
      final create = find.ancestor(
        of: find.text('Tạo đơn hàng'),
        matching: find.byWidgetPredicate(
          (widget) => widget is ButtonStyleButton,
        ),
      );
      expect(tester.widget<ButtonStyleButton>(create).onPressed, isNull);
      expect(find.text('MINH CHỨNG'), findsNothing);
      await tester.enterText(
        find.byKey(const ValueKey('orders-search')),
        '202504',
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('order-detail-ORD-202504')));
      await tester.pumpAndSettle();
      expect(find.text('#ORD-202504'), findsOneWidget);
      expect(find.text('Đã hủy'), findsOneWidget);
      await tester.tap(find.byTooltip('Về danh sách đơn hàng'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byKey(const ValueKey('order-id-ORD-202504')), findsOneWidget);
      await tester.tap(find.byTooltip('Bộ lọc đơn hàng đang áp dụng'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Xóa bộ lọc'));
      await tester.pumpAndSettle();
      expect(find.text('Hiển thị 1-5 trong số 12 đơn hàng'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  for (final width in [390.0, 800.0, 1280.0]) {
    testWidgets('Order table adapts at $width with 120% text', (tester) async {
      viewport(tester, width: width, scale: 1.2);
      await tester.pumpWidget(host(MockAdminOrdersSource()));
      await tester.pumpAndSettle();
      final horizontal = find.descendant(
        of: find.byType(OrdersTable),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is SingleChildScrollView &&
              widget.scrollDirection == Axis.horizontal,
        ),
      );
      await tester.drag(horizontal, const Offset(-900, 0));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
