import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';
import 'package:lenlab_customer/app/navigation.dart';

import '../../../reviews/presentation/review_navigation.dart';

import '../order_detail_styles.dart';

class OrderDetailActions extends StatelessWidget {
  const OrderDetailActions({super.key, required this.order});
  final Order order;
  @override
  Widget build(BuildContext context) => Material(
    color: P2.rose,
    child: SafeArea(
      top: false,
      minimum: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _Action(
              label: 'Liên hệ hỗ trợ',
              onPressed: () => go(context, '/support', order.id),
            ),
          ),
          if (order.state == OrderState.delivered) ...[
            const SizedBox(width: 12),
            Expanded(
              child: _Action(
                label: 'Đánh giá',
                onPressed: () => openOrderReview(context, order.id),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

class _Action extends StatelessWidget {
  const _Action({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: P2.rose,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .25),
          offset: const Offset(0, 4),
          blurRadius: 4,
        ),
      ],
    ),
    child: TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: P2.rose,
        foregroundColor: P2.ink,
        minimumSize: const Size(44, 52),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        side: const BorderSide(color: Color(0xFFE8DDD0)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        textStyle: orderDetailType(
          14,
          weight: FontWeight.w600,
          height: 20 / 14,
        ),
      ),
      child: Text(label, textAlign: TextAlign.center),
    ),
  );
}
