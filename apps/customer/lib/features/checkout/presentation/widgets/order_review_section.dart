import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

import '../order_review_styles.dart';

class OrderReviewSection extends StatelessWidget {
  const OrderReviewSection({
    super.key,
    required this.child,
    this.address = false,
  });
  final Widget child;
  final bool address;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(address ? 18 : 17),
    decoration: BoxDecoration(
      color: P2.rose.withValues(alpha: .85),
      border: Border.all(
        color: address ? P2.brown : orderReviewBorder,
        width: address ? 2 : 1,
      ),
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0D000000),
          offset: Offset(0, 1),
          blurRadius: 2,
        ),
      ],
    ),
    child: child,
  );
}
