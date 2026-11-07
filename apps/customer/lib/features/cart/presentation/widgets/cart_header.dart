import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';
import 'package:lenlab_customer/shared/widgets/header_widgets.dart';

import '../cart_styles.dart';

class CartHeader extends StatelessWidget implements PreferredSizeWidget {
  const CartHeader({super.key});
  @override
  Size get preferredSize => const Size.fromHeight(72);
  @override
  Widget build(BuildContext context) => Material(
    color: P2.rose,
    child: SafeArea(
      bottom: false,
      child: SizedBox(
        height: 72,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 8),
          child: Row(
            children: [
              const HeaderBackButton(),
              const Expanded(
                child: Text(
                  'Giỏ hàng',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    height: 28 / 18,
                    letterSpacing: -.5,
                    fontWeight: FontWeight.w700,
                    color: P2.ink,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Tùy chọn giỏ hàng',
                onPressed: () => missingSpec(context, 'Tùy chọn giỏ hàng'),
                icon: Transform.rotate(
                  angle: 89.41 * math.pi / 180,
                  child: cartAsset('imgContainer1', 4, 16),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
