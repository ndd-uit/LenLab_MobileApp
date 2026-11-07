import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';
import 'package:lenlab_customer/app/navigation.dart';

import '../home_styles.dart';

class HomeHero extends StatelessWidget {
  const HomeHero({super.key});
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(15),
    child: AspectRatio(
      aspectRatio: 358 / 508.696,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const P2Asset('a7b0e.png', label: 'Thủ công và bền vững'),
          const Positioned(
            right: 23,
            top: 34.5,
            child: SizedBox(
              width: 177,
              child: Text(
                'THỦ CÔNG\nVÀ BỀN VỮNG',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: 'packages/lenlab_shared/Bangers',
                  fontSize: 48,
                  height: 1,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 16.5,
            left: 24,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 142,
                child: InkWell(
                  onTap: () => go(context, '/about'),
                  borderRadius: BorderRadius.circular(99),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 44),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 31),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAC638).withValues(alpha: .45),
                          border: Border.all(
                            color: const Color(0xFFFAC638)
                                .withValues(alpha: .6),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: const Text(
                          'Xem thêm',
                          style: TextStyle(
                            fontFamily: homeFont,
                            fontSize: 15,
                            height: 1.2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
