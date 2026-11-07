import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

const drawerEntries = [
  (
    label: 'Trang chủ',
    route: '/',
    asset: 'imgContainer',
    width: 22.0,
    height: 20.0,
  ),
  (
    label: 'Sản phẩm',
    route: '/products',
    asset: 'imgContainer1',
    width: 20.0,
    height: 16.0,
  ),
  (
    label: 'Về chúng tôi',
    route: '/about',
    asset: 'imgContainer3',
    width: 16.995,
    height: 16.992,
  ),
  (
    label: 'Hỗ trợ',
    route: '/faq',
    asset: 'imgContainer5',
    width: 20.0,
    height: 18.0,
  ),
];

class DrawerEntry extends StatelessWidget {
  const DrawerEntry({
    super.key,
    required this.index,
    required this.open,
    required this.node,
  });
  final int index;
  final String node;
  final ValueChanged<String> open;
  @override
  Widget build(BuildContext context) {
    final item = drawerEntries[index];
    return Semantics(
      button: true,
      child: InkWell(
        onTap: () => open(item.route),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              P2Asset.node(
                node,
                item.asset,
                width: item.width,
                height: item.height,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  item.label,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                    color: P2.brown,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
