import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

import '../order_review_styles.dart';
import 'order_review_section.dart';

class OrderReviewAddress extends StatelessWidget {
  const OrderReviewAddress({
    super.key,
    required this.address,
    required this.onEdit,
  });
  final Address address;
  final VoidCallback onEdit;
  @override
  Widget build(BuildContext context) => OrderReviewSection(
    address: true,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Địa chỉ nhận hàng',
                style: reviewSerif(16, weight: FontWeight.w700),
              ),
            ),
            SizedBox(
              width: 44,
              height: 24,
              child: OverflowBox(
                maxHeight: 44,
                child: TextButton(
                  onPressed: onEdit,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    foregroundColor: P2.ink,
                  ),
                  child: const Text(
                    'Sửa',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              address.name,
              style: reviewSerif(
                14,
                weight: FontWeight.w700,
                color: Colors.black,
                height: 20 / 14,
              ),
            ),
            Container(width: 1, height: 12, color: orderReviewBorder),
            Text(
              address.phone,
              style: const TextStyle(
                fontSize: 14,
                height: 20 / 14,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          '${address.street}, ${address.ward},\n${address.district}, ${address.city}',
          style: reviewSerif(14, color: Colors.black, height: 22.75 / 14),
        ),
      ],
    ),
  );
}
