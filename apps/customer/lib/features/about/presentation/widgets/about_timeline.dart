import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

import '../../data/about_source.dart';

class AboutTimeline extends StatelessWidget {
  const AboutTimeline({super.key, required this.content});
  final AboutContent content;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 8),
    child: Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: P2.checkoutButton.withValues(alpha: .65),
            width: 2,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (index, item) in content.milestones.indexed)
            Padding(
              padding: EdgeInsets.only(
                bottom: index == content.milestones.length - 1 ? 0 : 32,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 26),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.year,
                          style: TextStyle(
                            fontSize: 14,
                            height: 20 / 14,
                            fontWeight: FontWeight.w700,
                            color: index == 0 ? P2.ink : P2.brown,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            fontWeight: FontWeight.w700,
                            color: P2.brown,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.description,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 20 / 14,
                            color: P2.brown,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: -9,
                    top: 4,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == 0
                            ? P2.checkoutButton
                            : const Color(0xFF4B5563),
                        boxShadow: const [
                          BoxShadow(color: Color(0xFF211911), spreadRadius: 4),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    ),
  );
}
