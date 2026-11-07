import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_customer/app/customer_app.dart';
import 'package:lenlab_customer/features/checkout/presentation/widgets/payment_method_footer.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

void main() {
  for (final width in [360.0, 390.0, 430.0]) {
    testWidgets('payment $width large text submits COD with draft', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 886);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final store =
          LenlabStore(repository: MockLenlabRepository(latency: Duration.zero))
            ..signedIn = true
            ..coupon = 'LEN50'
            ..deliveryAddress = const Address(ownerId: mockCustomerAId)
            ..checkoutNote = 'Gói quà.';
      await tester.pumpWidget(
        CustomerApp(initialRoute: '/payment-method', store: store),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<PaymentMethodFooter>(find.byType(PaymentMethodFooter))
            .total,
        1880000,
      );
      expect(find.text('Thanh toán khi nhận hàng'), findsOneWidget);
      expect(find.text('Chuyển khoản ngân hàng'), findsOneWidget);
      await tester.tap(find.text('Đặt hàng COD'));
      await tester.pumpAndSettle();
      expect(find.text('Đặt hàng thành công!'), findsOneWidget);
      expect(store.checkoutPaymentMethod, CheckoutPaymentMethod.cod);
      expect(store.orders.first.note, 'Gói quà.');
      expect(store.orders.first.payment, PaymentState.cod);
      expect(store.orders.first.state, OrderState.pending);
      expect(store.cart, isEmpty);
      expect(store.orders.length, 5);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'bank option links to separate flow and returns to COD selection',
    (tester) async {
      final store =
          LenlabStore(repository: MockLenlabRepository(latency: Duration.zero))
            ..signedIn = true
            ..coupon = 'LEN50'
            ..deliveryAddress = const Address(ownerId: mockCustomerAId);
      await tester.pumpWidget(
        CustomerApp(initialRoute: '/payment-method', store: store),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Chuyển khoản ngân hàng'));
      await tester.pumpAndSettle();
      expect(store.checkoutPaymentMethod, CheckoutPaymentMethod.bankTransfer);
      expect(find.text('Số tiền cần thanh toán'), findsOneWidget);
      final context = tester.element(find.byType(Scaffold).last);
      Navigator.pop(context);
      await tester.pumpAndSettle();
      expect(find.text('Phương thức thanh toán'), findsOneWidget);
      expect(store.checkoutPaymentMethod, CheckoutPaymentMethod.cod);
      expect(store.cartCount, 3);
      expect(store.orders.length, 4);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('loading error retry and changing cart keep totals current', (
    tester,
  ) async {
    final repo = MockLenlabRepository(
      latency: const Duration(milliseconds: 300),
    )..failNext('orderReview');
    final store = LenlabStore(repository: repo)
      ..signedIn = true
      ..coupon = 'LEN50'
      ..deliveryAddress = const Address(ownerId: mockCustomerAId);
    await tester.pumpWidget(
      CustomerApp(initialRoute: '/payment-method', store: store),
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester
          .widget<PaymentMethodFooter>(find.byType(PaymentMethodFooter))
          .onContinue,
      isNull,
    );
    await tester.pumpAndSettle();
    expect(find.text('Không thể tải thông tin thanh toán'), findsOneWidget);
    expect(
      tester
          .widget<PaymentMethodFooter>(find.byType(PaymentMethodFooter))
          .onContinue,
      isNull,
    );
    await tester.tap(find.text('Thử lại'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<PaymentMethodFooter>(find.byType(PaymentMethodFooter))
          .total,
      1880000,
    );
    store.changeQuantity(store.cart.first, 1);
    await tester.pump();
    expect(
      tester
          .widget<PaymentMethodFooter>(find.byType(PaymentMethodFooter))
          .onContinue,
      isNull,
    );
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<PaymentMethodFooter>(find.byType(PaymentMethodFooter))
          .total,
      3080000,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('missing address and empty cart block payment actions', (
    tester,
  ) async {
    final store =
        LenlabStore(repository: MockLenlabRepository(latency: Duration.zero))
          ..signedIn = true
          ..coupon = 'LEN50';
    await tester.pumpWidget(
      CustomerApp(initialRoute: '/payment-method', store: store),
    );
    await tester.pumpAndSettle();
    expect(find.text('Chưa có địa chỉ nhận hàng'), findsOneWidget);
    expect(find.byType(PaymentMethodFooter), findsNothing);
    store.cart.clear();
    store.changed();
    await tester.pumpAndSettle();
    expect(find.text('Giỏ hàng đang trống'), findsOneWidget);
    expect(find.text('Đặt hàng COD'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
