import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';
import 'package:lenlab_customer/app/customer_scope.dart';

import '../cart_styles.dart';

class CartQuantity extends StatelessWidget {
  const CartQuantity({super.key, required this.line});
  final CartLine line;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: cartDark,
      borderRadius: BorderRadius.circular(99),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Giảm ${line.product.name}',
          onPressed: line.quantity > 1
              ? () => CustomerScope.of(context).changeQuantity(line, -1)
              : null,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 44, height: 44),
          icon: cartAsset(
            line.product.id == 'gloves' ? 'imgContainer5' : 'imgContainer3',
            9.333,
            1.333,
          ),
        ),
        Text(
          '${line.quantity}',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
            height: 20 / 14,
          ),
        ),
        IconButton(
          tooltip: 'Tăng ${line.product.name}',
          onPressed: line.quantity < line.product.stock
              ? () => CustomerScope.of(context).changeQuantity(line, 1)
              : null,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 44, height: 44),
          icon: Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: P2.checkoutButton,
              shape: BoxShape.circle,
            ),
            child: Center(child: cartAsset('imgContainer4', 9.333, 9.333)),
          ),
        ),
      ],
    ),
  );
}
