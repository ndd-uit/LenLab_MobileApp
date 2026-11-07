import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

class CodOrderReceipt extends StatelessWidget {
  const CodOrderReceipt({super.key, required this.order});
  final Order order;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: P2.rose,
      border: Border.all(color: const Color(0xFF1F2937)),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Column(
      children: [
        _ReceiptRow('Mã đơn hàng', '#${order.id}', first: true, code: true),
        _ReceiptRow(
          'Giao hàng dự kiến',
          order.deliveryEstimate ?? 'Chờ shop xác nhận',
          asset: 'imgContainer',
        ),
        _ReceiptRow(
          'Phương thức',
          'Thanh toán khi nhận hàng',
          asset: 'imgContainer1',
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  'Tổng thanh toán',
                  style: P2
                      .serif(14, color: P2.ink, weight: FontWeight.w700)
                      .copyWith(height: 20 / 14),
                ),
              ),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(context).width * .5,
                ),
                child: Text(
                  money(order.total).replaceAll('đ', '₫'),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 20,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF523A30),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: P2.cream.withValues(alpha: .9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: P2.brown, width: 2),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              P2Asset.node(
                '2026:1691',
                'imgMargin',
                width: 12.023,
                height: 14.007,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ĐÓNG GÓI XANH',
                      style: P2
                          .serif(12, color: P2.ink, weight: FontWeight.w700)
                          .copyWith(height: 16 / 12, letterSpacing: .3),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Đơn hàng này không sử dụng nilon. Chúng tôi sử dụng giấy tái chế thân thiện với môi trường.',
                      style: P2.serif(12).copyWith(height: 16 / 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow(
    this.label,
    this.value, {
    this.asset,
    this.first = false,
    this.code = false,
  });
  final String label, value;
  final String? asset;
  final bool first, code;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: EdgeInsets.only(top: first ? 0 : 16, bottom: 16),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  if (asset != null) ...[
                    P2Asset.node(
                      '2026:1691',
                      asset!,
                      width: asset == 'imgContainer' ? 12.852 : 11.648,
                      height: 9.352,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      style: P2
                          .serif(14, color: P2.ink)
                          .copyWith(height: 20 / 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: (MediaQuery.sizeOf(context).width - 82) * .6,
              ),
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: code
                      ? 'packages/lenlab_shared/Cousine'
                      : 'packages/lenlab_shared/BeVietnamPro',
                  fontSize: code ? 16 : 14,
                  height: code ? 1.5 : 20 / 14,
                  fontWeight: code ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: code ? .4 : null,
                  color: code ? Colors.black : const Color(0xFF523A30),
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(
        height: 1,
        width: double.infinity,
        child: CustomPaint(painter: _ReceiptDash()),
      ),
    ],
  );
}

class _ReceiptDash extends CustomPainter {
  const _ReceiptDash();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1F2937)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 4) {
      canvas.drawLine(
        Offset(x, .5),
        Offset(math.min(x + 2, size.width), .5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
