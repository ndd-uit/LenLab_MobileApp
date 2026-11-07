import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_customer/app/customer_app.dart';
import 'package:lenlab_customer/features/checkout/presentation/cod_success_page.dart';
import 'package:lenlab_customer/features/checkout/presentation/widgets/payment_method_footer.dart';
import 'package:lenlab_customer/features/orders/presentation/widgets/order_detail_information.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

void main() {
  testWidgets(
    'sending COD locks controls and back; failure retains draft and retries once',
    (tester) async {
      tester.view.physicalSize = const Size(390, 956);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repo = MockLenlabRepository(
        latency: const Duration(milliseconds: 500),
      )..failNext('checkout');
      final store = LenlabStore(repository: repo)
        ..signedIn = true
        ..coupon = 'LEN50'
        ..deliveryAddress = const Address(ownerId: mockCustomerAId)
        ..checkoutNote = 'Giao buổi chiều';
      await tester.pumpWidget(
        CustomerApp(initialRoute: '/payment-method', store: store),
      );
      await tester.pumpAndSettle();
      final submit = tester
          .widget<PaymentMethodFooter>(find.byType(PaymentMethodFooter))
          .onContinue!;
      submit();
      submit();
      await tester.pump();
      expect(find.text('Đang đặt đơn…'), findsOneWidget);
      expect(
        tester
            .widget<PaymentMethodFooter>(find.byType(PaymentMethodFooter))
            .onContinue,
        isNull,
      );
      await tester.binding.handlePopRoute();
      await tester.pump();
      expect(find.text('Phương thức thanh toán'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('Thử đặt lại'), findsOneWidget);
      expect(find.byType(CodSuccessPage), findsNothing);
      expect(store.cartCount, 3);
      expect(store.checkoutNote, 'Giao buổi chiều');
      expect(store.orders.length, 4);
      await tester.ensureVisible(find.text('Thử đặt lại'));
      await tester.tap(find.text('Thử đặt lại'));
      await tester.pumpAndSettle();
      expect(find.text('Đặt hàng thành công!'), findsOneWidget);
      expect(find.text('#${store.orders.first.id}'), findsOneWidget);
      expect(store.orders.length, 5);
      expect(store.orders.first.note, 'Giao buổi chiều');
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(CodSuccessPage), findsNothing);
      expect(find.text('Phương thức thanh toán'), findsNothing);
      expect(store.orders.length, 5);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('success actions pass order id and shopping returns home', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store =
        LenlabStore(repository: MockLenlabRepository(latency: Duration.zero))
          ..signedIn = true
          ..coupon = 'LEN50'
          ..deliveryAddress = const Address(ownerId: mockCustomerAId);
    await tester.pumpWidget(
      CustomerApp(initialRoute: '/payment-method', store: store),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Đặt hàng COD'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Xem chi tiết đơn hàng'));
    await tester.tap(find.text('Xem chi tiết đơn hàng'));
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(Scaffold).last);
    final detail = tester.widget<OrderDetailInformation>(
      find.byType(OrderDetailInformation),
    );
    expect(detail.order, same(store.orders.first));
    expect(detail.order.total, 1880000);
    expect(ModalRoute.of(context)!.settings.arguments, store.orders.first.id);
    expect(ModalRoute.of(context)!.settings.name, '/order-detail');
    Navigator.pop(context);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Tiếp tục mua sắm'));
    await tester.tap(find.text('Tiếp tục mua sắm'));
    await tester.pumpAndSettle();
    expect(find.byType(CodSuccessPage), findsNothing);
    expect(
      Navigator.canPop(tester.element(find.byType(Scaffold).last)),
      isFalse,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('direct success route cannot invent a successful order', (
    tester,
  ) async {
    final store = LenlabStore()
      ..signedIn = true
      ..coupon = 'LEN50';
    await tester.pumpWidget(
      CustomerApp(initialRoute: '/cod-confirmation', store: store),
    );
    await tester.pumpAndSettle();
    expect(find.text('Chưa có đơn COD để hiển thị'), findsOneWidget);
    expect(find.text('Đặt hàng thành công!'), findsNothing);
    expect(store.cartCount, 3);
    expect(store.orders.length, 4);
  });
}
