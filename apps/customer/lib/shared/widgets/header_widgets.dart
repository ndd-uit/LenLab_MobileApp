import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

import '../../app/navigation.dart';

/// Orders is the visual reference for every customer header back button.
/// Fallbacks stay explicit because checkout steps have different entry points.
class HeaderBackButton extends StatelessWidget {
  const HeaderBackButton({super.key, this.onFallback, this.round = false});
  final VoidCallback? onFallback;
  final bool round;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 44,
    height: 44,
    child: IconButton(
      tooltip: 'Quay lại',
      onPressed: () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else if (onFallback != null) {
          onFallback!();
        } else {
          home(context);
        }
      },
      style: IconButton.styleFrom(
        fixedSize: const Size(44, 44),
        padding: EdgeInsets.zero,
        backgroundColor: round ? P2.rose.withValues(alpha: .9) : null,
        shape: const CircleBorder(),
      ),
      icon: ColorFiltered(
        colorFilter: const ColorFilter.mode(P2.brown, BlendMode.srcIn),
        child: P2Asset.node(
          '2026:1852',
          'imgContainer',
          width: 11.775,
          height: 20,
        ),
      ),
    ),
  );
}

/// Shared cart glyph and badge for every customer header and detail overlay.
class HeaderCartIcon extends StatelessWidget {
  const HeaderCartIcon({super.key, required this.showBadge, this.color});
  final bool showBadge;
  final Color? color;
  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      if (color == null)
        P2Asset.node('2026:664', 'imgContainer2', width: 16, height: 20)
      else
        ColorFiltered(
          colorFilter: ColorFilter.mode(color!, BlendMode.srcIn),
          child: P2Asset.node(
            '2026:664',
            'imgContainer2',
            width: 16,
            height: 20,
          ),
        ),
      if (showBadge)
        Positioned(
          right: -3,
          top: -3,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFFFAC638),
              shape: BoxShape.circle,
            ),
          ),
        ),
    ],
  );
}

class HeaderHomeLink extends StatelessWidget {
  const HeaderHomeLink({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'LENLAB — Trang chủ',
    excludeSemantics: true,
    child: InkWell(
      onTap: () => home(context),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Align(
          alignment: Alignment.centerLeft,
          widthFactor: 1,
          heightFactor: 1,
          child: child,
        ),
      ),
    ),
  );
}
