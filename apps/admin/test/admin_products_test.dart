import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_admin/features/products/data/admin_products_source.dart';
import 'package:lenlab_admin/features/products/presentation/admin_products_content.dart';
import 'package:lenlab_admin/features/products/presentation/widgets/products_table.dart';
import 'package:lenlab_admin/features/products/presentation/widgets/products_pagination.dart';
import 'package:lenlab_admin/features/products/presentation/widgets/products_header.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

Widget host(AdminProductsSource source) => MaterialApp(
  theme: P2.theme(admin: true),
  home: Scaffold(
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: AdminProductsContent(source: source),
    ),
  ),
);

class ControlledProducts implements AdminProductsSource {
  final requests = <(AdminProductsQuery, Completer<AdminProductsResult>)>[];
  @override
  Future<AdminProductsResult> fetch(AdminProductsQuery query) {
    final completer = Completer<AdminProductsResult>();
    requests.add((query, completer));
    return completer.future;
  }
}

void wide(WidgetTester tester, {double width = 1280, double scale = 1}) {
  tester.view.physicalSize = Size(width, 1300);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

void main() {
  testWidgets('Read-only toolbar and filter summary support keyboard dismiss', (
    tester,
  ) async {
    wide(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: P2.theme(admin: true),
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                const ProductsHeader(),
                AdminProductsContent(source: MockAdminProductsSource()),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    for (final label in ['Thêm mới', 'Xóa mục đã chọn']) {
      final button = find.ancestor(
        of: find.text(label),
        matching: find.byWidgetPredicate(
          (widget) => widget is ButtonStyleButton,
        ),
      );
      expect(tester.widget<ButtonStyleButton>(button).onPressed, isNull);
    }
    await tester.enterText(
      find.byKey(const ValueKey('products-search')),
      'MK-GAU',
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('MK-GAU-\n003'), findsOneWidget);
    await tester.tap(find.byTooltip('Bộ lọc đang áp dụng'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('MK-GAU-\n003'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Large totals keep pagination compact and allow last page', (
    tester,
  ) async {
    var selected = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductsPagination(
            result: AdminProductsResult(items: [], total: 5000, page: 50),
            onPage: (value) => selected = value,
          ),
        ),
      ),
    );
    expect(find.byType(OutlinedButton).evaluate().length, lessThanOrEqualTo(7));
    await tester.tap(find.byTooltip('Trang 1000'));
    await tester.pumpAndSettle();
    expect(selected, 1000);
  });
  test('Source combines filters before pagination, clamps pages and has immutable results', () async {
    final source = MockAdminProductsSource(latency: Duration.zero);
    final first = await source.fetch(const AdminProductsQuery());
    final second = await source.fetch(const AdminProductsQuery(page: 2));
    expect(first.total, 12);
    expect(first.start, 1);
    expect(first.end, 5);
    expect(first.pages, 3);
    expect(second.start, 6);
    expect(second.end, 10);
    expect(
      first.items
          .map((p) => p.sku)
          .toSet()
          .intersection(second.items.map((p) => p.sku).toSet()),
      isEmpty,
    );
    final last = await source.fetch(const AdminProductsQuery(page: 100));
    expect(last.page, 3);
    expect(last.end, 12);
    final filtered = await source.fetch(
      const AdminProductsQuery(
        search: '  mk-gau  ',
        category: ProductCategory.toys,
        visibility: ProductVisibility.hidden,
      ),
    );
    expect(filtered.items.single.sku, 'MK-GAU-003');
    final empty = await source.fetch(
      const AdminProductsQuery(
        search: 'mk-gau',
        category: ProductCategory.fashion,
      ),
    );
    expect(empty.total, 0);
    expect(empty.start, 0);
    expect(empty.end, 0);
    expect(() => first.items.clear(), throwsUnsupportedError);
  });
  testWidgets(
    'Search, filters, pagination reset and empty/clear work together',
    (tester) async {
      wide(tester);
      await tester.pumpWidget(host(MockAdminProductsSource()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('Hiển thị 1-5 trong số 12 sản phẩm'), findsOneWidget);
      await tester.tap(find.byTooltip('Trang 2'));
      await tester.pumpAndSettle();
      expect(find.text('Hiển thị 6-10 trong số 12 sản phẩm'), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('products-search')),
        'Móc khóa',
      );
      await tester.pumpAndSettle();
      expect(find.text('Hiển thị 1-3 trong số 3 sản phẩm'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('products-visibility')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Đang ẩn').last);
      await tester.pumpAndSettle();
      expect(find.text('MK-GAU-\n003'), findsOneWidget);
      expect(find.text('MK-MEO-\n001'), findsNothing);
      await tester.tap(find.byKey(const ValueKey('products-category')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Thời trang & Phụ kiện').last);
      await tester.pumpAndSettle();
      expect(find.text('Không có sản phẩm'), findsOneWidget);
      await tester.tap(find.text('Xóa bộ lọc'));
      await tester.pumpAndSettle();
      expect(find.text('Hiển thị 1-5 trong số 12 sản phẩm'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('Retry preserves page and last page disables next', (
    tester,
  ) async {
    wide(tester);
    final source = MockAdminProductsSource();
    await tester.pumpWidget(host(source));
    await tester.pumpAndSettle();
    source.failNext = true;
    await tester.tap(find.byTooltip('Trang 2'));
    await tester.pumpAndSettle();
    expect(find.text('Không thể tải danh sách sản phẩm'), findsOneWidget);
    expect(find.byType(ProductsTable), findsNothing);
    await tester.tap(find.text('Thử lại'));
    await tester.pumpAndSettle();
    expect(find.text('Hiển thị 6-10 trong số 12 sản phẩm'), findsOneWidget);
    await tester.tap(find.byTooltip('Trang sau'));
    await tester.pumpAndSettle();
    expect(find.text('Hiển thị 11-12 trong số 12 sản phẩm'), findsOneWidget);
    final next = find.descendant(
      of: find.byTooltip('Trang sau'),
      matching: find.byType(OutlinedButton),
    );
    expect(tester.widget<OutlinedButton>(next).onPressed, isNull);
  });
  testWidgets('Older success/error cannot replace latest search result', (
    tester,
  ) async {
    wide(tester);
    final source = ControlledProducts();
    await tester.pumpWidget(host(source));
    await tester.enterText(
      find.byKey(const ValueKey('products-search')),
      'gấu',
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(
      find.byKey(const ValueKey('products-search')),
      'mèo',
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(source.requests.length, 3);
    source.requests.last.$2.complete(
      AdminProductsResult(
        items: [adminProductFixtures.first],
        total: 1,
        page: 1,
      ),
    );
    await tester.pumpAndSettle();
    source.requests[1].$2.completeError(StateError('Old failure'));
    source.requests.first.$2.complete(
      AdminProductsResult(items: [adminProductFixtures[2]], total: 1, page: 1),
    );
    await tester.pumpAndSettle();
    expect(find.text('MK-MEO-\n001'), findsOneWidget);
    expect(find.text('MK-GAU-\n003'), findsNothing);
    expect(find.text('Không thể tải danh sách sản phẩm'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Empty source and disposal during fetch are safe', (
    tester,
  ) async {
    await tester.pumpWidget(host(MockAdminProductsSource(products: [])));
    await tester.pumpAndSettle();
    expect(find.text('Danh sách sản phẩm hiện đang trống.'), findsOneWidget);
    final source = ControlledProducts();
    await tester.pumpWidget(host(source));
    await tester.pumpWidget(const SizedBox());
    source.requests.single.$2.completeError(StateError('Late failure'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
  for (final width in [390.0, 800.0, 1280.0]) {
    testWidgets('Read-only table scrolls at $width / 120% text', (
      tester,
    ) async {
      wide(tester, width: width, scale: 1.2);
      await tester.pumpWidget(host(MockAdminProductsSource()));
      await tester.pumpAndSettle();
      expect(find.byType(Switch), findsNothing);
      final horizontal = find.descendant(
        of: find.byType(ProductsTable),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is SingleChildScrollView &&
              widget.scrollDirection == Axis.horizontal,
        ),
      );
      await tester.drag(horizontal, const Offset(-800, 0));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Hiển thị 1-5 trong số 12 sản phẩm'), findsOneWidget);
    });
  }
}
