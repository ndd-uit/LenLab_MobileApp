class AdminGeneralSettings {
  const AdminGeneralSettings({
    this.websiteName,
    this.brandColorName,
    this.brandColorHex,
    this.showSampleLogo = false,
    this.emailNotifications,
    this.browserNotifications,
  });
  final String? websiteName, brandColorName, brandColorHex;
  final bool showSampleLogo;
  final bool? emailNotifications, browserNotifications;
}

abstract interface class AdminSettingsSource {
  Future<AdminGeneralSettings?> fetch();
}

class MockAdminSettingsSource implements AdminSettingsSource {
  MockAdminSettingsSource({
    this.latency = const Duration(milliseconds: 300),
    this.settings = adminSettingsFixture,
  });
  final Duration latency;
  final AdminGeneralSettings? settings;
  bool failNext = false;
  @override
  Future<AdminGeneralSettings?> fetch() async {
    await Future<void>.delayed(latency);
    if (failNext) {
      failNext = false;
      throw StateError('Mock settings unavailable');
    }
    return settings;
  }
}

// P2 illustration only. These values do not configure either running app.
const adminSettingsFixture = AdminGeneralSettings(
  websiteName: 'Lenlab Official',
  brandColorName: 'Cam Đất (Terracotta)',
  brandColorHex: '#E89F70',
  showSampleLogo: true,
  emailNotifications: false,
  browserNotifications: false,
);
