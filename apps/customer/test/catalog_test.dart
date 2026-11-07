import 'package:lenlab_customer/features/catalog/presentation/widgets/catalog_product_card.dart';
import 'package:lenlab_customer/features/catalog/presentation/widgets/catalog_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_customer/app/customer_app.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

void main() {
  for (final width in [360.0, 390.0, 430.0]) {
    testWidgets(
      'card buttons align at $width with large text and an old price',
      (tester) async {
        tester.view.physicalSize = Size(width, 929);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 1.2;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpWidget(
          CustomerApp(
            initialRoute: '/products',
            store: LenlabStore(
              repository: MockLenlabRepository(latency: Duration.zero),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final left = find.byWidgetPredicate(
          (w) =>
              w is IconButton &&
              w.tooltip == 'Chọn biến thể Combo Len Sợi Loang Màu Pastel',
        );
        final right = find.byWidgetPredicate(
          (w) =>
              w is IconButton &&
              w.tooltip == 'Chọn biến thể Móc Khoá Củ Cà Rốt Mini',
        );
        expect(
          tester.getCenter(left).dy,
          closeTo(tester.getCenter(right).dy, .1),
        );
        final card = find
            .ancestor(of: left, matching: find.byType(CatalogProductCard))
            .first;
        expect(
          tester.getRect(left).right,
          closeTo(tester.getRect(card).right, .1),
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'loading resolves to data; pagination and sorting reset correctly',
    (tester) async {
      tester.view.physicalSize = const Size(390, 895);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        CustomerApp(
          initialRoute: '/products',
          store: LenlabStore(
            repository: MockLenlabRepository(
              latency: const Duration(milliseconds: 500),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(CatalogLoading), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.byType(CatalogProductCard), findsNWidgets(6));
      await tester.ensureVisible(find.byTooltip('Trang sau'));
      await tester.tap(find.byTooltip('Trang sau'));
      await tester.pumpAndSettle();
      expect(find.byType(CatalogProductCard), findsNWidgets(6));
      expect(
        tester
            .widgetList<CatalogProductCard>(find.byType(CatalogProductCard))
            .first
            .product
            .id,
        'merino',
      );
      await tester.tap(find.byTooltip('Sắp xếp'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(CheckedPopupMenuItem<String>, 'Giá tăng dần'),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widgetList<CatalogProductCard>(find.byType(CatalogProductCard))
            .first
            .product
            .id,
        'carrot',
      );
      expect(find.byType(CatalogProductCard), findsNWidgets(6));
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'category sheet, empty reset and keyboard search preserve usable controls',
    (tester) async {
      tester.view.physicalSize = const Size(360, 844);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(
        CustomerApp(
          initialRoute: '/products',
          store: LenlabStore(
            repository: MockLenlabRepository(latency: Duration.zero),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lọc'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Nguyên phụ liệu'));
      await tester.pumpAndSettle();
      expect(find.byType(CatalogProductCard), findsOneWidget);
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await tester.enterText(find.byType(TextField), 'không tồn tại');
      await tester.pumpAndSettle();
      expect(find.text('Không có kết quả'), findsOneWidget);
      await tester.ensureVisible(find.text('Xóa bộ lọc'));
      await tester.tap(find.text('Xóa bộ lọc'));
      await tester.pumpAndSettle();
      expect(find.byType(CatalogProductCard), findsNWidgets(6));
      expect(tester.takeException(), isNull);
    },
  );
}
