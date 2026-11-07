import 'package:flutter/material.dart';

import '../data/admin_settings_source.dart';
import 'widgets/settings_header_footer.dart';
import 'widgets/settings_sections.dart';
import 'widgets/settings_styles.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key, this.source, this.onMenu});
  final AdminSettingsSource? source;
  final VoidCallback? onMenu;
  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  late AdminSettingsSource _source;
  late Future<AdminGeneralSettings?> _request;
  @override
  void initState() {
    super.initState();
    _reset();
  }

  @override
  void didUpdateWidget(covariant AdminSettingsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source != widget.source) {
      _reset();
    }
  }

  void _reset() {
    _source = widget.source ?? MockAdminSettingsSource();
    _request = _source.fetch();
  }

  void _retry() => setState(() {
    _request = _source.fetch();
  });
  @override
  Widget build(BuildContext context) => Column(
    children: [
      SettingsHeader(onMenu: widget.onMenu),
      Expanded(
        child: LayoutBuilder(
          builder: (context, c) => SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              c.maxWidth >= 800 ? 32 : 16,
              c.maxWidth >= 800 ? 56 : 24,
              c.maxWidth >= 800 ? 32 : 16,
              32,
            ),
            child: FutureBuilder<AdminGeneralSettings?>(
              future: _request,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const SizedBox(
                    height: 480,
                    child: Center(
                      child: CircularProgressIndicator(
                        semanticsLabel: 'Đang tải cấu hình',
                      ),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return _message(
                    'Không thể tải cấu hình',
                    'Vui lòng thử lại để xem cấu hình mẫu.',
                  );
                }
                final settings = snapshot.data;
                if (settings == null) {
                  return _message(
                    'Chưa có cấu hình',
                    'Nguồn dữ liệu chưa có cấu hình để hiển thị.',
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SettingsBrandSection(settings: settings),
                    const SizedBox(height: 24),
                    SettingsNotificationsSection(settings: settings),
                    const SizedBox(height: 16),
                    const Text(
                      'Dữ liệu mẫu P2 • Chỉ đọc • Chưa áp dụng cho hệ thống',
                      style: TextStyle(fontSize: 12, color: settingsMuted),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
      const SettingsFooter(),
    ],
  );
  Widget _message(String title, String description) => Container(
    constraints: const BoxConstraints(minHeight: 400),
    padding: const EdgeInsets.all(24),
    decoration: settingsSurface(),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: adminHeading,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          description,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: adminText),
        ),
        const SizedBox(height: 16),
        OutlinedButton(onPressed: _retry, child: const Text('Thử lại')),
      ],
    ),
  );
}
