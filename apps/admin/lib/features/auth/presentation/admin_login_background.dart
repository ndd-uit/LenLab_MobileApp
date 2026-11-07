import 'dart:ui';

import 'package:flutter/material.dart';

class AdminLoginBackground extends StatelessWidget {
  const AdminLoginBackground({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    clipBehavior: Clip.hardEdge,
    children: [
      Positioned(
        left: -64,
        top: -70.59,
        child: IgnorePointer(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
            child: Container(
              width: 512,
              height: 282.39,
              decoration: BoxDecoration(
                color: const Color(0xFFD1A171).withValues(alpha: .05),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        right: -64,
        top: 141.19,
        child: IgnorePointer(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(
              width: 384,
              height: 211.8,
              decoration: BoxDecoration(
                color: const Color(0xFFE3E0DD).withValues(alpha: .4),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ),
      ),
      child,
    ],
  );
}
