import 'lenlab_repository.dart';
import 'mock_lenlab_repository.dart';
import 'review_photo.dart';

class ReviewDraft {
  ReviewDraft({
    required this.orderId,
    required this.productId,
    required this.authorId,
    required this.rating,
    required this.text,
    List<ReviewPhoto> photos = const [],
  }) : photos = List.unmodifiable(photos);
  final String orderId, productId, authorId, text;
  final int rating;
  final List<ReviewPhoto> photos;
}

/// API implementations must validate ownership and enforce uniqueness server-side.
abstract interface class PostPurchaseReviewSource {
  Future<void> save(ReviewDraft draft);
}

class MockPostPurchaseReviewSource implements PostPurchaseReviewSource {
  MockPostPurchaseReviewSource(this.repository);
  final LenlabRepository repository;
  @override
  Future<void> save(ReviewDraft draft) async {
    if (repository case final MockLenlabRepository mock) {
      await mock.operation('submitReview');
    } else {
      throw const RepositoryException('Chưa cấu hình dịch vụ gửi đánh giá.');
    }
  }
}
