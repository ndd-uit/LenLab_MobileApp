import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

class CartSummary extends StatelessWidget {
  const CartSummary({
    super.key,
    required this.subtotal,
    required this.discount,
    this.quote,
    this.useQuote = false,
  });
  final int subtotal, discount;
  final CheckoutQuote? quote;
  final bool useQuote;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      const Divider(color: Color(0x0DFFFFFF), height: 1),
      const SizedBox(height: 16),
      _row(
        'Tiền hàng',
        useQuote && quote == null ? 'Đang tính…' : money(subtotal),
      ),
      const SizedBox(height: 12),
      _row(
        'Tiền giảm giá',
        useQuote && quote?.itemsDiscountVnd == null
            ? 'Chưa xác định'
            : '${discount > 0 ? '-' : ''}${money(discount)}',
      ),
      const SizedBox(height: 20),
      _row(
        'Tạm tính',
        useQuote
            ? (quote?.status == CheckoutQuoteStatus.ready
                  ? money(quote!.itemsPayableVnd!)
                  : 'Chưa đủ thông tin')
            : money(subtotal - discount),
        total: true,
      ),
    ],
  );
  Widget _row(String label, String value, {bool total = false}) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Expanded(
        child: Text(
          label,
          style: P2
              .serif(total ? 16 : 14, color: P2.brown)
              .copyWith(height: 1.5, letterSpacing: 0),
        ),
      ),
      const SizedBox(width: 8),
      Flexible(
        child: Text(
          value,
          textAlign: TextAlign.right,
          style: total
              ? const TextStyle(
                  fontSize: 24,
                  height: 32 / 24,
                  fontWeight: FontWeight.w700,
                  color: P2.ink,
                  letterSpacing: 0,
                )
              : P2
                    .serif(14, color: const Color(0xFF0F0F0F))
                    .copyWith(height: 20 / 14, letterSpacing: 0),
        ),
      ),
    ],
  );
}
