import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

import '../../../../shared/widgets/admin_list_styles.dart';
import '../../data/admin_reviews_source.dart';

Widget reviewAsset(String alias, double width, double height) =>
    P2Asset.node('2026:5597', alias, width: width, height: height);
const reviewAccent = Color(0xFFF2994A);

class ReviewCard extends StatelessWidget {
  const ReviewCard({super.key, required this.review});
  final AdminReview review;

  @override
  Widget build(BuildContext context) {
    final pending = review.status == AdminReviewStatus.pending;
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: pending ? const Color(0xFFFEF9C3) : const Color(0xFFDCFCE7),
        border: Border.all(
          color: pending ? const Color(0xFFFEF08A) : const Color(0xFFBBF7D0),
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        review.status.label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: pending ? const Color(0xFF854D0E) : const Color(0xFF15803D),
        ),
      ),
    );
    final identity = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipOval(
          child: review.avatarAlias != null
              ? reviewAsset(review.avatarAlias!, 40, 40)
              : Container(
                  width: 40,
                  height: 40,
                  color: const Color(0xFFF3E8FF),
                  alignment: Alignment.center,
                  child: Text(
                    review.customerName == 'Trần Văn Bảo' ? 'TB' : 'MH',
                    style: const TextStyle(
                      color: Color(0xFF9333EA),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                review.customerName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: adminListInk,
                ),
              ),
              Text(
                review.timeLabel,
                style: const TextStyle(fontSize: 12, color: adminListMuted),
              ),
            ],
          ),
        ),
      ],
    );
    return Container(
      key: ValueKey('review-${review.id}'),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: adminListBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            offset: Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, c) => c.maxWidth >= 400
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: identity),
                      const SizedBox(width: 12),
                      badge,
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [identity, const SizedBox(height: 12), badge],
                  ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: review.productAlias != null
                      ? reviewAsset(review.productAlias!, 40, 40)
                      : const SizedBox(
                          width: 40,
                          height: 40,
                          child: Icon(
                            Icons.inventory_2_outlined,
                            color: adminListMuted,
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SẢN PHẨM',
                        style: TextStyle(
                          fontSize: 12,
                          color: adminListMuted,
                          letterSpacing: .3,
                        ),
                      ),
                      Text(
                        review.productName,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B3510),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Semantics(
            label: '${review.rating} trên 5 sao',
            child: ExcludeSemantics(
              child: Row(
                children: [
                  for (var i = 0; i < 5; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: reviewAsset(
                        i < review.rating ? 'imgContainer10' : 'imgContainer13',
                        15,
                        14.25,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            review.comment,
            style: const TextStyle(
              fontSize: 14,
              height: 22.75 / 14,
              color: Color(0xFF374151),
            ),
          ),
          if (review.photos.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final photo in review.photos)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: reviewAsset(photo, 64, 64),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          const SizedBox(height: 16),
          Row(
            children: [
              if (pending) ...[
                Expanded(
                  child: _action(
                    'Duyệt',
                    'imgContainer11',
                    const Color(0xFFF0FDF4),
                    const Color(0xFF15803D),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: _action(
                  pending ? 'Ẩn' : 'Ẩn đánh giá này',
                  pending ? 'imgContainer12' : 'imgContainer14',
                  const Color(0xFFF9FAFB),
                  pending ? const Color(0xFF4B5563) : const Color(0xFFDC2626),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _action(
    String label,
    String icon,
    Color background,
    Color foreground,
  ) => Tooltip(
    message: '$label chưa triển khai trong bản chỉ đọc',
    child: TextButton.icon(
      onPressed: null,
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 36),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        disabledBackgroundColor: background,
        disabledForegroundColor: foreground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: reviewAsset(icon, icon == 'imgContainer11' ? 13.333 : 14.667, 13.2),
      label: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14),
      ),
    ),
  );
}
