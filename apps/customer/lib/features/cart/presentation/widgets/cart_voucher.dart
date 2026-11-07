import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';
import 'package:lenlab_customer/app/customer_scope.dart';
import 'package:lenlab_customer/app/navigation.dart';

import '../cart_styles.dart';

class CartVoucher extends StatelessWidget {
  const CartVoucher({super.key});
  @override
  Widget build(BuildContext context) {
    final store = CustomerScope.of(context);
    final quote = store.checkoutQuote;
    final newVoucher = store.hasUnquotedVoucherSelection;
    final discount = newVoucher
        ? (quote?.status == CheckoutQuoteStatus.ready
              ? quote!.itemsDiscountVnd! + quote.shippingDiscountVnd!
              : 0)
        : store.checkoutDiscount;
    return InkWell(
      onTap: () => go(context, '/vouchers'),
      borderRadius: BorderRadius.circular(32),
      child: CustomPaint(
        foregroundPainter: _VoucherBorder(),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF9B4B3E),
            borderRadius: BorderRadius.circular(32),
          ),
          child: Row(
            children: [
              cartAsset('imgMargin', 23.975, 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  newVoucher
                      ? (discount > 0
                            ? 'Ước tính giảm ${money(discount)}'
                            : 'Kiểm tra ưu đãi đã chọn')
                      : discount > 0
                      ? '${store.coupon} · Giảm ${money(discount)}'
                      : 'Chọn mã giảm giá',
                  style: const TextStyle(
                    fontSize: 14,
                    height: 20 / 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              cartAsset('imgContainer6', 16.667, 16.667),
            ],
          ),
        ),
      ),
    );
  }
}

class _VoucherBorder extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(1),
          const Radius.circular(32),
        ),
      );
    final paint = Paint()
      ..color = const Color(0x99E9A663)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (final metric in path.computeMetrics()) {
      for (double distance = 0; distance < metric.length; distance += 5) {
        canvas.drawPath(
          metric.extractPath(distance, math.min(distance + 2, metric.length)),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
