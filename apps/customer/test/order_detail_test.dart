import 'package:lenlab_customer/features/auth/presentation/auth_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_customer/app/customer_scope.dart';
import 'package:lenlab_customer/features/orders/presentation/order_detail_page.dart';
import 'package:lenlab_customer/features/orders/presentation/widgets/order_detail_information.dart';
import 'package:lenlab_customer/features/orders/presentation/widgets/order_detail_status.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

Widget app(LenlabStore store, {String? id, Key? key}) => CustomerScope(
  store: store,
  child: MaterialApp(
    theme: P2.theme(),
    home: OrderDetailPage(key: key, orderId: id),
  ),
);

void main() {
  testWidgets('review action only for delivered orders; guest must sign in', (
    tester,
  ) async {
    final store =
        LenlabStore(repository: MockLenlabRepository(latency: Duration.zero))
          ..signedIn = true
          ..coupon = 'LEN50';
    final order = store.orders.first;
    for (final state in OrderState.values) {
      order.state = state;
      await tester.pumpWidget(app(store, id: order.id, key: UniqueKey()));
      await tester.pumpAndSettle();
      expect(find.text('Hủy đơn hàng'), findsNothing);
      expect(
        find.text('Đánh giá'),
        state == OrderState.delivered ? findsOneWidget : findsNothing,
      );
    }
    order.state = OrderState.delivered;
    for (final signedIn in [false]) {
      store.signedIn = signedIn;
      await tester.pumpWidget(app(store, id: order.id, key: UniqueKey()));
      await tester.pumpAndSettle();
      expect(find.byType(AuthPage), findsOneWidget);
      expect(find.text('Đánh giá'), findsNothing);
      expect(order.state, OrderState.delivered);
      expect(store.orders, isEmpty);
      expect(store.cartCount, 0);
    }
    expect(tester.takeException(), isNull);
  });
  for (final width in [360.0, 390.0, 430.0]) {
    testWidgets(
      'order detail $width large text shows shipping order without cancel or review',
      (tester) async {
        tester.view.physicalSize = Size(width, 1000);
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
        final order = store.orders.first;
        await tester.pumpWidget(app(store, id: order.id));
        await tester.pumpAndSettle();
        expect(find.text('#${order.id}'), findsOneWidget);
        expect(
          tester
              .widget<OrderDetailStatus>(find.byType(OrderDetailStatus))
              .order
              .state,
          OrderState.shipping,
        );
        expect(find.text('Số lượng: 2'), findsOneWidget);
        final info = find.byType(OrderDetailInformation);
        await tester.ensureVisible(info);
        await tester.pumpAndSettle();
        expect(
          tester.widget<OrderDetailInformation>(info).order.total,
          1880000,
        );
        expect(find.text('Hủy đơn hàng'), findsNothing);
        expect(find.text('Đánh giá'), findsNothing);
        expect(find.text('Liên hệ hỗ trợ'), findsOneWidget);
        expect(order.state, OrderState.shipping);
        expect(order.payment, PaymentState.cod);
        expect(store.cartCount, 3);
        expect(store.orders.length, 4);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets('order detail loading error retry does not show stale actions', (
    tester,
  ) async {
    final repo = MockLenlabRepository(
      latency: const Duration(milliseconds: 300),
    )..failNext('orderDetail');
    final store = LenlabStore(repository: repo)
      ..signedIn = true
      ..coupon = 'LEN50';
    await tester.pumpWidget(app(store, id: store.orders.first.id));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Hủy đơn hàng'), findsNothing);
    await tester.pumpAndSettle();
    expect(find.text('Không thể tải chi tiết đơn hàng'), findsOneWidget);
    expect(find.text('Hủy đơn hàng'), findsNothing);
    await tester.tap(find.text('Thử lại'));
    await tester.pumpAndSettle();
    expect(find.byType(OrderDetailStatus), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('missing and unknown ids do not show the first seed order', (
    tester,
  ) async {
    final store =
        LenlabStore(repository: MockLenlabRepository(latency: Duration.zero))
          ..signedIn = true
          ..coupon = 'LEN50';
    await tester.pumpWidget(app(store));
    await tester.pumpAndSettle();
    expect(find.text('Không tìm thấy đơn hàng'), findsOneWidget);
    expect(find.text('Hủy đơn hàng'), findsNothing);
    await tester.pumpWidget(app(store, id: 'missing', key: UniqueKey()));
    await tester.pumpAndSettle();
    expect(find.text('Không tìm thấy đơn hàng'), findsOneWidget);
    expect(find.text('#WOOL-8823'), findsNothing);
    expect(store.orders.length, 4);
  });
  testWidgets('empty products and absent metadata show explicit fallback', (
    tester,
  ) async {
    final store =
        LenlabStore(repository: MockLenlabRepository(latency: Duration.zero))
          ..signedIn = true
          ..coupon = 'LEN50';
    store.orders.add(
      Order(
        ownerId: mockCustomerAId,
        id: 'EMPTY',
        lines: [],
        address: const Address(ownerId: mockCustomerAId),
        shipping: 0,
      ),
    );
    await tester.pumpWidget(app(store, id: 'EMPTY'));
    await tester.pumpAndSettle();
    expect(find.text('Chưa có thời gian đặt đơn'), findsOneWidget);
    expect(find.text('Chưa có lịch giao hàng'), findsOneWidget);
    expect(find.text('Đơn hàng chưa có sản phẩm'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'order updates reflect state payment and note without cart totals',
    (tester) async {
      final store =
          LenlabStore(repository: MockLenlabRepository(latency: Duration.zero))
            ..signedIn = true
            ..coupon = 'LEN50';
      final order = store.orders[2];
      await tester.pumpWidget(app(store, id: order.id));
      await tester.pumpAndSettle();
      order.state = OrderState.cancelled;
      order.payment = PaymentState.pendingConfirmation;
      order.note = 'Gói quà';
      store.changeQuantity(store.cart.first, 1);
      await tester.pumpAndSettle();
      expect(find.text('Đã hủy'), findsNWidgets(3));
      final info = tester.widget<OrderDetailInformation>(
        find.byType(OrderDetailInformation),
      );
      expect(info.order.total, order.total);
      expect(info.order.note, 'Gói quà');
      expect(info.order.payment, PaymentState.pendingConfirmation);
      expect(tester.takeException(), isNull);
    },
  );
}
