import 'package:flutter/material.dart';

import '../../../../shared/widgets/admin_dashed_border.dart';
import '../../data/admin_settings_source.dart';
import 'settings_styles.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.child,
  });
  final String title, description;
  final Widget icon, child;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: settingsSurface(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            icon,
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  height: 28 / 18,
                  fontWeight: FontWeight.bold,
                  color: adminHeading,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: const TextStyle(
            fontSize: 14,
            height: 20 / 14,
            color: adminText,
          ),
        ),
        const SizedBox(height: 16),
        const Divider(height: 1, color: settingsBorder),
        const SizedBox(height: 24),
        child,
      ],
    ),
  );
}

class SettingsBrandSection extends StatelessWidget {
  const SettingsBrandSection({super.key, required this.settings});
  final AdminGeneralSettings settings;
  String _value(String? value) =>
      value == null || value.trim().isEmpty ? 'Chưa có dữ liệu' : value;
  @override
  Widget build(BuildContext context) => SettingsSection(
    title: 'Tùy chỉnh Giao diện',
    description: 'Thiết lập các yếu tố nhận diện thương hiệu',
    icon: settingsAsset('imgContainer10', 19.969, 19.969),
    child: LayoutBuilder(
      builder: (context, c) {
        final validColor = RegExp(r'^#[0-9a-fA-F]{6}$')
            .hasMatch(settings.brandColorHex ?? '');
        final color = validColor
            ? Color(
                0xFF000000 |
                    int.parse(settings.brandColorHex!.substring(1), radix: 16),
              )
            : const Color(0xFFE5E7EB);
        final identity = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _label('Tên Website'),
            const SizedBox(height: 8),
            Semantics(
              key: const ValueKey('settings-website-name'),
              readOnly: true,
              textField: true,
              label: 'Tên Website',
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 11,
                ),
                decoration: _fieldSurface(),
                child: Text(
                  _value(settings.websiteName),
                  style: const TextStyle(
                    fontSize: 14,
                    height: 20 / 14,
                    color: settingsMuted,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _label('Màu sắc chủ đạo'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: _fieldSurface(),
              child: Row(
                children: [
                  Container(
                    key: const ValueKey('settings-color-swatch'),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _value(settings.brandColorName),
                          style: const TextStyle(
                            fontSize: 14,
                            height: 20 / 14,
                            color: adminHeading,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          validColor
                              ? settings.brandColorHex!
                              : 'Chưa có mã màu hợp lệ',
                          style: const TextStyle(
                            fontSize: 12,
                            height: 16 / 12,
                            color: settingsMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Tooltip(
                    message: 'Đổi màu chưa triển khai trong bản chỉ đọc',
                    child: TextButton(
                      key: const ValueKey('settings-change-color'),
                      onPressed: null,
                      style: TextButton.styleFrom(
                        disabledForegroundColor: const Color(0xFF7A2929),
                        minimumSize: const Size(0, 28),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Thay đổi',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
        final images = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _label('Logo Website'),
            const SizedBox(height: 8),
            Tooltip(
              message: 'Upload logo chưa triển khai',
              child: CustomPaint(
                foregroundPainter: const AdminDashedBorder(radius: 16),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0x80F9FAFB),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      if (settings.showSampleLogo)
                        Container(
                          width: 64,
                          height: 64,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: Color(0xFFD97757),
                            shape: BoxShape.circle,
                          ),
                          child: settingsAsset('imgContainer11', 22.324, 22.5),
                        )
                      else
                        const Text(
                          'Chưa có logo',
                          style: TextStyle(fontSize: 14, color: settingsMuted),
                        ),
                      const SizedBox(height: 12),
                      const Text(
                        'Tải lên logo mới',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          height: 20 / 14,
                          color: Color(0xFF7A2929),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'SVG, PNG, JPG (Max. 800x400px)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          height: 16 / 12,
                          color: adminText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _label('Favicon'),
            const SizedBox(height: 8),
            Tooltip(
              message: 'Upload favicon chưa triển khai',
              child: Row(
                children: [
                  CustomPaint(
                    foregroundPainter: const AdminDashedBorder(),
                    child: Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: settingsAsset('imgContainer12', 13.969, 16.594),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Kích thước đề xuất: 32x32px\nDùng làm biểu tượng trên tab trình duyệt',
                      style: TextStyle(
                        fontSize: 12,
                        height: 16 / 12,
                        color: adminText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
        return c.maxWidth >= 650 &&
                MediaQuery.textScalerOf(context).scale(14) <= 16
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: identity),
                  const SizedBox(width: 32),
                  Expanded(child: images),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [identity, const SizedBox(height: 32), images],
              );
      },
    ),
  );
  Widget _label(String value) => Text(
    value,
    style: const TextStyle(
      fontSize: 14,
      height: 20 / 14,
      fontWeight: FontWeight.w600,
      color: adminHeading,
    ),
  );
  BoxDecoration _fieldSurface() => BoxDecoration(
    color: const Color(0xFFF9FAFB),
    border: Border.all(color: const Color(0xFFE5E7EB)),
    borderRadius: BorderRadius.circular(8),
  );
}

class SettingsNotificationsSection extends StatelessWidget {
  const SettingsNotificationsSection({super.key, required this.settings});
  final AdminGeneralSettings settings;
  @override
  Widget build(BuildContext context) => SettingsSection(
    title: 'Cấu hình Thông báo',
    description: 'Quản lý cách bạn nhận thông tin từ hệ thống',
    icon: settingsAsset('imgContainer13', 19.711, 19.5),
    child: Column(
      children: [
        _row(
          'Thông báo qua Email',
          'Nhận đơn hàng mới qua email admin',
          settings.emailNotifications,
          'settings-email',
        ),
        const SizedBox(height: 24),
        const Divider(height: 1, color: settingsBorder),
        const SizedBox(height: 24),
        _row(
          'Thông báo Trình duyệt',
          'Pop-up khi có tin nhắn mới',
          settings.browserNotifications,
          'settings-browser',
        ),
      ],
    ),
  );
  Widget _row(String title, String description, bool? enabled, String key) =>
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 20 / 14,
                    fontWeight: FontWeight.bold,
                    color: adminHeading,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 16 / 12,
                    color: adminText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          if (enabled == null)
            const Flexible(
              child: Text(
                'Chưa có dữ liệu',
                style: TextStyle(fontSize: 12, color: settingsMuted),
              ),
            )
          else
            Semantics(
              key: ValueKey(key),
              label: '$title, chỉ đọc',
              toggled: enabled,
              enabled: false,
              child: Tooltip(
                message: 'Trạng thái chỉ đọc, chưa kết nối dịch vụ',
                child: Container(
                  width: 44,
                  height: 24,
                  padding: const EdgeInsets.all(4),
                  alignment: enabled
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: enabled
                        ? const Color(0xFFD97757)
                        : const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
}
