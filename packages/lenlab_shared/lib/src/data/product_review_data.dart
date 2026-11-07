import 'lenlab_repository.dart';
import 'mock_lenlab_repository.dart';
import 'review_photo.dart';

enum ReviewFilter { all, newest, withImages, fiveStars }

class ProductReview {
  ProductReview({
    required this.id,
    required this.productId,
    required this.name,
    required this.initials,
    required this.rating,
    this.date,
    this.orderId,
    this.authorId,
    required this.text,
    required this.helpful,
    required List<String> starAssets,
    List<String> photos = const [],
    List<ReviewPhoto> localPhotos = const [],
    this.avatar,
    this.variant,
    this.purchased = true,
    this.assetNode = '2026:1037',
  }) : starAssets = List.unmodifiable(starAssets),
       photos = List.unmodifiable(photos),
       localPhotos = List.unmodifiable(localPhotos);
  final String id, productId, name, initials, text;
  final int rating;
  final String? orderId, authorId;
  final int? helpful;
  final DateTime? date;
  final String assetNode;
  final List<String> starAssets, photos;
  final List<ReviewPhoto> localPhotos;
  bool get hasImages => photos.isNotEmpty || localPhotos.isNotEmpty;
  final String? avatar, variant;
  final bool purchased;
  String get dateLabel {
    final value = date;
    if (value == null) {
      return 'Chưa có ngày đánh giá';
    }
    return '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
  }
}

final mockMerinoReviews = List<ProductReview>.unmodifiable([
  ProductReview(
    id: 'minh-anh',
    productId: 'merino',
    name: 'Minh Anh',
    initials: 'MA',
    rating: 5,
    date: DateTime(2023, 10, 12),
    helpful: 12,
    text: 'Khăn len rất mềm và ấm, màu sắc đúng như hình mô tả. Mình rất thích cách shop đóng gói, thân thiện với môi trường không dùng nilon. Sẽ ủng hộ shop dài dài!',
    photos: ['imgImageBorder', 'imgImageBorder1'],
    starAssets: ['imgIcon4', 'imgIcon5', 'imgIcon6', 'imgIcon4', 'imgIcon7'],
  ),
  ProductReview(
    id: 'hoang-phuc',
    productId: 'merino',
    name: 'Hoàng Phúc',
    initials: 'HP',
    rating: 5,
    date: DateTime(2023, 10, 5),
    helpful: 3,
    variant: 'Màu Nâu',
    text: 'Chất lượng len tốt, không bị xù lông. Tuy nhiên giao hàng hơi chậm một chút do bên vận chuyển (mất 4 ngày). Nhưng bù lại sản phẩm đẹp nên vẫn cho 4 sao.',
    starAssets: ['imgIcon4', 'imgIcon4', 'imgIcon4', 'imgIcon4', 'imgIcon4'],
  ),
  ProductReview(
    id: 'thu-ha',
    productId: 'merino',
    name: 'Thu Hà',
    initials: '',
    rating: 5,
    date: DateTime(2023, 9, 28),
    helpful: 8,
    avatar: 'imgImage',
    text: 'Tuyệt vời! Mua tặng mẹ mà mẹ khen mãi. Len Merino này sờ vào mát tay mà lại rất ấm. Rất đáng tiền.',
    starAssets: ['imgIcon4', 'imgIcon8', 'imgIcon4', 'imgIcon9', 'imgIcon4'],
  ),
  ProductReview(
    id: 'tuan',
    productId: 'merino',
    name: 'Tuấn',
    initials: 'T',
    rating: 3,
    date: DateTime(2023, 9, 20),
    helpful: 1,
    text: 'Sản phẩm ổn, nhưng màu sắc thực tế hơi tối hơn so với ảnh chụp studio.',
    photos: ['imgImageBorder2'],
    starAssets: ['imgIcon10', 'imgIcon4', 'imgIcon4', 'imgIcon11', 'imgIcon11'],
  ),
]);

final mockProductReviews = List<ProductReview>.unmodifiable(mockMerinoReviews);

class ReviewCollection {
  ReviewCollection({
    required this.productId,
    required List<ProductReview> reviews,
  }) : reviews = List.unmodifiable(
         reviews.where((r) => r.productId == productId),
       );
  final String productId;
  final List<ProductReview> reviews;
  double get average => reviews.isEmpty
      ? 0
      : reviews.fold<int>(0, (sum, r) => sum + r.rating) / reviews.length;
  int get imageCount => reviews.where((r) => r.hasImages).length;
  int count(int stars) => reviews.where((r) => r.rating == stars).length;
  List<ProductReview> filtered(ReviewFilter filter) {
    final items = reviews
        .where(
          (r) => switch (filter) {
            ReviewFilter.withImages => r.hasImages,
            ReviewFilter.fiveStars => r.rating == 5,
            _ => true,
          },
        )
        .toList();
    if (filter == ReviewFilter.newest) {
      items.sort((a, b) {
        final left = a.date, right = b.date;
        if (left == null) {
          return right == null ? 0 : 1;
        }
        if (right == null) {
          return -1;
        }
        return right.compareTo(left);
      });
    }
    return List.unmodifiable(items);
  }
}

abstract interface class ReviewSource {
  Future<ReviewCollection> load(String productId);
}

class MockReviewSource implements ReviewSource {
  MockReviewSource(this.repository, {List<ProductReview>? reviews})
    : reviews = List.unmodifiable(reviews ?? mockProductReviews);
  final LenlabRepository repository;
  final List<ProductReview> reviews;
  @override
  Future<ReviewCollection> load(String productId) async {
    if (repository case final MockLenlabRepository mock) {
      await mock.operation('reviews');
    } else {
      throw const RepositoryException('Chưa cấu hình nguồn nhận xét.');
    }
    return ReviewCollection(productId: productId, reviews: reviews);
  }
}
