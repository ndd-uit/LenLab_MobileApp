import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

import '../home_styles.dart';

class HomeCampaign extends StatelessWidget {
  const HomeCampaign({super.key});
  @override
  Widget build(BuildContext context) => Container(
    key: const ValueKey('home-campaign'),
    constraints: const BoxConstraints(minHeight: 159),
    padding: const EdgeInsets.fromLTRB(24, 18.568, 15.068, 18.568),
    decoration: BoxDecoration(
      color: P2.rose.withValues(alpha: .55),
      border: Border.all(color: P2.rose, width: 2),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: P2.cream,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'CAMPAIGN',
                  style: P2
                      .serif(
                        10,
                        color: const Color(0xFF231E0F),
                        weight: FontWeight.w700,
                      )
                      .copyWith(height: 1.5, letterSpacing: .5),
                ),
              ),
              const SizedBox(height: 8),
              const Text.rich(
                TextSpan(
                  style: TextStyle(
                    fontFamily: homeFont,
                    fontSize: 24,
                    height: 1,
                    fontWeight: FontWeight.w700,
                    color: P2.brown,
                  ),
                  children: [
                    TextSpan(text: 'MÙA ĐÔNG\n'),
                    TextSpan(
                      text: 'ẤM ÁP',
                      style: TextStyle(color: P2.ink),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Giảm 15% cho đơn hàng đầu tiên.',
                style: P2.serif(12, color: P2.ink).copyWith(height: 16 / 12),
              ),
            ],
          ),
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 113.864,
          height: 113.864,
          child: Center(
            child: Transform.rotate(
              angle: math.pi / 15,
              child: Container(
                width: 96,
                height: 96,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .2),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      offset: Offset(0, 10),
                      blurRadius: 15,
                      spreadRadius: -3,
                    ),
                  ],
                ),
                child: const P2Asset('e6d76.png', radius: 20),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
