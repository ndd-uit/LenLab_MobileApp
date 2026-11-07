import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';
import 'package:lenlab_customer/app/navigation.dart';

import '../home_styles.dart';
import '../../data/home_content.dart';

class HomeCategories extends StatelessWidget {
  const HomeCategories({super.key});
  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(12) / 12;
    const labelStyle = TextStyle(
      fontFamily: homeFont,
      fontSize: 12,
      height: 1.25,
      fontWeight: FontWeight.w600,
      color: P2.brown,
      letterSpacing: 0,
    );
    final widths = <double>[];
    var rowHeight = 111.0;
    for (final item in homeCategories) {
      final painter = TextPainter(
        text: TextSpan(text: item.label, style: labelStyle),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout();
      widths.add(
        math.max(96 * math.max(1, scale), painter.width.ceilToDouble() + 2),
      );
      rowHeight = math.max(rowHeight, 80 + 8 + painter.height + 8);
      painter.dispose();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Danh mục',
            style: P2
                .serif(20, color: P2.green, weight: FontWeight.w700)
                .copyWith(height: 1.4, letterSpacing: -.5),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: rowHeight,
          child: ListView.separated(
            key: const ValueKey('home-categories'),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemCount: homeCategories.length,
            itemBuilder: (context, index) {
              final item = homeCategories[index];
              return SizedBox(
                width: widths[index],
                child: InkWell(
                  onTap: () => go(context, '/products', switch (item.label) {
                    'Đồ trang trí' => 'Decor',
                    'Thời trang len' => 'Thời trang',
                    _ => item.label,
                  }),
                  borderRadius: BorderRadius.circular(24),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: P2.cream,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x40000000),
                              offset: Offset(0, 4),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        child: P2Asset.node(
                          '2026:664',
                          item.icon,
                          width: item.width,
                          height: item.height,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.label,
                        textAlign: TextAlign.center,
                        style: labelStyle,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 2.65),
      ],
    );
  }
}
