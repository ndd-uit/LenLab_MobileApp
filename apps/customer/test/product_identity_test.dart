import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_customer/app/customer_app.dart';
import 'package:lenlab_customer/features/home/data/home_content.dart';
import 'package:lenlab_customer/features/orders/data/buy_again_source.dart';
import 'package:lenlab_customer/features/orders/presentation/widgets/order_list_card.dart';
import 'package:lenlab_customer/features/products/presentation/product_detail_page.dart';
import 'package:lenlab_customer/features/products/presentation/product_unavailable_page.dart';
import 'package:lenlab_customer/features/products/presentation/widgets/detail_related.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

void viewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> tap(WidgetTester tester, Finder target) async {
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

NavigatorState navigator(WidgetTester tester) =>
    tester.state<NavigatorState>(find.byType(Navigator).first);

void main() {
  test(
    'Home and Related references resolve once to the same canonical records',
    () async {
      final repository = MockLenlabRepository(latency: Duration.zero);
      final products = await repository.products();
      expect(products.map((p) => p.id).toSet().length, products.length);
      for (final id in [
        ...homeFeaturedItems.map((item) => item.productId),
        ...relatedProductIds,
      ]) {
        final product = products.where((p) => p.id == id).single;
        expect(product.published, isTrue);
        expect(product.stock, greaterThan(0));
        expect(
          product,
          same(repository.catalog.singleWhere((p) => p.id == id)),
        );
        expect(
          (await repository.products()).singleWhere((p) => p.id == id),
          same(product),
        );
      }
      // These P2 records must not be merged by their similar display names.
      expect(products.singleWhere((p) => p.id == 'sweater').price, 1200000);
      expect(
        products.singleWhere((p) => p.id == 'related-356e2.png').price,
        850000,
      );
      expect(
        products.singleWhere((p) => p.id == 'featured-handknit').image,
        '472b3.png',
      );
      final anotherSession = MockLenlabRepository(latency: Duration.zero);
      repository.catalog.singleWhere((p) => p.id == 'featured-socks').stock = 0;
      expect(
        anotherSession.catalog
            .singleWhere((p) => p.id == 'featured-socks')
            .stock,
        greaterThan(0),
      );
    },
  );

  for (final item in homeFeaturedItems) {
    testWidgets(
      '${item.productId}: Home → Detail → Cart → Checkout → COD → Buy Again',
      (tester) async {
        viewport(tester);
        final repository = MockLenlabRepository(latency: Duration.zero);
        final product = repository.catalog.singleWhere(
          (p) => p.id == item.productId,
        );
        final store = LenlabStore(repository: repository)
          ..signedIn = true
          ..coupon = 'LEN50'
          ..deliveryAddress = const Address(ownerId: mockCustomerAId);
        store.cart.clear();
        await tester.pumpWidget(CustomerApp(store: store));
        await tester.pumpAndSettle();
        await tap(
          tester,
          find.byKey(ValueKey('home-product-${item.productId}')),
        );
        expect(
          tester
              .widget<ProductDetailPage>(find.byType(ProductDetailPage))
              .product,
          same(product),
        );
        await tap(tester, find.text('Thêm vào giỏ'));
        expect(store.cart.single.product.id, product.id);
        expect(store.cart.single.product.price, product.price);
        expect(store.cart.single.product, isNot(same(product)));
        navigator(tester).pushNamed('/cart');
        await tester.pumpAndSettle();
        await tap(tester, find.text('Thanh toán'));
        await tap(tester, find.text('Xem lại đơn hàng'));
        await tap(tester, find.text('Chọn thanh toán'));
        await tap(tester, find.text('Đặt hàng COD'));
        final order = store.orders.first;
        expect(order.lines.single.product.id, product.id);
        expect(order.lines.single.product.name, product.name);
        expect(order.lines.single.product.price, product.price);
        expect(order.lines.single.product.image, product.image);
        expect(
          order.lines.single.product,
          isNot(same(product)),
        ); // Historical snapshot.
        expect(store.cart, isEmpty);
        final purchasedPrice = order.lines.single.product.price;
        product.price += 1000;
        expect(order.lines.single.product.price, purchasedPrice);
        // Test fixture progression only; this task adds no order status mutation UI.
        order.state = OrderState.delivered;
        navigator(tester).pushNamed('/orders');
        await tester.pumpAndSettle();
        final card = find.byWidgetPredicate(
          (w) => w is OrderListCard && identical(w.order, order),
        );
        await tap(
          tester,
          find.descendant(of: card, matching: find.text('Mua lại')),
        );
        final reopened = tester
            .widget<ProductDetailPage>(find.byType(ProductDetailPage))
            .product;
        expect(reopened, same(product));
        expect(reopened.price, purchasedPrice + 1000);
        expect(store.cart, isEmpty); // Buy Again opens detail, never auto-adds.
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final id in relatedProductIds) {
    testWidgets('$id: Related → Detail → Cart', (tester) async {
      viewport(tester);
      final repository = MockLenlabRepository(latency: Duration.zero);
      final store = LenlabStore(repository: repository);
      store.cart.clear();
      await tester.pumpWidget(CustomerApp(store: store));
      await tester.pumpAndSettle();
      navigator(tester).pushNamed(
        '/product',
        arguments: repository.catalog.singleWhere((p) => p.id == 'merino'),
      );
      await tester.pumpAndSettle();
      await tap(tester, find.byKey(ValueKey('related-product-$id')));
      final product = repository.catalog.singleWhere((p) => p.id == id);
      expect(
        tester
            .widget<ProductDetailPage>(find.byType(ProductDetailPage))
            .product,
        same(product),
      );
      await tap(tester, find.text('Thêm vào giỏ'));
      expect(store.cart.single.product.id, product.id);
      expect(store.cart.single.product.price, product.price);
      expect(store.cart.single.product, isNot(same(product)));
      expect(store.cart.single.total, product.price);
      expect(tester.takeException(), isNull);
    });
  }

  for (final unavailable in [
    'removed',
    'hidden',
    'out-of-stock',
    'duplicate',
  ]) {
    testWidgets(
      'Stale Home payload $unavailable cannot select or buy another product',
      (tester) async {
        viewport(tester);
        final repository = MockLenlabRepository(latency: Duration.zero);
        final product = repository.catalog.singleWhere(
          (p) => p.id == homeFeaturedItems.first.productId,
        );
        final store = LenlabStore(repository: repository);
        await tester.pumpWidget(CustomerApp(store: store));
        await tester.pumpAndSettle();
        if (unavailable == 'removed') repository.catalog.remove(product);
        if (unavailable == 'hidden') product.published = false;
        if (unavailable == 'out-of-stock') product.stock = 0;
        if (unavailable == 'duplicate') repository.catalog.add(product);
        await tap(tester, find.byKey(ValueKey('home-product-${product.id}')));
        expect(find.byType(ProductUnavailablePage), findsOneWidget);
        expect(find.byType(ProductDetailPage), findsNothing);
        expect(store.cartCount, 0);
        final prior = Order(
          ownerId: mockCustomerAId,
          id: 'PAST',
          lines: [CartLine(product)],
          address: const Address(ownerId: mockCustomerAId),
          state: OrderState.delivered,
        );
        store.signedIn = true;
        store.coupon = 'LEN50';
        store.orders.add(prior);
        final result = await tester.runAsync(
          () => CatalogBuyAgainSource(repository, session: store).load(prior),
        );
        expect(result!.single.product, isNull);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'Route resolves canonical values instead of trusting a forged payload',
    (tester) async {
      viewport(tester);
      final repository = MockLenlabRepository(latency: Duration.zero);
      await tester.pumpWidget(
        CustomerApp(store: LenlabStore(repository: repository)),
      );
      await tester.pumpAndSettle();
      final actual = repository.catalog.singleWhere(
        (p) => p.id == homeFeaturedItems.first.productId,
      );
      navigator(tester).pushNamed(
        '/product',
        arguments: Product(
          id: actual.id,
          name: 'Wrong display data',
          price: 1,
          image: '',
          category: '',
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<ProductDetailPage>(find.byType(ProductDetailPage))
            .product,
        same(actual),
      );
      expect(find.text('Wrong display data'), findsNothing);
    },
  );

  testWidgets(
    'Home and detail catalog failures retry without constructing substitutes',
    (tester) async {
      viewport(tester);
      final repository = MockLenlabRepository(latency: Duration.zero)
        ..failNext('products');
      await tester.pumpWidget(
        CustomerApp(store: LenlabStore(repository: repository)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Không thể tải sản phẩm'), findsOneWidget);
      await tap(tester, find.text('Thử lại'));
      repository.failNext('products');
      await tap(
        tester,
        find.byKey(
          ValueKey('home-product-${homeFeaturedItems.first.productId}'),
        ),
      );
      expect(find.text('Không thể tải sản phẩm'), findsOneWidget);
      expect(find.byType(ProductDetailPage), findsNothing);
      await tap(tester, find.text('Thử lại'));
      expect(find.byType(ProductDetailPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
