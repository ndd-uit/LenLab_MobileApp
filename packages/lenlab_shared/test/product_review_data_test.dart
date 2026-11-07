import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

void main() {
  test(
    'newest keeps undated reviews last and does not assign a synthetic date',
    () {
      final undated = ProductReview(
        id: 'unknown-date',
        productId: 'merino',
        name: 'Test',
        initials: 'T',
        rating: 5,
        text: 'Không có ngày',
        helpful: null,
        starAssets: [],
      );
      final collection = ReviewCollection(
        productId: 'merino',
        reviews: [undated, ...mockMerinoReviews],
      );
      expect(collection.filtered(ReviewFilter.newest).last, same(undated));
      expect(undated.dateLabel, 'Chưa có ngày đánh giá');
      expect(undated.date, isNull);
    },
  );
  test(
    'store and async review source derive the same summary for every product',
    () async {
      final repo = MockLenlabRepository(latency: Duration.zero);
      final store = LenlabStore(repository: repo);
      final source = MockReviewSource(repo, reviews: store.productReviews);
      for (final product in repo.catalog) {
        final snapshot = store.reviewsFor(product.id);
        final loaded = await source.load(product.id);
        expect(snapshot.average, loaded.average);
        expect(snapshot.reviews.length, loaded.reviews.length);
        for (var star = 1; star <= 5; star++) {
          expect(snapshot.count(star), loaded.count(star));
        }
        expect(
          snapshot.reviews.every((r) => r.productId == product.id),
          isTrue,
        );
      }
      expect(store.reviewsFor('merino').average, 4.5);
      expect(store.reviewsFor('merino').reviews.length, 4);
      expect(store.reviewsFor('sheep').reviews, isEmpty);
    },
  );
  test('review snapshot does not invent rating when there are no rows', () {
    final store = LenlabStore(productReviews: []);
    expect(store.reviewsFor('merino').reviews, isEmpty);
    expect(store.reviewsFor('merino').average, 0);
    expect(store.reviewsFor('unknown').imageCount, 0);
    expect(store.cartCount, 0);
    expect(store.orders.length, 0);
  });
  test('fixture and nested photo/star lists cannot be edited by consumers', () {
    final store = LenlabStore();
    expect(() => store.productReviews.clear(), throwsUnsupportedError);
    expect(
      () => store.productReviews.first.photos.clear(),
      throwsUnsupportedError,
    );
    expect(
      () => store.productReviews.first.starAssets.clear(),
      throwsUnsupportedError,
    );
  });
}
