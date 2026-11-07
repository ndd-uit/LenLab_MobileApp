import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';
import 'package:lenlab_customer/app/navigation.dart';

import 'package:lenlab_customer/shared/widgets/header_widgets.dart';

class BankTransferHeader extends StatelessWidget
    implements PreferredSizeWidget {
  const BankTransferHeader({super.key, this.height = 64});
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
            HeaderBackButton(onFallback: () => go(context, '/payment-method')),
            Expanded(
              child: Text(
                'Chuyển khoản ngân hàng',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.25,
                  letterSpacing: -.27,
                  fontWeight: FontWeight.w700,
                  color: P2.ink,
                ),
              ),
            ),
            const SizedBox(width: 44),
          ],
        ),
      ),
    ),
  );
}
