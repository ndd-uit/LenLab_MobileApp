import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_customer/app/customer_app.dart';
import 'package:lenlab_customer/features/products/presentation/widgets/merino_variant_sheet.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

Future<LenlabStore> open(WidgetTester tester) async {
  final repo = MockLenlabRepository(latency: Duration.zero);
  final store = LenlabStore(repository: repo)..cart.clear();
  await tester.pumpWidget(CustomerApp(store: store));
  await tester.pumpAndSettle();
  tester
      .state<NavigatorState>(find.byType(Navigator))
      .pushNamed(
        '/product',
        arguments: repo.catalog.firstWhere((p) => p.id == 'merino'),
      );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Thêm vào giỏ'));
  await tester.pumpAndSettle();
  return store;
}

void main() {
  for (final width in [360.0, 390.0, 430.0]) {
    testWidgets(
      'Variant sheet $width text120 selects and totals, confirm uses canonical variant',
      (tester) async {
        tester.view.physicalSize = Size(width, 884);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 1.2;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final store = await open(tester);
        expect(find.byType(MerinoVariantSheet), findsOneWidget);
        expect(store.cart, isEmpty);
        final sheet = find.byType(MerinoVariantSheet);
        await tester.tap(
          find.descendant(of: sheet, matching: find.text('Nâu')),
        );
        await tester.ensureVisible(
          find.descendant(of: sheet, matching: find.text('200 cm')),
        );
        await tester.tap(
          find.descendant(of: sheet, matching: find.text('200 cm')),
        );
        await tester.ensureVisible(find.text('+'));
        await tester.tap(find.text('+'));
        await tester.pump();
        expect(find.text('Nâu · 200 cm · 2 sản phẩm'), findsOneWidget);
        expect(find.text('Thêm vào giỏ · 1.100.000đ'), findsOneWidget);
        await tester.ensureVisible(
          find.byKey(const ValueKey('variant-confirm')),
        );
        await tester.tap(find.byKey(const ValueKey('variant-confirm')));
        await tester.pumpAndSettle();
        expect(store.cart.single.variant, 'Nâu · 200cm');
        expect(store.cart.single.quantity, 2);
        expect(store.orders.length, 0);
        expect(find.byType(MerinoVariantSheet), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'Cancel/Back discard selections; Be maps to Kem and merges existing cart key',
    (tester) async {
      final store = await open(tester);
      await tester.tap(find.text('Nâu').last);
      await tester.ensureVisible(find.text('Hủy lựa chọn'));
      await tester.tap(find.text('Hủy lựa chọn'));
      await tester.pumpAndSettle();
      expect(store.cart, isEmpty);
      await tester.tap(find.text('Thêm vào giỏ'));
      await tester.pumpAndSettle();
      expect(find.text('Màu sắc: Be tự nhiên'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(store.cart, isEmpty);
      final product = (store.repository as MockLenlabRepository).catalog
          .firstWhere((p) => p.id == 'merino');
      store.addToCart(product, 1, 'Kem · 180cm');
      await tester.tap(find.text('Thêm vào giỏ'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('variant-confirm')));
      await tester.tap(find.byKey(const ValueKey('variant-confirm')));
      await tester.pumpAndSettle();
      expect(store.cart.single.variant, 'Kem · 180cm');
      expect(store.cart.single.quantity, 2);
    },
  );

  testWidgets(
    'Stock change while sheet is open blocks confirmation and preserves draft',
    (tester) async {
      final store = await open(tester);
      final product = (store.repository as MockLenlabRepository).catalog
          .firstWhere((p) => p.id == 'merino');
      product.stock = 0;
      await tester.ensureVisible(find.byKey(const ValueKey('variant-confirm')));
      await tester.tap(find.byKey(const ValueKey('variant-confirm')));
      await tester.pumpAndSettle();
      expect(store.cart, isEmpty);
      expect(find.byType(MerinoVariantSheet), findsOneWidget);
    },
  );
}
