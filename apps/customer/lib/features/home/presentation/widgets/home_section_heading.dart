import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';
import 'package:lenlab_customer/app/navigation.dart';

import '../home_styles.dart';

class HomeSectionHeading extends StatelessWidget {
  const HomeSectionHeading(this.title, {super.key, required this.route});
  final String title, route;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Text(
          title,
          style: P2
              .serif(20, color: P2.green, weight: FontWeight.w700)
              .copyWith(height: 1.6, letterSpacing: -.6),
        ),
      ),
      TextButton(
        onPressed: () => go(context, route),
        style: TextButton.styleFrom(
          minimumSize: const Size(44, 44),
          padding: const EdgeInsets.fromLTRB(8, 6, 0, 18),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Xem tất cả',
              style: TextStyle(
                fontFamily: homeFont,
                fontSize: 14,
                height: 20 / 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF523A30),
              ),
            ),
            const SizedBox(width: 4),
            P2Asset.node('2026:664', 'imgContainer9', width: 4.933, height: 8),
          ],
        ),
      ),
    ],
  );
}
