import 'package:flutter/material.dart';

import 'settings_styles.dart';

class SettingsHeader extends StatelessWidget {
  const SettingsHeader({super.key, this.onMenu});
  final VoidCallback? onMenu;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(bottom: BorderSide(color: settingsBorder)),
    ),
    child: LayoutBuilder(
      builder: (context, c) {
        final title = Row(
          children: [
            if (onMenu != null)
              IconButton(
                tooltip: 'Mở menu quản trị',
                onPressed: onMenu,
                icon: const Icon(Icons.menu, color: adminText),
              ),
            Expanded(
              child: Wrap(
                spacing: 16,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(
                    'Cấu hình hệ thống',
                    style: TextStyle(
                      fontSize: 18,
                      height: 28 / 18,
                      fontWeight: FontWeight.bold,
                      color: adminHeading,
                    ),
                  ),
                  if (c.maxWidth >= 750)
                    const Text(
                      '|',
                      style: TextStyle(fontSize: 16, color: adminText),
                    ),
                  const Text(
                    'Tùy chỉnh giao diện & Thông báo',
                    style: TextStyle(
                      fontSize: 14,
                      height: 20 / 14,
                      color: adminText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
        final actions = Wrap(
          spacing: 12,
          children: [
            IconButton(
              tooltip: 'Thông báo',
              onPressed: () => adminPendingNotice(
                context,
                'Thông báo',
                'Chưa kết nối thông báo quản trị.',
              ),
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  settingsAsset('imgContainer8', 15.197, 19.5),
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Đổi giao diện',
              onPressed: () => adminPendingNotice(
                context,
                'Đổi giao diện',
                'Chưa triển khai đổi giao diện.',
              ),
              icon: settingsAsset('imgContainer9', 17.96, 17.955),
            ),
          ],
        );
        return c.maxWidth >= 750 &&
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
                children: [title, const SizedBox(height: 8), actions],
              );
      },
    ),
  );
}

class SettingsFooter extends StatelessWidget {
  const SettingsFooter({super.key});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: settingsBorder)),
    ),
    child: Align(
      alignment: Alignment.centerRight,
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        alignment: WrapAlignment.end,
        children: [
          Tooltip(
            message: 'Không có thay đổi trong chế độ chỉ đọc',
            child: TextButton(
              key: const ValueKey('settings-cancel'),
              onPressed: null,
              style: TextButton.styleFrom(
                disabledForegroundColor: settingsMuted,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Hủy bỏ',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Tooltip(
            message: 'Lưu cấu hình chưa triển khai trong bản chỉ đọc',
            child: FilledButton(
              key: const ValueKey('settings-save'),
              onPressed: null,
              style: FilledButton.styleFrom(
                disabledBackgroundColor: const Color(0xFFD97757),
                disabledForegroundColor: const Color(0xFF332620),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Lưu thay đổi',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
