import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_customer/app/customer_app.dart';
import 'package:lenlab_customer/features/auth/presentation/auth_page.dart';
import 'package:lenlab_customer/features/catalog/presentation/catalog_page.dart';
import 'package:lenlab_customer/features/profile/presentation/profile_page.dart';
import 'package:lenlab_customer/features/products/presentation/product_detail_page.dart';
import 'package:lenlab_customer/features/products/presentation/product_unavailable_page.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

void main() {
  testWidgets('catalog account uses current session after login and logout', (
    tester,
  ) async {
    final store = LenlabStore(
      repository: MockLenlabRepository(latency: Duration.zero),
    );
    await tester.pumpWidget(
      CustomerApp(store: store, initialRoute: '/products'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Tài khoản'));
    await tester.pumpAndSettle();
    expect(find.byType(AuthPage), findsOneWidget);
    final navigator = tester.state<NavigatorState>(
      find.byType(Navigator).first,
    );
    navigator.pop();
    store.signedIn = true;
    store.coupon = 'LEN50';
    store.changed();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Tài khoản'));
    await tester.pumpAndSettle();
    expect(find.byType(ProfilePage), findsOneWidget);
    expect(find.byType(AuthPage), findsNothing);
    navigator.pop();
    store.signedIn = false;
    store.changed();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Tài khoản'));
    await tester.pumpAndSettle();
    expect(find.byType(AuthPage), findsOneWidget);
    expect(store.cartCount, 0);
    expect(store.orders, isEmpty);
    expect(tester.takeException(), isNull);
  });

  for (final payload in <Object?>[
    null,
    'unknown-product-id',
    {'id': 'merino'},
  ]) {
    testWidgets(
      'product route rejects invalid payload $payload and back preserves catalog',
      (tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 1.2;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final store = LenlabStore(
          repository: MockLenlabRepository(latency: Duration.zero),
        );
        await tester.pumpWidget(
          CustomerApp(store: store, initialRoute: '/products'),
        );
        await tester.pumpAndSettle();
        final navigator = tester.state<NavigatorState>(
          find.byType(Navigator).first,
        );
        navigator.pushNamed('/product', arguments: payload);
        await tester.pumpAndSettle();
        expect(find.byType(ProductUnavailablePage), findsOneWidget);
        expect(find.text('Không tìm thấy sản phẩm'), findsOneWidget);
        expect(find.byType(ProductDetailPage), findsNothing);
        expect(find.text('Thêm vào giỏ'), findsNothing);
        expect(store.cartCount, 0);
        expect(store.orders, isEmpty);
        expect(tester.takeException(), isNull);
        await tester.tap(find.byTooltip('Quay lại'));
        await tester.pumpAndSettle();
        expect(find.byType(CatalogPage), findsOneWidget);
        expect(find.byType(ProductUnavailablePage), findsNothing);
      },
    );
  }

  testWidgets(
    'missing product at initial route can open catalog without crashing',
    (tester) async {
      await tester.pumpWidget(
        CustomerApp(
          initialRoute: '/product',
          store: LenlabStore(
            repository: MockLenlabRepository(latency: Duration.zero),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ProductUnavailablePage), findsOneWidget);
      await tester.tap(find.text('Xem sản phẩm'));
      await tester.pumpAndSettle();
      expect(find.byType(CatalogPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  for (final productId in ['sheep', 'cashmere']) {
    testWidgets('valid $productId product route keeps exact object', (
      tester,
    ) async {
      final repo = MockLenlabRepository(latency: Duration.zero);
      final product = repo.catalog.firstWhere((p) => p.id == productId);
      await tester.pumpWidget(
        CustomerApp(
          store: LenlabStore(repository: repo),
          initialRoute: '/products',
        ),
      );
      await tester.pumpAndSettle();
      tester
          .state<NavigatorState>(find.byType(Navigator).first)
          .pushNamed('/product', arguments: product);
      await tester.pumpAndSettle();
      final detail = tester.widget<ProductDetailPage>(
        find.byType(ProductDetailPage),
      );
      expect(detail.product, same(product));
      expect(find.text(product.name), findsOneWidget);
      expect(find.byType(ProductUnavailablePage), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
