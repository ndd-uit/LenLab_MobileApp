import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

import '../order_review_styles.dart';
import 'order_review_section.dart';

class OrderReviewPaymentDetails extends StatelessWidget {
  const OrderReviewPaymentDetails({
    super.key,
    required this.totals,
    this.quote,
  });
  final OrderReviewTotals totals;
  final CheckoutQuote? quote;
  @override
  Widget build(BuildContext context) => OrderReviewSection(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chi tiết thanh toán',
          style: reviewSerif(16, weight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        _row('Tiền hàng', reviewMoney(totals.subtotal)),
        const SizedBox(height: 10),
        _row('Phí vận chuyển', reviewMoney(totals.shipping)),
        const SizedBox(height: 10),
        _row(
          'Giảm giá',
          '${totals.discount > 0 ? '-' : ''}${reviewMoney(totals.discount)}',
          discount: true,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: CustomPaint(
            size: const Size(double.infinity, 1),
            painter: _ReviewDivider(),
          ),
        ),
        _row('Tổng cộng', reviewMoney(totals.total), total: true),
      ],
    ),
  );
  Widget _row(
    String label,
    String amount, {
    bool discount = false,
    bool total = false,
  }) => LayoutBuilder(
    builder: (context, constraints) => Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            label,
            style: reviewSerif(
              total ? 16 : 14,
              weight: total ? FontWeight.w700 : FontWeight.w400,
              color: total ? P2.brown : Colors.black,
              height: total ? 1.5 : 20 / 14,
            ),
          ),
        ),
        const SizedBox(width: 8),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: constraints.maxWidth * .6),
          child: Text(
            amount,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: total ? 20 : 14,
              height: total ? 1.4 : 20 / 14,
              fontWeight: total ? FontWeight.w700 : FontWeight.w500,
              color: discount || total ? orderReviewRed : P2.brown,
            ),
          ),
        ),
      ],
    ),
  );
}

class _ReviewDivider extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = orderReviewBorder
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 5) {
      canvas.drawLine(
        Offset(x, .5),
        Offset(math.min(x + 3, size.width), .5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
