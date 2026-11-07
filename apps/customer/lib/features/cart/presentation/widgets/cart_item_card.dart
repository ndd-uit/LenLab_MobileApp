import 'package:lenlab_customer/shared/widgets/selection_mark.dart';
import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';
import 'package:lenlab_customer/app/customer_scope.dart';
import 'package:lenlab_customer/app/navigation.dart';

import '../cart_styles.dart';
import 'cart_quantity.dart';

class CartItemCard extends StatelessWidget {
  const CartItemCard({super.key, required this.line});
  final CartLine line;
  @override
  Widget build(BuildContext context) {
    final store = CustomerScope.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: P2.rose,
        border: Border.all(color: P2.brown, width: 2),
        borderRadius: BorderRadius.circular(40),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            offset: Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Semantics(
            checked: store.isCartLineSelected(line),
            child: SizedBox(
              width: 22,
              height: 44,
              child: OverflowBox(
                maxWidth: 44,
                minWidth: 44,
                child: IconButton(
                  key: ValueKey('cart-select-${line.key}'),
                  tooltip: 'Lựa chọn ${line.product.name}',
                  onPressed: store.isSubmittingCod
                      ? null
                      : () => store.toggleCartLine(line),
                  padding: EdgeInsets.zero,
                  icon: CustomerSelectionMark(
                    selected: store.isCartLineSelected(line),
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 11),
          SizedBox(
            width: 66,
            height: 88,
            child: InkWell(
              onTap: () => go(context, '/product', line.product),
              child: P2Asset(
                line.product.image,
                radius: 32,
                label: line.product.name,
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            line.product.name,
                            style: P2
                                .serif(
                                  14,
                                  color: line.product.id == 'gloves'
                                      ? const Color(0xFF7A2929)
                                      : P2.ink,
                                  weight: FontWeight.w700,
                                )
                                .copyWith(height: 1.25, letterSpacing: 0),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            line.variant.replaceAll(' · ', ' - '),
                            style: P2
                                .serif(12, color: const Color(0xFF523A30))
                                .copyWith(height: 16 / 12, letterSpacing: 0),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 24,
                      height: 32,
                      child: OverflowBox(
                        maxWidth: 44,
                        maxHeight: 44,
                        child: IconButton(
                          tooltip: 'Xóa ${line.product.name}',
                          onPressed: () {
                            store.removeFromCart(line);
                            toast(context, 'Đã xóa sản phẩm khỏi giỏ hàng.');
                          },
                          icon: cartAsset('imgContainer2', 13.333, 15),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LayoutBuilder(
                  builder: (context, constraints) {
                    const style = TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      fontWeight: FontWeight.w700,
                      color: P2.ink,
                      letterSpacing: 0,
                    );
                    final price = Text(money(line.product.price), style: style);
                    final painter = TextPainter(
                      text: TextSpan(
                        text: money(line.product.price),
                        style: DefaultTextStyle.of(context).style.merge(style),
                      ),
                      textDirection: Directionality.of(context),
                      textScaler: MediaQuery.textScalerOf(context),
                    )..layout();
                    final fits = painter.width + 100 <= constraints.maxWidth;
                    painter.dispose();
                    final quantity = CartQuantity(line: line);
                    return fits
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [price, quantity],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              price,
                              const SizedBox(height: 8),
                              quantity,
                            ],
                          );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
