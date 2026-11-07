import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';
import 'package:lenlab_customer/shared/widgets/header_widgets.dart';

import '../order_list_styles.dart';

class OrderListHeader extends StatelessWidget implements PreferredSizeWidget {
  const OrderListHeader({super.key, this.height = 65});
  final double height;
  @override
  Size get preferredSize => Size.fromHeight(height);
  @override
  Widget build(BuildContext context) => Material(
    color: P2.rose,
    child: SafeArea(
      bottom: false,
      child: SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              const HeaderBackButton(),
              Expanded(
                child: Text(
                  'Đơn hàng của tôi',
                  textAlign: TextAlign.center,
                  style: orderListType(
                    18,
                    color: P2.ink,
                    weight: FontWeight.w700,
                    height: 28 / 18,
                  ).copyWith(letterSpacing: -.45),
                ),
              ),
              const SizedBox(width: 44),
            ],
          ),
        ),
      ),
    ),
  );
}
