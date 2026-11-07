enum AdminReviewStatus {
  pending('Chờ duyệt'),
  approved('Đã duyệt');

  const AdminReviewStatus(this.label);
  final String label;
}

enum AdminReviewFilter { all, pending, fiveStars, withImages }

class AdminReview {
  const AdminReview({
    required this.id,
    required this.customerName,
    required this.productName,
    required this.rating,
    required this.comment,
    required this.timeLabel,
    required this.status,
    this.avatarAlias,
    this.productAlias,
    this.photos = const [],
  });
  final String id, customerName, productName, comment, timeLabel;
  final int rating;
  final AdminReviewStatus status;
  final String? avatarAlias, productAlias;
  final List<String> photos;
}

class AdminReviewsQuery {
  const AdminReviewsQuery({
    this.search = '',
    this.filter = AdminReviewFilter.all,
    this.stars,
    this.page = 1,
  });
  static const pageSize = 3;
  final String search;
  final AdminReviewFilter filter;
  final int? stars;
  final int page;
}

class AdminReviewsResult {
  AdminReviewsResult({
    required List<AdminReview> items,
    required this.total,
    required this.page,
    required this.pendingCount,
  }) : items = List.unmodifiable(items);
  final List<AdminReview> items;
  final int total, page, pendingCount;
  int get pages => (total / AdminReviewsQuery.pageSize).ceil();
  int get start => total == 0 ? 0 : (page - 1) * AdminReviewsQuery.pageSize + 1;
  int get end => total == 0 ? 0 : start + items.length - 1;
}

abstract interface class AdminReviewsSource {
  Future<AdminReviewsResult> fetch(AdminReviewsQuery query);
}

class MockAdminReviewsSource implements AdminReviewsSource {
  MockAdminReviewsSource({
    this.latency = const Duration(milliseconds: 300),
    List<AdminReview>? reviews,
  }) : reviews = List.unmodifiable(reviews ?? adminReviewFixtures);
  final Duration latency;
  final List<AdminReview> reviews;
  bool failNext = false;
  @override
  Future<AdminReviewsResult> fetch(AdminReviewsQuery query) async {
    await Future<void>.delayed(latency);
    if (failNext) {
      failNext = false;
      throw StateError('Mock reviews unavailable');
    }
    final search = query.search.trim().toLowerCase();
    final matching = reviews
        .where(
          (review) =>
              (search.isEmpty ||
                  review.customerName.toLowerCase().contains(search) ||
                  review.productName.toLowerCase().contains(search)) &&
              (query.stars == null || review.rating == query.stars) &&
              switch (query.filter) {
                AdminReviewFilter.all => true,
                AdminReviewFilter.pending =>
                  review.status == AdminReviewStatus.pending,
                AdminReviewFilter.fiveStars => review.rating == 5,
                AdminReviewFilter.withImages => review.photos.isNotEmpty,
              },
        )
        .toList();
    final pages = (matching.length / AdminReviewsQuery.pageSize).ceil();
    final page = pages == 0 ? 1 : query.page.clamp(1, pages);
    return AdminReviewsResult(
      items: matching
          .skip((page - 1) * AdminReviewsQuery.pageSize)
          .take(AdminReviewsQuery.pageSize)
          .toList(),
      total: matching.length,
      page: page,
      pendingCount: reviews
          .where((r) => r.status == AdminReviewStatus.pending)
          .length,
    );
  }
}

final adminReviewFixtures = List<AdminReview>.unmodifiable([
  const AdminReview(
    id: 'REVIEW-P2-001',
    customerName: 'Nguyễn Thị Lan',
    productName: 'Khăn len Merino Thủ Công',
    rating: 5,
    comment: 'Sản phẩm rất đẹp, len mềm mịn, giao hàng nhanh hơn dự kiến. Màu kem bên ngoài nhìn sang lắm ạ. Shop đóng gói cẩn thận.',
    timeLabel: '2 giờ trước',
    status: AdminReviewStatus.pending,
    avatarAlias: 'imgUserAvatar',
    productAlias: 'imgProductThumbnail',
    photos: ['imgUserPhoto1', 'imgUserPhoto2'],
  ),
  const AdminReview(
    id: 'REVIEW-P2-002',
    customerName: 'Trần Văn Bảo',
    productName: 'Thú Bông Cừu Handmade',
    rating: 4,
    comment: 'Sản phẩm dễ thương, nhưng hơi nhỏ so với mình tưởng tượng. Shop nên ghi rõ kích thước hơn trong mô tả nhé.',
    timeLabel: '1 ngày trước',
    status: AdminReviewStatus.approved,
    productAlias: 'imgProductThumbnail1',
  ),
  const AdminReview(
    id: 'REVIEW-P2-003',
    customerName: 'Lê Minh Tú',
    productName: 'Mũ Len Be Phong Cách Hàn',
    rating: 5,
    comment:
        'Tuyệt vời! Mũ đội rất ấm, form đẹp y hình. Sẽ ủng hộ shop dài dài.',
    timeLabel: '3 giờ trước',
    status: AdminReviewStatus.pending,
    avatarAlias: 'imgUserAvatar1',
    productAlias: 'imgProductThumbnail2',
    photos: ['imgUserPhoto3'],
  ),
  // Explicit illustrative records, with no customer/order ownership claims.
  for (var i = 4; i <= 8; i++)
    AdminReview(
      id: 'DEMO-REVIEW-$i',
      customerName: 'Khách minh họa $i',
      productName: 'Sản phẩm minh họa $i',
      rating: (i % 5) + 1,
      comment: 'Đánh giá minh họa để kiểm tra tìm kiếm, lọc và phân trang.',
      timeLabel: 'Dữ liệu minh họa',
      status: AdminReviewStatus.approved,
    ),
]);
