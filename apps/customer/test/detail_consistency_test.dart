import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_customer/app/customer_app.dart';
import 'package:lenlab_customer/app/customer_scope.dart';
import 'package:lenlab_customer/shared/widgets/header_widgets.dart';
import 'package:lenlab_customer/features/home/presentation/home_page.dart';
import 'package:lenlab_customer/features/products/presentation/product_detail_page.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

void main() {
  for (final width in [360.0, 430.0]) {
    for (final productId in ['sheep', 'cashmere']) {
      testWidgets('detail $width $productId preserves product and actions', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 895);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 1.2;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final repo = MockLenlabRepository(latency: Duration.zero);
        final store = LenlabStore(repository: repo);
        final product = repo.catalog.firstWhere((p) => p.id == productId);
        await tester.pumpWidget(
          CustomerScope(
            store: store,
            child: MaterialApp(
              theme: P2.theme(),
              home: ProductDetailPage(product: product),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(ProductDetailPage), findsOneWidget);
        expect(find.text(product.name), findsOneWidget);
        expect(
          find.text(money(product.price).replaceAll('đ', '₫')),
          findsWidgets,
        );
        expect(find.text('180cm'), findsNothing);
        expect(find.text('Bền vững'), findsNothing);
        expect(find.byType(HeaderCartIcon), findsNWidgets(2));
        {
          await tester.tap(find.text('Thêm vào giỏ'));
          await tester.pumpAndSettle();
          final line = store.cart.singleWhere(
            (l) => l.product.id == product.id,
          );
          expect(line.variant, product.detail);
          expect(line.total, product.price);
        }
        expect(tester.takeException(), isNull);
      });
    }
  }
  for (final route in ['/products']) {
    testWidgets('LENLAB in $route header returns home and clears history', (
      tester,
    ) async {
      await tester.pumpWidget(CustomerApp(initialRoute: route));
      await tester.pumpAndSettle();
      expect(find.byType(HeaderHomeLink), findsOneWidget);
      await tester.tap(find.byType(HeaderHomeLink));
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);
      expect(
        Navigator.of(tester.element(find.byType(HomePage))).canPop(),
        isFalse,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
