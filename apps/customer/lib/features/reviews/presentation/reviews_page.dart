import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';
import 'package:lenlab_customer/app/customer_scope.dart';
import 'package:lenlab_customer/shared/widgets/header_widgets.dart';

import 'review_styles.dart';
import 'widgets/review_summary.dart';
import 'widgets/review_card.dart';

class ReviewsPage extends StatefulWidget {
  const ReviewsPage({super.key, required this.productId, this.source});
  final String productId;
  final ReviewSource? source;
  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  ReviewSource? source;
  Future<ReviewCollection>? request;
  ReviewFilter filter = ReviewFilter.all;
  int? reviewsCount;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final store = CustomerScope.of(context);
    final count = store.productReviews.length;
    if (source == null || (widget.source == null && reviewsCount != count)) {
      reviewsCount = count;
      source =
          widget.source ??
          MockReviewSource(store.repository, reviews: store.productReviews);
      request = source!.load(widget.productId);
    }
  }

  @override
  void didUpdateWidget(covariant ReviewsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.productId != widget.productId ||
        oldWidget.source != widget.source) {
      source =
          widget.source ??
          MockReviewSource(
            CustomerScope.of(context).repository,
            reviews: CustomerScope.of(context).productReviews,
          );
      filter = ReviewFilter.all;
      request = source!.load(widget.productId);
    }
  }

  void retry() => setState(() {
    request = source!.load(widget.productId);
  });
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      toolbarHeight: 72,
      automaticallyImplyLeading: false,
      leadingWidth: 64,
      leading: const Padding(
        padding: EdgeInsets.only(left: 14, right: 6),
        child: HeaderBackButton(),
      ),
      title: const Text(
        'Đánh giá & Nhận xét',
        textAlign: TextAlign.center,
        maxLines: 2,
      ),
      actions: const [SizedBox(width: 64)],
    ),
    bottomNavigationBar: Container(
      color: P2.rose,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: ElevatedButton(
            onPressed: () => reviewNotice(
              context,
              'Để viết đánh giá, hãy mở Đơn hàng của tôi và chọn đơn Đã giao. Có thể đính kèm tối đa 5 ảnh JPG/PNG, mỗi ảnh tối đa 5 MB.',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: P2.productDetailButton,
              foregroundColor: reviewText,
              minimumSize: const Size.fromHeight(56),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              shape: const StadiumBorder(),
              elevation: 4,
              shadowColor: P2.productDetailButton.withValues(alpha: .25),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                reviewAsset('imgContainer2', 16.667, 16.688),
                const SizedBox(width: 8),
                const Flexible(
                  child: Text(
                    'Viết đánh giá của bạn',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    body: SafeArea(
      top: false,
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: FutureBuilder<ReviewCollection>(
          future: request,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: CircularProgressIndicator(
                    semanticsLabel: 'Đang tải nhận xét',
                  ),
                ),
              );
            }
            if (snapshot.hasError) {
              return EmptyPanel(
                'Không thể tải nhận xét',
                action: P2Button('Thử lại', onPressed: retry),
              );
            }
            final collection = snapshot.data!;
            final items = collection.filtered(filter);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ReviewSummary(collection: collection),
                const SizedBox(height: 24),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final tab in [
                        (ReviewFilter.all, 'Tất cả'),
                        (ReviewFilter.newest, 'Mới nhất'),
                        (
                          ReviewFilter.withImages,
                          'Có hình ảnh (${collection.imageCount})',
                        ),
                        (
                          ReviewFilter.fiveStars,
                          '5 Sao (${collection.count(5)})',
                        ),
                      ])
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Semantics(
                            button: true,
                            selected: filter == tab.$1,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(24),
                              onTap: () => setState(() {
                                filter = tab.$1;
                              }),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 9,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    color: filter == tab.$1
                                        ? P2.rose
                                        : tab.$1 == ReviewFilter.fiveStars
                                        ? const Color(0xFF221910)
                                        : P2.categoryButton,
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 2,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    tab.$2,
                                    style: TextStyle(
                                      fontSize: 14,
                                      height: 20 / 14,
                                      fontWeight: filter == tab.$1
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: filter == tab.$1
                                          ? reviewText
                                          : const Color(0xFFD1D5DB),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (items.isEmpty)
                  EmptyPanel(
                    collection.reviews.isEmpty
                        ? 'Chưa có đánh giá cho sản phẩm này'
                        : 'Không có nhận xét phù hợp',
                    action: collection.reviews.isEmpty
                        ? null
                        : P2Button(
                            'Xem tất cả',
                            onPressed: () => setState(() {
                              filter = ReviewFilter.all;
                            }),
                          ),
                  ),
                for (final (index, item) in items.indexed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ReviewCard(
                      key: ValueKey(item.id),
                      review: item,
                      last: index == items.length - 1,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    ),
  );
}
