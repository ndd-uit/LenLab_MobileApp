import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_customer/app/customer_app.dart';
import 'package:lenlab_customer/app/customer_scope.dart';
import 'package:lenlab_customer/features/checkout/presentation/order_review_page.dart';
import 'package:lenlab_customer/features/checkout/presentation/widgets/order_review_products.dart';
import 'package:lenlab_customer/features/checkout/presentation/widgets/order_review_totals.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

class _TestQuoteSource implements OrderReviewSource {
  @override
  Future<OrderReviewTotals> preview({
    required int subtotal,
    required int discount,
    required Address address,
  }) async => OrderReviewTotals(
    subtotal: subtotal,
    discount: discount,
    shipping: 15000,
  );
}

void main() {
  for (final width in [360.0, 390.0, 430.0]) {
    testWidgets(
      'review $width large text and keyboard preserve data and note',
      (tester) async {
        tester.view.physicalSize = Size(width, 929);
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
              ..coupon = 'LEN50'
              ..deliveryAddress = const Address(ownerId: mockCustomerAId);
        await tester.pumpWidget(
          CustomerApp(initialRoute: '/order-review', store: store),
        );
        await tester.pumpAndSettle();
        expect(find.byType(OrderReviewProductLine), findsNWidgets(2));
        expect(find.text('x2'), findsOneWidget);
        final totals = tester
            .widget<OrderReviewPaymentDetails>(
              find.byType(OrderReviewPaymentDetails),
            )
            .totals;
        expect(totals.subtotal, 1900000);
        expect(totals.total, 1880000);
        tester.view.viewInsets = const FakeViewPadding(bottom: 300);
        addTearDown(tester.view.resetViewInsets);
        final note = find.byKey(const ValueKey('order-note'));
        await tester.ensureVisible(note);
        await tester.enterText(note, 'Gói quà, không hiển thị giá.');
        await tester.pumpAndSettle();
        expect(store.checkoutNote, 'Gói quà, không hiển thị giá.');
        await tester.tap(find.text('Chọn thanh toán'));
        await tester.pumpAndSettle();
        expect(find.text('Phương thức thanh toán'), findsOneWidget);
        expect(store.orders.length, 4);
        expect(store.cart.length, 2);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets('edit address returns to existing review and preserves note', (
    tester,
  ) async {
    final store =
        LenlabStore(repository: MockLenlabRepository(latency: Duration.zero))
          ..signedIn = true
          ..coupon = 'LEN50'
          ..deliveryAddress = const Address(ownerId: mockCustomerAId);
    await tester.pumpWidget(
      CustomerApp(initialRoute: '/order-review', store: store),
    );
    await tester.pumpAndSettle();
    final note = find.byKey(const ValueKey('order-note'));
    await tester.ensureVisible(note);
    await tester.enterText(note, 'Giao buổi chiều.');
    await tester.ensureVisible(find.text('Sửa'));
    await tester.tap(find.text('Sửa'));
    await tester.pumpAndSettle();
    expect(find.text('Địa chỉ giao hàng'), findsOneWidget);
    final street = find.byKey(const ValueKey('address-street'));
    await tester.ensureVisible(street);
    await tester.enterText(street, '55 Đường mẫu');
    await tester.tap(find.text('Xem lại đơn hàng'));
    await tester.pumpAndSettle();
    expect(find.byType(OrderReviewPage), findsOneWidget);
    expect(find.textContaining('55 Đường mẫu'), findsOneWidget);
    expect(tester.widget<TextField>(note).controller!.text, 'Giao buổi chiều.');
    expect(store.addresses.single.street, '123 Đường Nguyễn Huệ');
    expect(store.orders.length, 4);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'review loading error retry and cart change recalculate without clearing notes',
    (tester) async {
      final repo = MockLenlabRepository(
        latency: const Duration(milliseconds: 300),
      )..failNext('orderReview');
      final store = LenlabStore(repository: repo)
        ..signedIn = true
        ..coupon = 'LEN50'
        ..deliveryAddress = const Address(ownerId: mockCustomerAId);
      await tester.pumpWidget(
        CustomerApp(initialRoute: '/order-review', store: store),
      );
      await tester.pump();
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(
        tester
            .widget<ElevatedButton>(
              find.widgetWithText(ElevatedButton, 'Chọn thanh toán'),
            )
            .onPressed,
        isNull,
      );
      await tester.pumpAndSettle();
      expect(find.text('Không thể tải tổng quan đơn hàng'), findsOneWidget);
      await tester.tap(find.text('Thử lại'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('order-note')));
      await tester.enterText(
        find.byKey(const ValueKey('order-note')),
        'Giữ ghi chú.',
      );
      store.changeQuantity(store.cart.first, 1);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<OrderReviewPaymentDetails>(
              find.byType(OrderReviewPaymentDetails),
            )
            .totals
            .total,
        3080000,
      );
      expect(store.checkoutNote, 'Giữ ghi chú.');
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('review guards missing address and empty cart', (tester) async {
    final store =
        LenlabStore(repository: MockLenlabRepository(latency: Duration.zero))
          ..signedIn = true
          ..coupon = 'LEN50';
    await tester.pumpWidget(
      CustomerApp(initialRoute: '/order-review', store: store),
    );
    await tester.pumpAndSettle();
    expect(find.text('Chưa có địa chỉ nhận hàng'), findsOneWidget);
    expect(find.text('Chọn thanh toán'), findsNothing);
    store.cart.clear();
    store.changed();
    await tester.pumpAndSettle();
    expect(find.text('Giỏ hàng đang trống'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'review renders totals from its data source instead of hardcoded shipping',
    (tester) async {
      final store =
          LenlabStore(repository: MockLenlabRepository(latency: Duration.zero))
            ..signedIn = true
            ..coupon = 'LEN50'
            ..deliveryAddress = const Address(ownerId: mockCustomerAId);
      await tester.pumpWidget(
        CustomerScope(
          store: store,
          child: MaterialApp(
            theme: P2.theme(),
            home: OrderReviewPage(source: _TestQuoteSource()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final totals = tester
          .widget<OrderReviewPaymentDetails>(
            find.byType(OrderReviewPaymentDetails),
          )
          .totals;
      expect(totals.shipping, 15000);
      expect(totals.total, 1865000);
      expect(tester.takeException(), isNull);
    },
  );
}
