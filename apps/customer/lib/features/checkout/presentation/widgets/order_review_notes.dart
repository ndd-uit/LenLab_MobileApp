import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

import '../order_review_styles.dart';
import 'order_review_section.dart';

class OrderReviewNotes extends StatelessWidget {
  const OrderReviewNotes({
    super.key,
    required this.controller,
    required this.onChanged,
  });
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) => OrderReviewSection(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ghi chú đơn hàng',
          style: reviewSerif(16, weight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .05),
            border: Border.all(color: orderReviewBorder.withValues(alpha: .5)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              P2Asset.node(orderReviewNode, 'imgIcon', width: 20, height: 19),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  key: const ValueKey('order-note'),
                  controller: controller,
                  onChanged: onChanged,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  minLines: 3,
                  maxLines: 6,
                  style: reviewSerif(
                    14,
                    color: const Color(0xFF585353),
                    height: 22.75 / 14,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: 'Nếu bạn muốn gói quà để tặng hoặc không hiển thị giá, hãy để lại ghi chú với chúng tôi',
                    hintStyle: reviewSerif(
                      14,
                      color: const Color(0xFF585353),
                      height: 22.75 / 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
