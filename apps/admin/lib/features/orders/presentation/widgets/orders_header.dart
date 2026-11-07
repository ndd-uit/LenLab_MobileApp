import 'package:flutter/material.dart';

import '../../../../shared/layout/admin_styles.dart';
import 'order_styles.dart';

class OrdersHeader extends StatelessWidget {
  const OrdersHeader({super.key, this.onMenu});
  final VoidCallback? onMenu;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(bottom: BorderSide(color: adminListBorder)),
    ),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final title = Row(
          children: [
            if (onMenu != null)
              IconButton(
                tooltip: 'Mở menu quản trị',
                onPressed: onMenu,
                icon: const Icon(Icons.menu, color: adminText),
              ),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Danh sách đơn hàng',
                    style: TextStyle(
                      fontSize: 24,
                      height: 32 / 24,
                      fontWeight: FontWeight.bold,
                      color: adminListInk,
                    ),
                  ),
                  Text(
                    'Quản lý và theo dõi trạng thái các đơn hàng.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 20 / 14,
                      color: adminListMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
        final actions = Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            IconButton(
              tooltip: 'Đổi giao diện',
              onPressed: () => adminPendingNotice(
                context,
                'Đổi giao diện',
                'Chưa triển khai đổi giao diện.',
              ),
              icon: orderAsset('imgContainer9', 17.96, 17.955),
            ),
            Tooltip(
              message: 'Tạo đơn hàng chưa triển khai trong bản chỉ đọc',
              child: FilledButton.icon(
                onPressed: null,
                style: FilledButton.styleFrom(
                  disabledBackgroundColor: orderAccent,
                  disabledForegroundColor: const Color(0xFF523A30),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: orderAsset('imgContainer10', 8.148, 8.148),
                label: const Text(
                  'Tạo đơn hàng',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        );
        return constraints.maxWidth >= 750 &&
                MediaQuery.textScalerOf(context).scale(14) <= 16
            ? Row(
                children: [
                  Expanded(child: title),
                  const SizedBox(width: 16),
                  actions,
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [title, const SizedBox(height: 12), actions],
              );
      },
    ),
  );
}
