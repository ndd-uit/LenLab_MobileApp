import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

import '../review_styles.dart';

class ReviewSummary extends StatelessWidget {
  const ReviewSummary({super.key, required this.collection});
  final ReviewCollection collection;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: P2.rose,
      border: Border.all(color: reviewRed.withValues(alpha: .9), width: 2),
      borderRadius: BorderRadius.circular(24),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 12)),
      ],
    ),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final score = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              collection.reviews.isEmpty
                  ? '—'
                  : collection.average.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 48,
                height: 1,
                letterSpacing: -2.4,
                fontWeight: FontWeight.w700,
                color: reviewText,
              ),
            ),
            const SizedBox(height: 4),
            if (collection.reviews.isNotEmpty)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var index = 0; index < 5; index++)
                    Padding(
                      padding: const EdgeInsets.only(right: 2),
                      child: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          collection.average - index >= .5
                              ? Colors.transparent
                              : const Color(0xFFB9AB9D),
                          collection.average - index >= .5
                              ? BlendMode.dst
                              : BlendMode.srcIn,
                        ),
                        child: reviewAsset(
                          collection.average - index >= .5 &&
                                  collection.average - index < 1
                              ? 'imgIcon3'
                              : 'imgIcon',
                          13.333,
                          12.667,
                        ),
                      ),
                    ),
                ],
              ),
            const SizedBox(height: 8),
            Text(
              '${collection.reviews.length} đánh giá',
              style: P2
                  .serif(12, color: const Color(0xFF7A2929))
                  .copyWith(height: 16 / 12),
            ),
          ],
        );
        final bars = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var stars = 5; stars >= 1; stars--)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      child: Text(
                        '$stars',
                        style: const TextStyle(
                          fontSize: 12,
                          height: 16 / 12,
                          color: Color(0xFF7A2929),
                        ),
                      ),
                    ),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: collection.reviews.isEmpty
                            ? 0
                            : collection.count(stars) /
                                  collection.reviews.length,
                        minHeight: 6,
                        color: P2.productDetailButton,
                        backgroundColor: Colors.white.withValues(alpha: .9),
                        borderRadius: BorderRadius.circular(99),
                        semanticsLabel:
                            '$stars sao: ${collection.count(stars)} đánh giá',
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
        if (constraints.maxWidth < 250 ||
            MediaQuery.textScalerOf(context).scale(14) > 16) {
          return Column(children: [score, const SizedBox(height: 16), bars]);
        }
        return Row(
          children: [
            SizedBox(width: 100, child: score),
            Container(
              width: 1,
              height: 96,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              color: Colors.white.withValues(alpha: .9),
            ),
            Expanded(child: bars),
          ],
        );
      },
    ),
  );
}
