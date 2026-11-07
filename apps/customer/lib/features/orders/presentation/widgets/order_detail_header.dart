import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';
import 'package:lenlab_customer/shared/widgets/header_widgets.dart';

import '../order_detail_styles.dart';

class OrderDetailHeader extends StatelessWidget implements PreferredSizeWidget {
  const OrderDetailHeader({super.key, this.height = 64});
  final double height;
  @override
  Size get preferredSize => Size.fromHeight(height);
  @override
  Widget build(BuildContext context) => Material(
    color: P2.rose,
    child: SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
        child: Row(
          children: [
            const HeaderBackButton(),
            Expanded(
              child: Text(
                'Chi tiết đơn hàng',
                textAlign: TextAlign.center,
                style: orderDetailType(
                  18,
                  weight: FontWeight.w700,
                  color: P2.ink,
                  height: 1.25,
                ).copyWith(letterSpacing: -.27),
              ),
            ),
            const SizedBox(width: 44),
          ],
        ),
      ),
    ),
  );
}
