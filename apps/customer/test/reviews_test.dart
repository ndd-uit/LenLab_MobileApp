import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_customer/app/customer_app.dart';
import 'package:lenlab_customer/app/customer_scope.dart';
import 'package:lenlab_customer/features/products/presentation/product_detail_page.dart';
import 'package:lenlab_customer/features/products/presentation/product_unavailable_page.dart';
import 'package:lenlab_customer/features/reviews/presentation/reviews_page.dart';
import 'package:lenlab_customer/features/reviews/presentation/widgets/review_card.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

void main() {
  for (final width in [360.0, 390.0, 430.0]) {
    testWidgets(
      'reviews $width text120 filters and demo actions do not mutate state',
      (tester) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 1.2;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final store = LenlabStore(
          repository: MockLenlabRepository(latency: Duration.zero),
        );
        await tester.pumpWidget(
          CustomerScope(
            store: store,
            child: MaterialApp(
              theme: P2.theme(),
              home: const ReviewsPage(productId: 'merino'),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(ReviewCard), findsNWidgets(4));
        expect(find.text('4 đánh giá'), findsOneWidget);
        expect(find.text('4.5'), findsOneWidget);
        await tester.ensureVisible(find.text('Có hình ảnh (2)'));
        await tester.tap(find.text('Có hình ảnh (2)'));
        await tester.pumpAndSettle();
        expect(find.byType(ReviewCard), findsNWidgets(2));
        expect(find.text('Hoàng Phúc'), findsNothing);
        await tester.ensureVisible(find.text('5 Sao (3)'));
        await tester.tap(find.text('5 Sao (3)'));
        await tester.pumpAndSettle();
        expect(find.byType(ReviewCard), findsNWidgets(3));
        expect(find.text('Tuấn'), findsNothing);
        await tester.ensureVisible(find.text('Hữu ích (12)'));
        await tester.tap(find.text('Hữu ích (12)'));
        await tester.pumpAndSettle();
        expect(
          find.text('Chưa gửi lượt hữu ích trong bản dùng thử.'),
          findsOneWidget,
        );
        await tester.tap(find.text('Đóng'));
        await tester.pumpAndSettle();
        expect(find.text('Hữu ích (12)'), findsOneWidget);
        await tester.tap(find.text('Viết đánh giá của bạn'));
        await tester.pumpAndSettle();
        expect(find.textContaining('hãy mở Đơn hàng của tôi'), findsOneWidget);
        expect(find.byType(TextField), findsNothing);
        expect(store.cartCount, 0);
        expect(store.orders, isEmpty);
        expect(store.signedIn, isFalse);
        expect(mockMerinoReviews.first.helpful, 12);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets('review loading failure retries and other product stays empty', (
    tester,
  ) async {
    final repo = MockLenlabRepository(
      latency: const Duration(milliseconds: 200),
    );
    repo.failNext('reviews');
    final store = LenlabStore(repository: repo);
    Widget app(String id) => CustomerScope(
      store: store,
      child: MaterialApp(
        theme: P2.theme(),
        home: ReviewsPage(productId: id),
      ),
    );
    await tester.pumpWidget(app('merino'));
    await tester.pump(const Duration(milliseconds: 20));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('Không thể tải nhận xét'), findsOneWidget);
    await tester.tap(find.text('Thử lại'));
    await tester.pumpAndSettle();
    expect(find.byType(ReviewCard), findsNWidgets(4));
    await tester.pumpWidget(app('sheep'));
    await tester.pumpAndSettle();
    expect(find.text('Chưa có đánh giá cho sản phẩm này'), findsOneWidget);
    expect(find.text('0 đánh giá'), findsOneWidget);
    expect(find.byType(ReviewCard), findsNothing);
    expect(find.text('Minh Anh'), findsNothing);
  });
  test(
    'source scopes product and filters compute from actual immutable rows',
    () async {
      final source = MockReviewSource(
        MockLenlabRepository(latency: Duration.zero),
      );
      final merino = await source.load('merino');
      expect(merino.reviews.length, 4);
      expect(merino.average, 4.5);
      expect(merino.imageCount, 2);
      expect(merino.count(5), 3);
      expect(merino.filtered(ReviewFilter.withImages).map((r) => r.id), [
        'minh-anh',
        'tuan',
      ]);
      expect((await source.load('sheep')).reviews, isEmpty);
      final shuffled = ReviewCollection(
        productId: 'merino',
        reviews: merino.reviews.reversed.toList(),
      );
      expect(shuffled.filtered(ReviewFilter.newest).map((r) => r.id), [
        'minh-anh',
        'hoang-phuc',
        'thu-ha',
        'tuan',
      ]);
      expect(() => merino.reviews.clear(), throwsUnsupportedError);
    },
  );
  testWidgets('empty image filter can reset to all', (tester) async {
    await tester.pumpWidget(
      CustomerScope(
        store: LenlabStore(),
        child: MaterialApp(
          theme: P2.theme(),
          home: ReviewsPage(productId: 'merino', source: TextReviewSource()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Có hình ảnh (0)'));
    await tester.tap(find.text('Có hình ảnh (0)'));
    await tester.pumpAndSettle();
    expect(find.text('Không có nhận xét phù hợp'), findsOneWidget);
    await tester.ensureVisible(find.text('Xem tất cả'));
    await tester.tap(find.text('Xem tất cả'));
    await tester.pumpAndSettle();
    expect(find.text('Hoàng Phúc'), findsOneWidget);
  });
  for (final id in ['merino', 'sheep']) {
    testWidgets('detail $id opens its own reviews and back keeps product', (
      tester,
    ) async {
      final repo = MockLenlabRepository(latency: Duration.zero);
      await tester.pumpWidget(
        CustomerApp(store: LenlabStore(repository: repo)),
      );
      await tester.pumpAndSettle();
      final product = repo.catalog.firstWhere((p) => p.id == id);
      tester
          .state<NavigatorState>(find.byType(Navigator).first)
          .pushNamed('/product', arguments: product);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Xem tất cả'));
      await tester.tap(find.text('Xem tất cả'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<ReviewsPage>(find.byType(ReviewsPage)).productId,
        id,
      );
      expect(
        find.byType(ReviewCard),
        id == 'merino' ? findsNWidgets(4) : findsNothing,
      );
      await tester.tap(find.byTooltip('Quay lại'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<ProductDetailPage>(find.byType(ProductDetailPage))
            .product,
        same(product),
      );
    });
  }
  testWidgets('reviews without product id uses safe unavailable page', (
    tester,
  ) async {
    await tester.pumpWidget(CustomerApp(initialRoute: '/reviews'));
    await tester.pumpAndSettle();
    expect(find.byType(ProductUnavailablePage), findsOneWidget);
    expect(find.byType(ReviewCard), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

class TextReviewSource implements ReviewSource {
  @override
  Future<ReviewCollection> load(String productId) async =>
      ReviewCollection(productId: productId, reviews: [mockMerinoReviews[1]]);
}
