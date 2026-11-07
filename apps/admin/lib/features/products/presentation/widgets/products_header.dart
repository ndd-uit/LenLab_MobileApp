import 'package:flutter/material.dart';

import '../../../../shared/layout/admin_styles.dart';
import 'product_styles.dart';

class ProductsHeader extends StatelessWidget {
  const ProductsHeader({super.key, this.onMenu});
  final VoidCallback? onMenu;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(bottom: BorderSide(color: productBorder)),
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
                    'Danh sách sản phẩm',
                    style: TextStyle(
                      fontSize: 24,
                      height: 32 / 24,
                      fontWeight: FontWeight.bold,
                      color: productInk,
                    ),
                  ),
                  Text(
                    'Quản lý kho hàng và danh mục sản phẩm của bạn.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 20 / 14,
                      color: productMuted,
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
              icon: productAsset('imgContainer9', 17.96, 17.955),
            ),
            _action(
              'Xóa mục đã chọn',
              'imgContainer10',
              13.969,
              18,
              const Color(0xFFEF4444),
            ),
            _action(
              'Thêm mới',
              'imgContainer11',
              13.969,
              13.969,
              productAccent,
            ),
          ],
        );
        return constraints.maxWidth >= 850 &&
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

  Widget _action(
    String label,
    String asset,
    double width,
    double height,
    Color color,
  ) => Tooltip(
    message: '$label chưa triển khai trong bản chỉ đọc',
    child: FilledButton.icon(
      onPressed: null,
      style: FilledButton.styleFrom(
        disabledBackgroundColor: color,
        disabledForegroundColor: const Color(0xFF523A30),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: productAsset(asset, width, height),
      label: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ),
  );
}
