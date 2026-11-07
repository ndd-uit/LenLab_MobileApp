import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';
import 'package:lenlab_customer/app/customer_scope.dart';
import 'package:lenlab_customer/app/navigation.dart';
import 'package:lenlab_customer/shared/widgets/header_widgets.dart';

import '../catalog_styles.dart';

class CatalogHeader extends StatelessWidget implements PreferredSizeWidget {
  const CatalogHeader({
    super.key,
    required this.controller,
    required this.onChanged,
  });
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  @override
  Size get preferredSize => const Size.fromHeight(67);
  @override
  Widget build(BuildContext context) => Material(
    color: Color.alphaBlend(P2.rose.withValues(alpha: .9), P2.cream),
    child: SafeArea(
      bottom: false,
      child: SizedBox(
        height: 67,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Builder(
                builder: (c) => IconButton(
                  tooltip: 'Mở menu',
                  constraints: const BoxConstraints.tightFor(
                    width: 44,
                    height: 44,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: () => Scaffold.of(c).openDrawer(),
                  icon: P2Asset.node(
                    catalogNode,
                    'imgContainer',
                    width: 18,
                    height: 12,
                  ),
                ),
              ),
              HeaderHomeLink(
                child: Text(
                  'LENLAB',
                  style: P2
                      .serif(20, color: P2.ink, weight: FontWeight.w800)
                      .copyWith(letterSpacing: 0),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  style: const TextStyle(fontSize: 14, letterSpacing: 0),
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm',
                    isDense: true,
                    filled: true,
                    fillColor: P2.cream,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 32),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(8),
                      child: P2Asset.node(
                        catalogNode,
                        'imgContainer1',
                        width: 15,
                        height: 15,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(99),
                      borderSide: const BorderSide(color: P2.brown),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(99),
                      borderSide: const BorderSide(color: P2.brown),
                    ),
                  ),
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
                onPressed: () => go(
                  context,
                  CustomerScope.of(context).signedIn ? '/profile' : '/login',
                ),
                icon: P2Asset.node(
                  catalogNode,
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
