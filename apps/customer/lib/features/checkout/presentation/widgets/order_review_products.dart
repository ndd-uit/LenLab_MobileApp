import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

import '../order_review_styles.dart';
import 'order_review_section.dart';

class OrderReviewProducts extends StatelessWidget {
  const OrderReviewProducts({super.key, required this.lines});
  final List<CartLine> lines;
  @override
  Widget build(BuildContext context) => OrderReviewSection(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Sản phẩm', style: reviewSerif(16, weight: FontWeight.w700)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: P2.checkoutButton.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                '${lines.fold(0, (n, l) => n + l.quantity)}',
                style: const TextStyle(
                  fontSize: 12,
                  height: 16 / 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        for (int i = 0; i < lines.length; i++) ...[
          if (i > 0)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1, thickness: 1, color: orderReviewBorder),
            ),
          OrderReviewProductLine(line: lines[i]),
        ],
      ],
    ),
  );
}

class OrderReviewProductLine extends StatelessWidget {
  const OrderReviewProductLine({super.key, required this.line});
  final CartLine line;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 80,
        height: 80,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: orderReviewBorder),
        ),
        padding: const EdgeInsets.all(1),
        child: P2Asset(line.product.image, label: line.product.name),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                line.product.name,
                style: reviewSerif(
                  14,
                  weight: FontWeight.w600,
                  height: 19.25 / 14,
                ),
              ),
              if (line.variant.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    reviewVariant(line.variant),
                    style: reviewSerif(
                      12,
                      color: orderReviewText,
                      height: 16 / 12,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      reviewMoney(line.product.price),
                      style: const TextStyle(
                        fontSize: 14,
                        height: 20 / 14,
                        color: P2.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'x${line.quantity}',
                    style: const TextStyle(
                      fontSize: 14,
                      height: 20 / 14,
                      color: orderReviewText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
