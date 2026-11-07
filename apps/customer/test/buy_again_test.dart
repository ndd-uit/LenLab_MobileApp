import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_customer/app/customer_app.dart';
import 'package:lenlab_customer/features/orders/data/buy_again_source.dart';
import 'package:lenlab_customer/features/orders/presentation/buy_again_dialog.dart';
import 'package:lenlab_customer/features/products/presentation/product_detail_page.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

Order delivered(List<Product> products) => Order(
  ownerId: mockCustomerAId,
  id: 'PAST',
  lines: [
    for (final p in products) CartLine(p, quantity: 3, variant: 'Biến thể cũ'),
  ],
  address: const Address(ownerId: mockCustomerAId),
  state: OrderState.delivered,
);
Product old(String id, {String name = 'Tên cũ'}) =>
    Product(id: id, name: name, price: 100, image: '', category: '');
LenlabStore storeFor(MockLenlabRepository repo, Order order) =>
    LenlabStore(repository: repo)
      ..signedIn = true
      ..orders.clear()
      ..orders.add(order);

void viewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

class ControlledBuyAgain implements BuyAgainSource {
  final result = Completer<List<BuyAgainChoice>>();
  @override
  Future<List<BuyAgainChoice>> load(Order order) => result.future;
}

Future<List<BuyAgainChoice>> resolve(MockLenlabRepository repo, Order order) =>
    CatalogBuyAgainSource(repo, session: storeFor(repo, order)).load(order);

void main() {
  testWidgets('Empty delivered order offers close; no navigation or mutation', (
    tester,
  ) async {
    viewport(tester);
    final store = storeFor(
      MockLenlabRepository(latency: Duration.zero),
      delivered([]),
    );
    await tester.pumpWidget(CustomerApp(store: store, initialRoute: '/orders'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mua lại'));
    await tester.pumpAndSettle();
    expect(
      find.text('Đơn hàng chưa có thông tin sản phẩm để mua lại.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Đóng'));
    await tester.pumpAndSettle();
    expect(find.byType(ProductDetailPage), findsNothing);
    expect(store.cartCount, 3);
  });
  test('Resolve exact current IDs/prices; no name matching, old variants or cart changes', () async {
    final repo = MockLenlabRepository(latency: Duration.zero);
    final current = repo.catalog.first;
    final prior = delivered([
      old(current.id),
      old(current.id),
      old('missing', name: current.name),
    ]);
    final result = await resolve(repo, prior);
    expect(result.length, 2);
    expect(result.first.product, same(current));
    expect(result.first.product!.price, 250000);
    expect(result.last.product, isNull);
    expect(prior.lines.first.quantity, 3);
    expect(prior.lines.first.product.price, 100);
    expect(prior.lines.first.variant, 'Biến thể cũ');
  });

  test('Unavailable/duplicate/hidden/digital/out-of-stock entries cannot be opened', () async {
    final repo = MockLenlabRepository(latency: Duration.zero);
    final sheep = repo.catalog.first;
    final cashmere = repo.catalog[1]..published = false;
    final yarn = repo.catalog[2]..stock = 0;
    repo.catalog.add(old(sheep.id));
    final result = await resolve(
      repo,
      delivered([
        old(sheep.id),
        old(cashmere.id),
        old(yarn.id),
        old('removed-product'),
      ]),
    );
    expect(result.every((choice) => choice.product == null), isTrue);
    expect(result.every((choice) => choice.unavailableReason != null), isTrue);
    expect(await resolve(repo, delivered([])), isEmpty);
  });

  testWidgets(
    'Single item opens current detail without copying old variant/quantity; only explicit Add changes cart',
    (tester) async {
      viewport(tester);
      final repo = MockLenlabRepository(latency: Duration.zero);
      final order = delivered([old('merino')]);
      final store = storeFor(repo, order)..cart.clear();
      await tester.pumpWidget(
        CustomerApp(store: store, initialRoute: '/orders'),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mua lại'));
      await tester.pumpAndSettle();
      final detail = tester.widget<ProductDetailPage>(
        find.byType(ProductDetailPage),
      );
      expect(
        detail.product,
        same(repo.catalog.firstWhere((p) => p.id == 'merino')),
      );
      expect(detail.product.price, 550000);
      expect(store.cart, isEmpty);
      expect(store.orders.single, same(order));
      await tester.tap(find.text('Thêm vào giỏ'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('variant-confirm')));
      await tester.tap(find.byKey(const ValueKey('variant-confirm')));
      await tester.pumpAndSettle();
      expect(store.cart.single.quantity, 1);
      expect(store.cart.single.variant, 'Kem · 180cm');
      expect(order.lines.single.variant, 'Biến thể cũ');
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Đơn hàng của tôi'), findsOneWidget);
    },
  );

  testWidgets(
    'Lookup loading/error/retry preserves data and prevents duplicate dialogs',
    (tester) async {
      viewport(tester);
      final repo = MockLenlabRepository(
        latency: const Duration(milliseconds: 300),
      );
      final order = delivered([old('sheep')]);
      final store = storeFor(repo, order);
      await tester.pumpWidget(
        CustomerApp(store: store, initialRoute: '/orders'),
      );
      await tester.pumpAndSettle();
      repo.failNext('products');
      await tester.tap(find.text('Mua lại'));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('Không thể tải sản phẩm để mua lại.'), findsOneWidget);
      expect(store.cartCount, 3);
      await tester.tap(find.text('Thử lại'));
      await tester.pumpAndSettle();
      expect(find.byType(ProductDetailPage), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      expect(store.cartCount, 3);
      expect(store.orders.single, same(order));
    },
  );

  testWidgets(
    'Multi-item selection uses available current item; unavailable rows do not navigate',
    (tester) async {
      viewport(tester);
      tester.platformDispatcher.textScaleFactorTestValue = 1.2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final repo = MockLenlabRepository(latency: Duration.zero);
      repo.catalog.first.stock = 0;
      final store = storeFor(
        repo,
        delivered([old('sheep'), old('cashmere'), old('unknown')]),
      );
      await tester.pumpWidget(
        CustomerApp(store: store, initialRoute: '/orders'),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mua lại'));
      await tester.pumpAndSettle();
      expect(find.text('Sản phẩm hiện đã hết hàng.'), findsOneWidget);
      expect(
        find.text('Không tìm thấy sản phẩm trong danh mục hiện tại.'),
        findsOneWidget,
      );
      final tiles = tester.widgetList<ListTile>(find.byType(ListTile)).toList();
      expect(tiles[0].onTap, isNull);
      await tester.ensureVisible(find.text(repo.catalog[1].name));
      await tester.tap(find.text(repo.catalog[1].name));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<ProductDetailPage>(find.byType(ProductDetailPage))
            .product
            .id,
        'cashmere',
      );
      expect(store.cartCount, 3);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Missing/empty order and closed lookup recover without late navigation',
    (tester) async {
      viewport(tester);
      final repo = MockLenlabRepository(latency: Duration.zero);
      final store = storeFor(repo, delivered([old('missing')]));
      await tester.pumpWidget(
        CustomerApp(store: store, initialRoute: '/orders'),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mua lại'));
      await tester.pumpAndSettle();
      expect(find.byType(ProductDetailPage), findsNothing);
      await tester.tap(find.text('Đóng'));
      await tester.pumpAndSettle();
      final source = ControlledBuyAgain();
      final context = tester.element(find.byType(Scaffold));
      final pending = openBuyAgain(
        context,
        store.orders.single,
        source: source,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.binding.handlePopRoute();
      await tester.pump();
      source.result.complete([
        BuyAgainChoice(name: 'Now available', product: repo.catalog.first),
      ]);
      await pending;
      await tester.pumpAndSettle();
      expect(find.byType(ProductDetailPage), findsNothing);
      expect(store.cartCount, 3);
      expect(tester.takeException(), isNull);
    },
  );
}
