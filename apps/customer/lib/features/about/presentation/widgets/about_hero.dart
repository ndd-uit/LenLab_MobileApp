import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

class AboutHero extends StatelessWidget {
  const AboutHero({super.key});
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(32),
    child: Stack(
      children: [
        Positioned.fill(
          child: P2Asset.node(
            '2026:3774',
            'imgBackgroundShadow',
            fit: BoxFit.cover,
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: .5),
                  Colors.transparent,
                ],
                stops: const [0, .4],
              ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 152, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SINCE 2021',
                style: TextStyle(
                  fontSize: 12,
                  height: 16 / 12,
                  letterSpacing: .6,
                  fontWeight: FontWeight.w700,
                  color: P2.checkoutButton,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Gửi ấm áp trong\ntừng mũi len',
                style: TextStyle(
                  fontSize: 32,
                  height: 1.25,
                  letterSpacing: -.8,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
