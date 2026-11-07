import 'package:flutter/material.dart';

import 'admin_styles.dart';

class AdminHeader extends StatelessWidget {
  const AdminHeader({super.key, this.onMenu});
  final VoidCallback? onMenu;
  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 68),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(bottom: BorderSide(color: adminDivider)),
      boxShadow: [
        BoxShadow(
          color: Color(0x0D000000),
          offset: Offset(0, 1),
          blurRadius: 2,
        ),
      ],
    ),
    child: Row(
      children: [
        if (onMenu != null)
          IconButton(
            tooltip: 'Mở menu quản trị',
            onPressed: onMenu,
            icon: const Icon(Icons.menu, color: adminText),
          ),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: onMenu == null ? 16 : 0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 512),
                child: Material(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => adminPendingNotice(
                      context,
                      'Tìm kiếm',
                      'Tìm kiếm sản phẩm và đơn hàng chưa được triển khai.',
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          adminAsset('imgIcon', 17.054, 17.054),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Tìm kiếm sản phẩm, đơn hàng...',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 14, color: adminText),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          tooltip: 'Thông báo',
          onPressed: () => adminPendingNotice(
            context,
            'Thông báo',
            'Thông báo admin chưa được tích hợp.',
          ),
          icon: SizedBox(
            width: 20,
            height: 22,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: adminAsset('imgContainer9', 15.197, 19.5),
                ),
                Positioned(
                  top: 0,
                  right: 1,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        IconButton(
          tooltip: 'Đổi giao diện',
          onPressed: () => adminPendingNotice(
            context,
            'Đổi giao diện',
            'Giao diện tối chưa được triển khai.',
          ),
          icon: adminAsset('imgContainer10', 17.96, 17.955),
        ),
      ],
    ),
  );
}
