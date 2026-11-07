import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';
import 'package:lenlab_customer/app/customer_scope.dart';
import 'package:lenlab_customer/app/navigation.dart';
import 'package:lenlab_customer/shared/widgets/header_widgets.dart';

class HomeHeader extends StatelessWidget implements PreferredSizeWidget {
  const HomeHeader({super.key});
  @override
  Size get preferredSize => const Size.fromHeight(66.13);
  @override
  Widget build(BuildContext context) {
    final store = CustomerScope.of(context);
    final textScale = MediaQuery.textScalerOf(context).scale(20) / 20;
    final brandStyle = P2
        .serif(20, color: P2.ink, weight: FontWeight.w800)
        .copyWith(height: 1.4, letterSpacing: 0);
    final brandPainter = TextPainter(
      text: TextSpan(text: 'LENLAB', style: brandStyle),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final brandWidth = math.max(
      80 * textScale,
      brandPainter.width.ceilToDouble() + 2,
    );
    brandPainter.dispose();
    return Material(
      color: Color.alphaBlend(P2.rose.withValues(alpha: .9), P2.cream),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 66.13,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal:
                  textScale > 1 && MediaQuery.sizeOf(context).width <= 360
                  ? 10
                  : 16,
            ),
            child: Row(
              children: [
                Builder(
                  builder: (c) => IconButton(
                    tooltip: 'Mở menu',
                    onPressed: () => Scaffold.of(c).openDrawer(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(
                      width: 44,
                      height: 44,
                    ),
                    icon: P2Asset.node(
                      '2026:664',
                      'imgContainer',
                      width: 18,
                      height: 12,
                    ),
                  ),
                ),
                SizedBox(
                  width: brandWidth,
                  child: HeaderHomeLink(
                    child: Text('LENLAB', maxLines: 1, style: brandStyle),
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Tìm kiếm sản phẩm',
                  onPressed: () => go(context, '/products'),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 44,
                    height: 44,
                  ),
                  icon: P2Asset.node(
                    '2026:664',
                    'imgContainer1',
                    width: 18,
                    height: 18,
                  ),
                ),
                IconButton(
                  tooltip: 'Giỏ hàng',
                  onPressed: () => go(context, '/cart'),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 44,
                    height: 44,
                  ),
                  icon: HeaderCartIcon(
                    showBadge: CustomerScope.of(context).cartCount > 0,
                  ),
                ),
                IconButton(
                  tooltip: 'Tài khoản',
                  onPressed: () =>
                      go(context, store.signedIn ? '/profile' : '/login'),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 44,
                    height: 44,
                  ),
                  icon: P2Asset.node(
                    '2026:664',
                    'imgContainer3',
                    width: 20,
                    height: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
