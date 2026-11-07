import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

import '../review_styles.dart';

class ReviewCard extends StatelessWidget {
  const ReviewCard({super.key, required this.review, this.last = false});
  final ProductReview review;
  final bool last;
  @override
  Widget build(BuildContext context) {
    final gradient = switch (review.initials) {
      'MA' => const [Color(0xFF60A5FA), Color(0xFFA855F7)],
      'HP' => const [Color(0xFFFB923C), Color(0xFFEC4899)],
      _ => const [Color(0xFF4ADE80), Color(0xFF14B8A6)],
    };
    return Container(
      padding: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: last
            ? null
            : Border(
                bottom: BorderSide(color: reviewRed.withValues(alpha: .2)),
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (review.avatar != null)
                ClipOval(
                  child: P2Asset.node(
                    review.assetNode,
                    review.avatar!,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradient,
                    ),
                  ),
                  child: Text(
                    review.initials,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Color(0xFF1C1510),
                    ),
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.name,
                      style: P2
                          .serif(14, color: reviewRed, weight: FontWeight.w700)
                          .copyWith(height: 20 / 14),
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Semantics(
                          label: '${review.rating} sao',
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (final star in review.starAssets)
                                Padding(
                                  padding: const EdgeInsets.only(right: 2),
                                  child: P2Asset.node(
                                    review.assetNode,
                                    star,
                                    width: 11.667,
                                    height: 11.083,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: Color(0xFFB9AB9D),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Text(
                          review.dateLabel,
                          style: const TextStyle(
                            fontSize: 12,
                            height: 16 / 12,
                            color: reviewText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.text,
            style: P2.serif(14, color: reviewRed).copyWith(height: 22.75 / 14),
          ),
          if (review.hasImages) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final photo in review.localPhotos)
                  ClipOval(
                    child: Image.memory(
                      photo.bytes,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      cacheWidth: 240,
                      semanticLabel: 'Ảnh đánh giá của ${review.name}',
                      errorBuilder: (_, error, stack) => const SizedBox(
                        width: 80,
                        height: 80,
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: P2.brown,
                        ),
                      ),
                    ),
                  ),
                for (final photo in review.photos)
                  ClipOval(
                    child: P2Asset.node(
                      review.assetNode,
                      photo,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              InkWell(
                onTap: () => reviewNotice(
                  context,
                  'Chưa gửi lượt hữu ích trong bản dùng thử.',
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 44),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      reviewAsset('imgContainer3', 14, 13.333),
                      const SizedBox(width: 6),
                      Text(
                        review.helpful == null
                            ? 'Hữu ích'
                            : 'Hữu ích (${review.helpful})',
                        style: const TextStyle(
                          fontSize: 12,
                          height: 16 / 12,
                          fontWeight: FontWeight.w500,
                          color: reviewText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (review.purchased) ...[
                const Text(
                  '|',
                  style: TextStyle(fontSize: 12, color: reviewText),
                ),
                Text(
                  'Đã mua hàng',
                  style: P2
                      .serif(12, color: P2.green)
                      .copyWith(height: 16 / 12),
                ),
              ],
              if (review.variant != null) ...[
                const Text(
                  '|',
                  style: TextStyle(fontSize: 12, color: reviewText),
                ),
                Text(
                  'Phân loại: ${review.variant}',
                  style: P2
                      .serif(12, color: reviewText)
                      .copyWith(height: 16 / 12),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
