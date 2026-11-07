import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_customer/app/customer_scope.dart';
import 'package:lenlab_customer/features/products/presentation/product_detail_page.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

void main() {
  Future<LenlabStore> open(WidgetTester tester, {int stock = 45}) async {
    final repo = MockLenlabRepository(latency: Duration.zero);
    final product = repo.catalog.firstWhere((p) => p.id == 'merino')
      ..stock = stock;
    final store = LenlabStore(repository: repo);
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
    return store;
  }

  for (final width in [360.0, 390.0, 430.0]) {
    testWidgets(
      'Merino $width enlarged text scrolls and adds selected variant',
      (tester) async {
        tester.view.physicalSize = Size(width, 895);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 1.2;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final store = await open(tester);
        await tester.ensureVisible(find.byTooltip('Nâu'));
        await tester.tap(find.byTooltip('Nâu'));
        await tester.ensureVisible(find.text('200cm'));
        await tester.tap(find.text('200cm'));
        await tester.tap(find.byTooltip('Tăng số lượng'));
        await tester.tap(find.text('Thêm vào giỏ'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(
          find.byKey(const ValueKey('variant-confirm')),
        );
        await tester.tap(find.byKey(const ValueKey('variant-confirm')));
        await tester.pumpAndSettle();
        final line = store.cart.singleWhere((l) => l.product.id == 'merino');
        expect(line.variant, 'Nâu · 200cm');
        expect(line.quantity, 2);
        expect(line.total, 1100000);
        await tester.ensureVisible(find.text('Có thể bạn cũng thích'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets('Merino stock bounds and cart merge prevent exceeding stock', (
    tester,
  ) async {
    final store = await open(tester, stock: 2);
    expect(
      tester
          .widget<IconButton>(
            find.byWidgetPredicate(
              (w) => w is IconButton && w.tooltip == 'Giảm số lượng',
            ),
          )
          .onPressed,
      isNull,
    );
    await tester.tap(find.byTooltip('Tăng số lượng'));
    await tester.pump();
    expect(
      tester
          .widget<IconButton>(
            find.byWidgetPredicate(
              (w) => w is IconButton && w.tooltip == 'Tăng số lượng',
            ),
          )
          .onPressed,
      isNull,
    );
    await tester.tap(find.text('Thêm vào giỏ'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('variant-confirm')));
    await tester.tap(find.byKey(const ValueKey('variant-confirm')));
    await tester.pump();
    await tester.tap(find.text('Thêm vào giỏ'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('variant-confirm')));
    await tester.tap(find.byKey(const ValueKey('variant-confirm')));
    await tester.pump();
    expect(store.cart.singleWhere((l) => l.product.id == 'merino').quantity, 2);
    await tester.pumpAndSettle();
    expect(
      find.text('Số lượng trong giỏ vượt tồn kho hiện có.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Hủy lựa chọn'));
    await tester.pumpAndSettle();
  });
  testWidgets('Merino favorite, missing measurement and description work', (
    tester,
  ) async {
    final store = await open(tester);
    store.signedIn = true;
    await tester.pump();
    await tester.tap(find.byTooltip('Yêu thích'));
    await tester.pump();
    expect(store.favorites, contains('merino'));
    await tester.ensureVisible(find.text('Hướng dẫn đo'));
    await tester.tap(find.text('Hướng dẫn đo'));
    await tester.pumpAndSettle();
    expect(find.text('Hướng dẫn đo'), findsWidgets);
    Navigator.of(tester.element(find.byType(AlertDialog))).pop();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Xem thêm...'));
    await tester.tap(find.text('Xem thêm...'));
    await tester.pump();
    expect(find.text('Thu gọn'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
