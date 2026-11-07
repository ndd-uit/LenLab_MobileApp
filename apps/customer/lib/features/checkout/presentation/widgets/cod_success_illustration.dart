import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

class CodSuccessIllustration extends StatelessWidget {
  const CodSuccessIllustration({super.key});
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 148,
    height: 160,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 10,
          top: 0,
          child: Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: P2.checkoutButton.withValues(alpha: .2),
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: P2.checkoutButton.withValues(alpha: .15),
                  blurRadius: 24,
                ),
                const BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 15,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: P2Asset.node(
              '2026:1691',
              'imgAbstractSuccessIllustrationWithACharacterCelebrating',
              width: 80,
              height: 80,
            ),
          ),
        ),
        Positioned(
          left: 102,
          top: 95,
          child: P2Asset.node(
            '2026:1691',
            'imgBackgroundBorder',
            width: 49,
            height: 47,
          ),
        ),
      ],
    ),
  );
}
