import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_admin/app.dart';
import 'package:lenlab_admin/features/orders/data/admin_orders_source.dart';
import 'package:lenlab_admin/features/orders/data/admin_order_detail.dart';
import 'package:lenlab_admin/features/orders/presentation/admin_order_detail_page.dart';
import 'package:lenlab_admin/features/auth/presentation/admin_login_page.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

import 'support/admin_test_session.dart';

class ControlledDetail extends MockAdminOrdersSource {
  final requests = <(String, Completer<AdminOrderDetail?>)>[];
  @override
  Future<AdminOrderDetail?> detail(String id) {
    final request = Completer<AdminOrderDetail?>();
    requests.add((id, request));
    return request.future;
  }
}

Widget host(String? id, AdminOrdersSource source) => MaterialApp(
  theme: P2.theme(admin: true),
  home: Scaffold(
    body: AdminOrderDetailPage(id: id, source: source),
  ),
);
void viewport(WidgetTester tester, {double width = 1280}) {
  tester.view.physicalSize = Size(width, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  test(
    'List and detail share exact summary; only matching ID has P2 supplements',
    () async {
      final source = MockAdminOrdersSource(latency: Duration.zero);
      for (var page = 1; page <= 3; page++) {
        final list = await source.fetch(AdminOrdersQuery(page: page));
        for (final summary in list.items) {
          final detail = (await source.detail(summary.id))!;
          expect(identical(detail.summary, summary), isTrue);
          if (summary.id == 'ORD-202502') {
            expect(detail.subtotal, 470000);
            expect(
              detail.subtotal! + detail.shipping! - detail.discount!,
              summary.total,
            );
            expect(detail.email, 'tranthib@example.com');
            expect(() => detail.lines.clear(), throwsUnsupportedError);
          } else {
            expect(detail.lines, isEmpty);
            expect(detail.shipping, isNull);
            expect(detail.address, isNull);
          }
        }
      }
      expect(await source.detail('not-found'), isNull);
      expect(await source.detail(''), isNull);
    },
  );
  testWidgets(
    'Loading, retry, matching data, disabled writes and missing payment history',
    (tester) async {
      viewport(tester);
      final source = MockAdminOrdersSource()..failNext = true;
      await tester.pumpWidget(host('ORD-202502', source));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('Không thể tải chi tiết đơn hàng'), findsOneWidget);
      await tester.tap(find.text('Thử lại'));
      await tester.pumpAndSettle();
      expect(find.text('#ORD-202502'), findsOneWidget);
      expect(find.text('Đang giao'), findsOneWidget);
      expect(find.text('Ngày đặt: 19/10/2023'), findsOneWidget);
      expect(find.text('Len Milk Cotton 125g'), findsOneWidget);
      expect(find.text('500.000₫'), findsOneWidget);
      expect(find.text('Trạng thái: Chưa có dữ liệu xác nhận'), findsOneWidget);
      expect(find.text('Chưa có dữ liệu lịch sử đơn hàng.'), findsOneWidget);
      expect(find.textContaining('Minh chứng'), findsNothing);
      for (final label in ['Duyệt đơn', 'Hủy đơn', 'Sửa']) {
        final button = find.ancestor(
          of: find.text(label),
          matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
        );
        expect(tester.widget<ButtonStyleButton>(button).onPressed, isNull);
      }
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'Missing ID avoids loading; unknown ID and wrong record do not leak detail',
    (tester) async {
      final source = ControlledDetail();
      await tester.pumpWidget(host(null, source));
      await tester.pumpAndSettle();
      expect(source.requests, isEmpty);
      expect(find.text('Thiếu mã đơn hàng'), findsOneWidget);
      await tester.pumpWidget(host('unknown', source));
      source.requests.last.$2.complete(null);
      await tester.pumpAndSettle();
      expect(find.text('Không tìm thấy đơn hàng'), findsOneWidget);
      await tester.pumpWidget(host('ORD-202501', source));
      source.requests.last.$2.complete(
        mockAdminOrderDetail(adminOrderFixtures[1]),
      );
      await tester.pumpAndSettle();
      expect(find.text('Dữ liệu đơn hàng không khớp mã'), findsOneWidget);
      expect(find.text('tranthib@example.com'), findsNothing);
      expect(find.text('Len Milk Cotton 125g'), findsNothing);
    },
  );
  testWidgets(
    'Changed ID ignores old result and disposal ignores late errors',
    (tester) async {
      final source = ControlledDetail();
      await tester.pumpWidget(host('ORD-202502', source));
      await tester.pumpWidget(host('ORD-202501', source));
      source.requests.last.$2.complete(
        mockAdminOrderDetail(adminOrderFixtures.first),
      );
      await tester.pumpAndSettle();
      source.requests.first.$2.complete(
        mockAdminOrderDetail(adminOrderFixtures[1]),
      );
      await tester.pumpAndSettle();
      expect(find.text('#ORD-202501'), findsOneWidget);
      expect(find.text('Len Milk Cotton 125g'), findsNothing);
      expect(
        find.text('Chưa có dữ liệu sản phẩm của đơn hàng này.'),
        findsOneWidget,
      );
      await tester.pumpWidget(host('ORD-202503', source));
      await tester.pumpWidget(const SizedBox());
      source.requests.last.$2.completeError(StateError('Late error'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'Direct URL returns to orders and session guard protects details',
    (tester) async {
      viewport(tester);
      final active = await createSession();
      await tester.pumpWidget(
        AdminApp(session: active, initialRoute: '/orders/detail?id=ORD-202502'),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AdminOrderDetailPage), findsOneWidget);
      await tester.tap(find.byTooltip('Về danh sách đơn hàng'));
      await tester.pumpAndSettle();
      expect(find.text('Danh sách đơn hàng'), findsOneWidget);
      active.signOut();
      await tester.pumpAndSettle();
      tester
          .state<NavigatorState>(find.byType(Navigator))
          .pushNamed('/orders/detail?id=ORD-202502');
      await tester.pumpAndSettle();
      expect(find.byType(AdminLoginPage), findsOneWidget);
      expect(find.byType(AdminOrderDetailPage), findsNothing);
    },
  );
  for (final width in [390.0, 800.0, 1280.0]) {
    testWidgets('Detail at $width and 120% text stays usable', (tester) async {
      viewport(tester, width: width);
      tester.platformDispatcher.textScaleFactorTestValue = 1.2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(host('ORD-202502', MockAdminOrdersSource()));
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.text('Chưa có dữ liệu lịch sử đơn hàng.'),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
