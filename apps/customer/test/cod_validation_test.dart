import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_customer/app/customer_app.dart';
import 'package:lenlab_customer/features/checkout/presentation/cod_success_page.dart';
import 'package:lenlab_customer/features/checkout/presentation/order_review_page.dart';
import 'package:lenlab_customer/features/checkout/presentation/widgets/payment_method_footer.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

void viewport(WidgetTester tester, [double width = 390]) {
  tester.view.physicalSize = Size(width, 1000);
  tester.view.devicePixelRatio = 1;
  if (width == 360) tester.platformDispatcher.textScaleFactorTestValue = 1.2;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

LenlabStore sample(MockLenlabRepository repository) {
  final store = LenlabStore(repository: repository)
    ..signedIn = true
    ..coupon = 'LEN50'
    ..deliveryAddress = const Address(ownerId: mockCustomerAId)
    ..checkoutNote = 'Giao buổi chiều';
  store.toggleCartLine(store.cart.last);
  return store;
}

Future<void> tap(WidgetTester tester, Finder target) async {
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

PaymentMethodFooter footer(WidgetTester tester) =>
    tester.widget<PaymentMethodFooter>(find.byType(PaymentMethodFooter));

void expectDraft(LenlabStore store, List<CartLine> original, Address address) {
  expect(store.cart, orderedEquals(original));
  expect(store.checkoutLines, [original.first]);
  expect(store.deliveryAddress, same(address));
  expect(store.checkoutNote, 'Giao buổi chiều');
  expect(store.coupon, 'LEN50');
  expect(store.orders, hasLength(4));
}

void main() {
  for (final error in ['removed', 'hidden', 'stock', 'quantity']) {
    testWidgets(
      'COD $error shows a specific error without losing draft or selection',
      (tester) async {
        viewport(tester);
        final repository = MockLenlabRepository(latency: Duration.zero);
        final store = sample(repository);
        final original = List.of(store.cart);
        final address = store.deliveryAddress!;
        final product = repository.catalog.singleWhere(
          (p) => p.id == original.first.product.id,
        );
        await tester.pumpWidget(
          CustomerApp(store: store, initialRoute: '/payment-method'),
        );
        await tester.pumpAndSettle();
        switch (error) {
          case 'removed':
            repository.catalog.remove(product);
          case 'hidden':
            product.published = false;
          case 'stock':
            product.stock = 0;
          case 'quantity':
            original.first.quantity = 46;
        }
        await tap(tester, find.text('Đặt hàng COD'));
        final expected = switch (error) {
          'removed' => 'không còn trong danh mục',
          'hidden' => 'đã bị ẩn',
          'stock' => 'đã hết hàng',
          _ => 'vượt tồn kho',
        };
        expect(find.textContaining(expected), findsOneWidget);
        expect(find.byType(CodSuccessPage), findsNothing);
        expectDraft(store, original, address);
        await tap(tester, find.byKey(const ValueKey('cod-edit-cart')));
        expect(find.text('Giỏ hàng'), findsOneWidget);
        expectDraft(store, original, address);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final width in [360.0, 390.0]) {
    testWidgets(
      'COD price change $width needs explicit update, review and another confirmation',
      (tester) async {
        viewport(tester, width);
        final repository = MockLenlabRepository(latency: Duration.zero);
        final store = sample(repository);
        final original = List.of(store.cart);
        final address = store.deliveryAddress!;
        final product = repository.catalog.singleWhere(
          (p) => p.id == original.first.product.id,
        );
        await tester.pumpWidget(
          CustomerApp(store: store, initialRoute: '/payment-method'),
        );
        await tester.pumpAndSettle();
        final originalTotal = footer(tester).total;
        product.price += 100000;
        store.changed();
        await tester.pumpAndSettle();
        expect(footer(tester).total, originalTotal);
        expect(original.first.product.price, 1200000);
        await tap(tester, find.text('Đặt hàng COD'));
        expect(find.textContaining('giá đã thay đổi'), findsOneWidget);
        expect(footer(tester).onContinue, isNull);
        expectDraft(store, original, address);
        repository.failNext('products');
        await tap(tester, find.byKey(const ValueKey('cod-review-updated')));
        expect(find.textContaining('Không thể kết nối'), findsOneWidget);
        expectDraft(store, original, address);
        await tap(tester, find.byKey(const ValueKey('cod-review-updated')));
        expect(find.byType(OrderReviewPage), findsOneWidget);
        expect(store.cart.first.product.price, 1300000);
        expect(store.cart.first.quantity, original.first.quantity);
        expect(store.cart.last, same(original.last));
        expect(store.isCartLineSelected(original.last), isFalse);
        expect(store.checkoutNote, 'Giao buổi chiều');
        expect(store.deliveryAddress, same(address));
        expect(store.orders, hasLength(4));
        await tap(tester, find.text('Chọn thanh toán'));
        expect(footer(tester).total, 1280000);
        await tap(tester, find.text('Đặt hàng COD'));
        expect(find.byType(CodSuccessPage), findsOneWidget);
        final order = store.orders.first;
        expect(order.lines.single.product.price, 1300000);
        expect(order.total, 1280000);
        expect(order.note, 'Giao buổi chiều');
        expect(order.address, same(address));
        expect(store.cart.single, same(original.last));
        expect(store.orders, hasLength(5));
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'Stock change with sufficient quantity also requires explicit review',
    (tester) async {
      viewport(tester);
      final repository = MockLenlabRepository(latency: Duration.zero);
      final store = sample(repository);
      await tester.pumpWidget(
        CustomerApp(store: store, initialRoute: '/payment-method'),
      );
      await tester.pumpAndSettle();
      final product = repository.catalog.singleWhere(
        (p) => p.id == store.cart.first.product.id,
      );
      product.stock = 50;
      await tap(tester, find.text('Đặt hàng COD'));
      expect(find.textContaining('tồn kho đã thay đổi'), findsOneWidget);
      expect(footer(tester).onContinue, isNull);
      expect(store.cart.first.product.stock, 45);
      await tap(tester, find.byKey(const ValueKey('cod-review-updated')));
      expect(find.byType(OrderReviewPage), findsOneWidget);
      expect(store.cart.first.product.stock, 50);
      expect(store.cart.first.quantity, 1);
      expect(store.orders, hasLength(4));
      expect(tester.takeException(), isNull);
    },
  );
}
