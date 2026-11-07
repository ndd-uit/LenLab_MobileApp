import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

import '../order_detail_styles.dart';

class OrderDetailProducts extends StatelessWidget {
  const OrderDetailProducts({super.key, required this.lines});
  final List<CartLine> lines;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          'Sản phẩm (${lines.fold(0, (total, line) => total + line.quantity)} món)',
          style: orderDetailType(
            18,
            weight: FontWeight.w700,
            color: P2.green,
            height: 1.25,
          ).copyWith(letterSpacing: -.45),
        ),
      ),
      const SizedBox(height: 12),
      if (lines.isEmpty) const EmptyPanel('Đơn hàng chưa có sản phẩm'),
      for (int i = 0; i < lines.length; i++) ...[
        if (i > 0) const SizedBox(height: 12),
        _Product(line: lines[i]),
      ],
    ],
  );
}

class _Product extends StatelessWidget {
  const _Product({required this.line});
  final CartLine line;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: orderDetailPanel(),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: P2Asset(
            line.product.image,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            label: line.product.name,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final nameStyle = orderDetailType(
                      16,
                      color: P2.ink,
                      weight: FontWeight.w600,
                    );
                    final priceStyle = orderDetailType(
                      16,
                      color: P2.ink,
                      weight: FontWeight.w700,
                    );
                    final price = money(line.product.price);
                    double width(String value, TextStyle style) => (TextPainter(
                      text: TextSpan(text: value, style: style),
                      textDirection: Directionality.of(context),
                      textScaler: MediaQuery.textScalerOf(context),
                    )..layout()).width;
                    final name = Text(line.product.name, style: nameStyle);
                    final amount = Text(price, style: priceStyle);
                    return width(line.product.name, nameStyle) +
                                width(price, priceStyle) +
                                8 <=
                            constraints.maxWidth
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: name),
                              const SizedBox(width: 8),
                              amount,
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [name, const SizedBox(height: 4), amount],
                          );
                  },
                ),
                if (line.variant.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    orderDetailVariant(line.variant),
                    style: orderDetailType(14, height: 20 / 14),
                  ),
                ],
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .05),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Số lượng: ${line.quantity}',
                    style: orderDetailType(
                      12,
                      weight: FontWeight.w500,
                      height: 16 / 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
