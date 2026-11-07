import 'package:lenlab_customer/features/home/presentation/widgets/home_categories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_customer/app/customer_app.dart';
import 'package:lenlab_customer/features/products/presentation/product_detail_page.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

void main() {
  for (final width in [360.0, 390.0, 430.0]) {
    testWidgets(
      'home $width with 120% text scrolls through campaign and footer',
      (tester) async {
        tester.view.physicalSize = Size(width, 844);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 1.2;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpWidget(CustomerApp());
        await tester.pumpAndSettle();
        expect(find.text('BEST SELLER'), findsOneWidget);
        expect(find.text('-20%'), findsOneWidget);
        await tester.ensureVisible(find.byKey(const ValueKey('home-campaign')));
        await tester.pumpAndSettle();
        expect(find.text('Giảm 15% cho đơn hàng đầu tiên.'), findsOneWidget);
        await tester.ensureVisible(
          find.text('© ${DateTime.now().year} LENLAB. All rights reserved.'),
        );
        await tester.pumpAndSettle();
        expect(find.text('KHÁM PHÁ'), findsOneWidget);
        expect(find.text('HỖ TRỢ'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets('header opens drawer and product search; account opens login', (
    tester,
  ) async {
    await tester.pumpWidget(
      CustomerApp(
        store: LenlabStore(
          repository: MockLenlabRepository(latency: Duration.zero),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Mở menu'));
    await tester.pumpAndSettle();
    expect(find.byType(Drawer), findsOneWidget);
    final products = find.descendant(
      of: find.byType(Drawer),
      matching: find.text('Sản phẩm'),
    );
    await tester.tap(products);
    await tester.pumpAndSettle();
    expect(find.text('Thú Bông Cừu Handmade Size L'), findsOneWidget);
    tester.state<NavigatorState>(find.byType(Navigator).first).pop();
    await tester.pumpAndSettle();
    final search = find.byTooltip('Tìm kiếm sản phẩm');
    await tester.tap(search);
    await tester.pumpAndSettle();
    expect(find.text('Thú Bông Cừu Handmade Size L'), findsOneWidget);
    tester.state<NavigatorState>(find.byType(Navigator).first).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Tài khoản'));
    await tester.pumpAndSettle();
    expect(find.text('Chào mừng bạn trở lại!'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'featured card carries the same product name and price into details',
    (tester) async {
      await tester.pumpWidget(CustomerApp());
      await tester.pumpAndSettle();
      final featured = find.text('Áo Len Cổ Lọ Handknit');
      await tester.ensureVisible(featured);
      await tester.tap(featured);
      await tester.pumpAndSettle();
      expect(find.text('Áo Len Cổ Lọ Handknit'), findsOneWidget);
      expect(
        tester
            .widget<ProductDetailPage>(find.byType(ProductDetailPage))
            .product
            .price,
        850000,
      );
      expect(find.text('850.000₫'), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'social link reports missing destination without guessing a URL',
    (tester) async {
      await tester.pumpWidget(CustomerApp());
      await tester.pumpAndSettle();
      final facebook = find.byTooltip('Facebook');
      await tester.ensureVisible(facebook);
      await tester.tap(facebook);
      await tester.pumpAndSettle();
      expect(find.text('Kênh Facebook'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('home category opens the matching catalog filter', (
    tester,
  ) async {
    await tester.pumpWidget(
      CustomerApp(
        store: LenlabStore(
          repository: MockLenlabRepository(latency: Duration.zero),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final category = find.descendant(
      of: find.byType(HomeCategories),
      matching: find.text('Nguyên phụ liệu'),
    );
    await tester.ensureVisible(category);
    await tester.tap(category);
    await tester.pumpAndSettle();
    expect(find.text('Combo Len Sợi Loang Màu Pastel'), findsOneWidget);
    expect(find.text('Thú Bông Cừu Handmade Size L'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
