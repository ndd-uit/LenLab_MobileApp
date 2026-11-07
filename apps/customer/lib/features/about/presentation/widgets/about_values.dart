import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

class AboutValues extends StatelessWidget {
  const AboutValues({super.key});
  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, value) in [
          (
            label: 'Thủ công\n100%',
            asset: 'imgContainer1',
            width: 21.0,
            height: 20.5,
          ),
          (
            label: 'Nguyên liệu\nBền vững',
            asset: 'imgContainer2',
            width: 16.995,
            height: 16.992,
          ),
          (
            label: 'Len\nCao cấp',
            asset: 'imgContainer3',
            width: 23.0,
            height: 19.0,
          ),
        ].indexed) ...[
          if (index > 0) const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(0xFFE8DDD0),
                borderRadius: BorderRadius.circular(32),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 4),
                    blurRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: P2.checkoutButton.withValues(alpha: .2),
                    ),
                    child: Center(
                      child: P2Asset.node(
                        '2026:3774',
                        value.asset,
                        width: value.width,
                        height: value.height,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.25,
                      fontWeight: FontWeight.w700,
                      color: P2.brown,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

class AboutPurposeCard extends StatelessWidget {
  const AboutPurposeCard({
    super.key,
    required this.title,
    required this.text,
    required this.vision,
  });
  final String title, text;
  final bool vision;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xFFE8DDD0),
      borderRadius: BorderRadius.circular(32),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        P2Asset.node(
          '2026:3774',
          vision ? 'imgMargin' : 'imgMargin1',
          width: vision ? 22 : 15,
          height: vision ? 19 : 21,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  height: 28 / 18,
                  fontWeight: FontWeight.w700,
                  color: P2.brown,
                ),
              ),
              const SizedBox(height: 3.25),
              Text(
                text,
                textAlign: TextAlign.justify,
                style: const TextStyle(
                  fontSize: 14,
                  height: 22.75 / 14,
                  color: P2.brown,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
