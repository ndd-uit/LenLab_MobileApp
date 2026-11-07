import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';
import 'package:lenlab_customer/shared/widgets/header_widgets.dart';

import '../detail_styles.dart';

class DetailOverlayButton extends StatelessWidget {
  const DetailOverlayButton({
    super.key,
    required this.label,
    required this.asset,
    required this.width,
    required this.height,
    required this.onPressed,
    this.badge = false,
    this.selected = false,
  });
  final String label, asset;
  final double width, height;
  final VoidCallback onPressed;
  final bool badge, selected;
  @override
  Widget build(BuildContext context) => Semantics(
    toggled: selected,
    child: IconButton(
      tooltip: label,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: P2.rose.withValues(alpha: .9),
        side: selected
            ? const BorderSide(color: Colors.white, width: 2)
            : BorderSide.none,
        fixedSize: const Size(44, 44),
      ),
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          if (asset == 'cart')
            HeaderCartIcon(showBadge: badge)
          else
            ColorFiltered(
              colorFilter: const ColorFilter.mode(P2.brown, BlendMode.srcIn),
              child: detailAsset(asset, width, height),
            ),
          if (badge && asset != 'cart')
            Positioned(
              right: -8,
              top: -8,
              child: detailAsset('imgBackgroundBorder', 10, 10),
            ),
        ],
      ),
    ),
  );
}
