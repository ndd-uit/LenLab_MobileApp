import 'package:lenlab_customer/features/auth/presentation/auth_page.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_customer/app/customer_app.dart';
import 'package:lenlab_customer/app/customer_scope.dart';
import 'package:lenlab_customer/features/orders/presentation/order_list_page.dart';
import 'package:lenlab_customer/features/orders/presentation/widgets/order_list_card.dart';
import 'package:lenlab_customer/features/orders/presentation/widgets/order_detail_information.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

Widget app(LenlabStore store, {OrderListSource? source}) => CustomerScope(
  store: store,
  child: MaterialApp(
    theme: P2.theme(),
    home: OrderListPage(source: source),
  ),
);

void main() {
  testWidgets('horizontal tabs reach cancelled and open its own detail', (
    tester,
  ) async {
    final store =
        LenlabStore(repository: MockLenlabRepository(latency: Duration.zero))
          ..signedIn = true
          ..coupon = 'LEN50';
    await tester.pumpWidget(CustomerApp(store: store, initialRoute: '/orders'));
    await tester.pumpAndSettle();
    final tab = find.byKey(const ValueKey('order-tab-cancelled'));
    await tester.ensureVisible(tab);
    await tester.tap(tab);
    await tester.pumpAndSettle();
    expect(find.text('Mã đơn: #WOOL-8750'), findsOneWidget);
    expect(find.byType(OrderListCard), findsOneWidget);
    await tester.tap(find.text('Xem lại'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<OrderDetailInformation>(find.byType(OrderDetailInformation))
          .order
          .id,
      'WOOL-8750',
    );
    expect(store.orders[3].state, OrderState.cancelled);
  });

  testWidgets('pull to refresh reads new data from the same source', (
    tester,
  ) async {
    final store =
        LenlabStore(repository: MockLenlabRepository(latency: Duration.zero))
          ..signedIn = true
          ..coupon = 'LEN50';
    await tester.pumpWidget(app(store));
    await tester.pumpAndSettle();
    store.orders.insert(
      0,
      Order(
        ownerId: mockCustomerAId,
        id: 'NEW-ORDER',
        lines: [],
        address: const Address(ownerId: mockCustomerAId),
      ),
    );
    await tester.drag(
      find.byKey(const ValueKey('order-list')),
      const Offset(0, 350),
    );
    await tester.pumpAndSettle();
    expect(find.text('Mã đơn: #NEW-ORDER'), findsOneWidget);
    expect(store.cartCount, 3);
  });

  for (final width in [360.0, 390.0, 430.0]) {
    testWidgets(
      'order list $width large text preserves actual data and scrolls all cards',
      (tester) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 1.2;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final store =
            LenlabStore(
                repository: MockLenlabRepository(latency: Duration.zero),
              )
              ..signedIn = true
              ..coupon = 'LEN50';
        await tester.pumpWidget(app(store));
        await tester.pumpAndSettle();
        expect(find.text('Mã đơn: #WOOL-8823'), findsOneWidget);
        expect(find.text('1.880.000đ'), findsOneWidget);
        expect(find.text('Tổng tiền (3 sản phẩm)'), findsOneWidget);
        await tester.scrollUntilVisible(
          find.text('Đã hiển thị hết đơn hàng'),
          300,
          scrollable: find.descendant(
            of: find.byKey(const ValueKey('order-list')),
            matching: find.byType(Scrollable),
          ),
        );
        expect(tester.takeException(), isNull);
        expect(store.orders, hasLength(4));
        expect(store.cartCount, 3);
      },
    );
  }

  testWidgets(
    'status filter returns exact orders and retains processing in all',
    (tester) async {
      final store =
          LenlabStore(repository: MockLenlabRepository(latency: Duration.zero))
            ..signedIn = true
            ..coupon = 'LEN50';
      store.orders.first.state = OrderState.processing;
      await tester.pumpWidget(app(store));
      await tester.pumpAndSettle();
      expect(find.text('Đang xử lý'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('order-tab-pending')));
      await tester.pumpAndSettle();
      expect(find.text('Mã đơn: #WOOL-8912'), findsOneWidget);
      expect(find.text('Mã đơn: #WOOL-8912'), findsOneWidget);
      expect(find.text('Mã đơn: #WOOL-8823'), findsNothing);
      await tester.tap(find.byKey(const ValueKey('order-tab-shipping')));
      await tester.pumpAndSettle();
      expect(find.text('Không có đơn hàng ở trạng thái này'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('order-tab-all')));
      await tester.pumpAndSettle();
      expect(find.text('Mã đơn: #WOOL-8823'), findsOneWidget);
    },
  );

  testWidgets(
    'loading hides stale cards, failure retries, empty does not show end label',
    (tester) async {
      final repository = MockLenlabRepository(
        latency: const Duration(milliseconds: 300),
      )..failNext('orderList');
      final store = LenlabStore(repository: repository)
        ..signedIn = true
        ..coupon = 'LEN50';
      await tester.pumpWidget(app(store));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(OrderListCard), findsNothing);
      await tester.pumpAndSettle();
      expect(find.text('Không thể tải danh sách đơn hàng'), findsOneWidget);
      await tester.tap(find.text('Thử lại'));
      await tester.pumpAndSettle();
      expect(find.text('Mã đơn: #WOOL-8823'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('order-tab-pending')));
      await tester.pump();
      expect(find.byType(OrderListCard), findsNothing);
      await tester.pumpAndSettle();
      store.orders.clear();
      await tester.tap(find.byKey(const ValueKey('order-tab-all')));
      await tester.pumpAndSettle();
      expect(find.text('Bạn chưa có đơn hàng nào'), findsOneWidget);
      expect(find.text('Đã hiển thị hết đơn hàng'), findsNothing);
    },
  );

  testWidgets(
    'late response from previous tab cannot replace the selected tab',
    (tester) async {
      final store =
          LenlabStore(repository: MockLenlabRepository(latency: Duration.zero))
            ..signedIn = true
            ..coupon = 'LEN50';
      final source = DeferredOrders();
      await tester.pumpWidget(app(store, source: source));
      await tester.tap(find.byKey(const ValueKey('order-tab-pending')));
      await tester.pump();
      source.requests[1].complete([store.orders[2]]);
      await tester.pumpAndSettle();
      expect(find.text('Mã đơn: #WOOL-8912'), findsOneWidget);
      source.requests[0].complete([store.orders.first]);
      await tester.pumpAndSettle();
      expect(find.text('Mã đơn: #WOOL-8823'), findsNothing);
      expect(find.text('Mã đơn: #WOOL-8912'), findsOneWidget);
    },
  );

  testWidgets(
    'route opens exact detail and reloads after returning without changing cart',
    (tester) async {
      final store =
          LenlabStore(repository: MockLenlabRepository(latency: Duration.zero))
            ..signedIn = true
            ..coupon = 'LEN50';
      await tester.pumpWidget(
        CustomerApp(store: store, initialRoute: '/orders'),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Chi tiết').first);
      await tester.pumpAndSettle();
      final info = tester.widget<OrderDetailInformation>(
        find.byType(OrderDetailInformation),
      );
      expect(info.order, same(store.orders.first));
      expect(info.order.id, 'WOOL-8823');
      // Simulates a source update, not an app cancellation action.
      store.orders.first.state = OrderState.processing;
      await tester.tap(find.byTooltip('Quay lại').last);
      await tester.pumpAndSettle();
      expect(find.text('Đang xử lý'), findsOneWidget);
      expect(store.cartCount, 3);
      expect(store.orders.first.payment, PaymentState.cod);
    },
  );

  testWidgets(
    'failed buy-again lookup and guest review leave order and cart intact',
    (tester) async {
      final store =
          LenlabStore(repository: MockLenlabRepository(latency: Duration.zero))
            ..signedIn = true
            ..coupon = 'LEN50';
      store.orders.removeWhere((order) => order.state != OrderState.delivered);
      final delivered = store.orders.single;
      await tester.pumpWidget(app(store));
      await tester.pumpAndSettle();
      (store.repository as MockLenlabRepository).failNext('products');
      await tester.tap(find.text('Mua lại'));
      await tester.pumpAndSettle();
      expect(find.text('Không thể tải sản phẩm để mua lại.'), findsOneWidget);
      await tester.tap(find.text('Đóng'));
      await tester.pumpAndSettle();
      store.logout();
      await tester.pumpAndSettle();
      expect(find.byType(AuthPage), findsOneWidget);
      expect(find.text('Đánh giá'), findsNothing);
      expect(store.cartCount, 0);
      expect(store.orders, isEmpty);
      store.signedIn = true;
      store.coupon = 'LEN50';
      expect(store.orders.single, same(delivered));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'empty order lines, long order code, and missing date remain readable',
    (tester) async {
      tester.view.physicalSize = const Size(360, 900);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final store =
          LenlabStore(repository: MockLenlabRepository(latency: Duration.zero))
            ..signedIn = true
            ..coupon = 'LEN50';
      store.orders
        ..clear()
        ..add(
          Order(
            ownerId: mockCustomerAId,
            id: 'ORDER-WITH-A-VERY-LONG-REFERENCE-1234567890',
            lines: [],
            address: const Address(ownerId: mockCustomerAId),
          ),
        );
      await tester.pumpWidget(app(store));
      await tester.pumpAndSettle();
      expect(find.text('Chưa có thông tin sản phẩm'), findsOneWidget);
      expect(find.text('Chưa có ngày đặt'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

class DeferredOrders implements OrderListSource {
  final requests = <Completer<List<Order>>>[];
  @override
  Future<List<Order>> load({OrderState? state}) {
    final request = Completer<List<Order>>();
    requests.add(request);
    return request.future;
  }
}
