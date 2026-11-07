import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';
import 'package:lenlab_customer/app/navigation.dart';
import 'package:lenlab_customer/app/customer_scope.dart';

import '../detail_styles.dart';

class DetailReviews extends StatelessWidget {
  const DetailReviews({super.key, required this.product});
  final Product product;
  @override
  Widget build(BuildContext context) {
    final collection = CustomerScope.of(context).reviewsFor(product.id);
    return Column(
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Đánh giá & Nhận xét',
                style: TextStyle(
                  fontSize: 18,
                  height: 28 / 18,
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton(
              onPressed: () => go(context, '/reviews', product.id),
              child: const Text(
                'Xem tất cả',
                style: TextStyle(fontSize: 14, color: detailText),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE8DDD0),
            border: Border.all(color: const Color(0xFF9B4B3E), width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (collection.reviews.isEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('0 nhận xét'),
                    const Text('Chưa có đánh giá cho sản phẩm này.'),
                  ],
                );
              }
              final summary = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    collection.average.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 36,
                      height: 1.25,
                      fontWeight: FontWeight.w700,
                      color: detailText,
                    ),
                  ),
                  const SizedBox(height: 4),
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
                            child: detailAsset(
                              collection.average - index >= .5 &&
                                      collection.average - index < 1
                                  ? 'imgIcon3'
                                  : 'imgIcon',
                              15,
                              14.25,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${collection.reviews.length} nhận xét',
                    style: const TextStyle(fontSize: 14, color: detailText),
                  ),
                ],
              );
              final bars = Column(
                children: [
                  for (var stars = 5; stars >= 1; stars--)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Text('$stars', style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: LinearProgressIndicator(
                              value:
                                  collection.count(stars) /
                                  collection.reviews.length,
                              color: detailOrange,
                              backgroundColor: const Color(0xCCFFFFFF),
                              minHeight: 6,
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
              if (constraints.maxWidth < 280 ||
                  MediaQuery.textScalerOf(context).scale(14) > 14) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [summary, const SizedBox(height: 24), bars],
                );
              }
              return Row(
                children: [
                  summary,
                  const SizedBox(width: 32),
                  Expanded(child: bars),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
