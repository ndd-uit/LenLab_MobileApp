import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_customer/app/customer_app.dart';
import 'package:lenlab_customer/features/catalog/presentation/widgets/catalog_product_card.dart';
import 'package:lenlab_customer/features/products/presentation/widgets/detail_reviews.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

void main() {
  testWidgets(
    'injected reviews drive catalog detail and review list, not legacy Product.rating',
    (tester) async {
      final repo = MockLenlabRepository(latency: Duration.zero);
      final sheep = repo.catalog.firstWhere((p) => p.id == 'sheep')..rating = 5;
      final store = LenlabStore(
        repository: repo,
        productReviews: [
          ProductReview(
            id: 'test-sheep',
            productId: 'sheep',
            name: 'Người thử',
            initials: 'NT',
            rating: 3,
            date: DateTime(2026, 1, 1),
            text: 'Nhận xét thử riêng cho cừu.',
            helpful: 0,
            starAssets: [
              'imgIcon4',
              'imgIcon4',
              'imgIcon4',
              'imgIcon11',
              'imgIcon11',
            ],
          ),
        ],
      );
      await tester.pumpWidget(
        CustomerApp(store: store, initialRoute: '/products'),
      );
      await tester.pumpAndSettle();
      final sheepCard = find.byWidgetPredicate(
        (w) => w is CatalogProductCard && w.product.id == 'sheep',
      );
      expect(
        find.descendant(of: sheepCard, matching: find.text('3.0')),
        findsOneWidget,
      );
      expect(find.text('5.0'), findsNothing);
      await tester.ensureVisible(
        find.descendant(of: sheepCard, matching: find.text(sheep.name)),
      );
      await tester.tap(
        find.descendant(of: sheepCard, matching: find.text(sheep.name)),
      );
      await tester.pumpAndSettle();
      expect(find.text('3.0'), findsNWidgets(2));
      await tester.ensureVisible(find.byType(DetailReviews));
      expect(find.text('1 nhận xét'), findsOneWidget);
      final bars = tester
          .widgetList<LinearProgressIndicator>(
            find.descendant(
              of: find.byType(DetailReviews),
              matching: find.byType(LinearProgressIndicator),
            ),
          )
          .toList();
      expect(bars.map((b) => b.value), [0, 0, 1, 0, 0]);
      await tester.ensureVisible(find.text('Xem tất cả'));
      await tester.tap(find.text('Xem tất cả'));
      await tester.pumpAndSettle();
      expect(find.text('3.0'), findsOneWidget);
      expect(find.text('1 đánh giá'), findsOneWidget);
      expect(find.text('Người thử'), findsOneWidget);
      expect(find.text('Minh Anh'), findsNothing);
      expect(store.cartCount, 0);
      expect(store.orders.length, 0);
      expect(sheep.rating, 5);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'empty product has no rating badge and both review views say zero',
    (tester) async {
      final repo = MockLenlabRepository(latency: Duration.zero);
      await tester.pumpWidget(
        CustomerApp(
          store: LenlabStore(repository: repo),
          initialRoute: '/products',
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('4.9'), findsNothing);
      expect(find.text('5.0'), findsNothing);
      await tester.ensureVisible(find.text(repo.catalog.first.name));
      await tester.tap(find.text(repo.catalog.first.name));
      await tester.pumpAndSettle();
      expect(find.text('4.9'), findsNothing);
      expect(find.text('0 nhận xét'), findsOneWidget);
      await tester.ensureVisible(find.text('Xem tất cả'));
      await tester.tap(find.text('Xem tất cả'));
      await tester.pumpAndSettle();
      expect(find.text('0 đánh giá'), findsOneWidget);
      expect(find.text('—'), findsOneWidget);
      expect(find.text('Chưa có đánh giá cho sản phẩm này'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
