import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

class ReviewProductSummary extends StatelessWidget {
  const ReviewProductSummary({
    super.key,
    required this.order,
    required this.product,
  });
  final Order order;
  final Product product;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: P2.rose,
      borderRadius: BorderRadius.circular(24),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        P2Asset(
          product.image,
          width: 72,
          height: 72,
          radius: 16,
          label: product.name,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: P2.ink,
                ),
              ),
              for (final variant
                  in order.lines
                      .where((l) => l.product.id == product.id)
                      .map((l) => l.variant)
                      .where((v) => v.isNotEmpty)
                      .toSet())
                Text(variant),
            ],
          ),
        ),
      ],
    ),
  );
}
