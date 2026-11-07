import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_admin/app.dart';
import 'package:lenlab_admin/features/auth/presentation/admin_login_page.dart';
import 'package:lenlab_admin/features/settings/data/admin_settings_source.dart';
import 'package:lenlab_admin/features/settings/presentation/admin_settings_page.dart';
import 'package:lenlab_admin/features/settings/presentation/widgets/settings_sections.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

import 'support/admin_test_session.dart';

Widget host(AdminSettingsSource source) => MaterialApp(
  theme: P2.theme(admin: true),
  home: Scaffold(body: AdminSettingsPage(source: source)),
);
void viewport(WidgetTester tester, {double width = 1280, double scale = 1}) {
  tester.view.physicalSize = Size(width, 1400);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

class ControlledSettings implements AdminSettingsSource {
  final request = Completer<AdminGeneralSettings?>();
  @override
  Future<AdminGeneralSettings?> fetch() => request.future;
}

void main() {
  test(
    'Read-only source returns P2 fixture, missing data and one-shot error',
    () async {
      final source = MockAdminSettingsSource(latency: Duration.zero);
      expect(identical(await source.fetch(), adminSettingsFixture), isTrue);
      expect(adminSettingsFixture.brandColorHex, '#E89F70');
      expect(adminSettingsFixture.emailNotifications, isFalse);
      expect(adminSettingsFixture.browserNotifications, isFalse);
      source.failNext = true;
      await expectLater(source.fetch(), throwsStateError);
      expect(await source.fetch(), adminSettingsFixture);
      expect(
        await MockAdminSettingsSource(
          latency: Duration.zero,
          settings: null,
        ).fetch(),
        isNull,
      );
    },
  );
  testWidgets('Loading then P2 values, readonly controls and fixed footer', (
    tester,
  ) async {
    viewport(tester);
    await tester.pumpWidget(host(MockAdminSettingsSource()));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('Lenlab Official'), findsOneWidget);
    expect(find.text('#E89F70'), findsOneWidget);
    expect(find.byType(EditableText), findsNothing);
    expect(
      tester
          .widget<Semantics>(
            find.byKey(const ValueKey('settings-website-name')),
          )
          .properties
          .readOnly,
      isTrue,
    );
    final swatch = tester.widget<Container>(
      find.byKey(const ValueKey('settings-color-swatch')),
    );
    expect(
      (swatch.decoration! as BoxDecoration).color,
      const Color(0xFFE89F70),
    );
    for (final key in ['settings-email', 'settings-browser']) {
      final semantics = tester
          .widget<Semantics>(find.byKey(ValueKey(key)))
          .properties;
      expect(semantics.toggled, isFalse);
      expect(semantics.enabled, isFalse);
    }
    expect(
      tester
          .widget<TextButton>(
            find.byKey(const ValueKey('settings-change-color')),
          )
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<TextButton>(find.byKey(const ValueKey('settings-cancel')))
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<FilledButton>(find.byKey(const ValueKey('settings-save')))
          .onPressed,
      isNull,
    );
    expect(find.byType(Switch), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'Error retry, empty configuration, nullable fields and invalid color are explicit',
    (tester) async {
      viewport(tester);
      final source = MockAdminSettingsSource(latency: Duration.zero)
        ..failNext = true;
      await tester.pumpWidget(host(source));
      await tester.pumpAndSettle();
      expect(find.text('Không thể tải cấu hình'), findsOneWidget);
      await tester.tap(find.text('Thử lại'));
      await tester.pumpAndSettle();
      expect(find.text('Lenlab Official'), findsOneWidget);
      await tester.pumpWidget(
        host(MockAdminSettingsSource(latency: Duration.zero, settings: null)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Chưa có cấu hình'), findsOneWidget);
      await tester.pumpWidget(
        host(
          MockAdminSettingsSource(
            latency: Duration.zero,
            settings: const AdminGeneralSettings(brandColorHex: 'bad-color'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Chưa có mã màu hợp lệ'), findsOneWidget);
      expect(find.text('Chưa có dữ liệu'), findsNWidgets(4));
      expect(find.text('Chưa có logo'), findsOneWidget);
      expect(find.byKey(const ValueKey('settings-email')), findsNothing);
      await tester.pumpWidget(
        host(
          MockAdminSettingsSource(
            latency: Duration.zero,
            settings: const AdminGeneralSettings(
              emailNotifications: true,
              browserNotifications: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<Semantics>(find.byKey(const ValueKey('settings-email')))
            .properties
            .toggled,
        isTrue,
      );
      expect(
        tester
            .widget<Semantics>(find.byKey(const ValueKey('settings-browser')))
            .properties
            .toggled,
        isFalse,
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'Source replacement and late success/error/disposal never leak old values',
    (tester) async {
      viewport(tester);
      final old = ControlledSettings();
      await tester.pumpWidget(host(old));
      await tester.pumpWidget(
        host(
          MockAdminSettingsSource(
            latency: Duration.zero,
            settings: const AdminGeneralSettings(websiteName: 'Current'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      old.request.complete(adminSettingsFixture);
      await tester.pumpAndSettle();
      expect(find.text('Current'), findsOneWidget);
      expect(find.text('Lenlab Official'), findsNothing);
      final pending = ControlledSettings();
      await tester.pumpWidget(host(pending));
      expect(find.text('Current'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpWidget(
        host(MockAdminSettingsSource(latency: Duration.zero)),
      );
      await tester.pumpAndSettle();
      pending.request.completeError(StateError('stale'));
      await tester.pumpAndSettle();
      expect(find.text('Không thể tải cấu hình'), findsNothing);
      final disposed = ControlledSettings();
      await tester.pumpWidget(host(disposed));
      await tester.pumpWidget(const SizedBox());
      disposed.request.completeError(StateError('disposed'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'Settings guard, sidebar route, Back and logout; header changes no theme',
    (tester) async {
      viewport(tester);
      await tester.pumpWidget(const AdminApp(initialRoute: '/settings'));
      await tester.pumpAndSettle();
      expect(find.byType(AdminLoginPage), findsOneWidget);
      expect(find.byType(AdminSettingsPage), findsNothing);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(AdminApp(session: await createSession()));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('admin-nav-settings')));
      await tester.pumpAndSettle();
      expect(find.byType(AdminSettingsPage), findsOneWidget);
      expect(
        ModalRoute.of(tester.element(find.byType(AdminSettingsPage)))!
            .settings
            .name,
        '/settings',
      );
      final before = Theme.of(tester.element(find.byType(AdminSettingsPage)))
          .colorScheme;
      await tester.tap(find.byTooltip('Đổi giao diện'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Đóng'));
      await tester.pumpAndSettle();
      expect(
        Theme.of(tester.element(find.byType(AdminSettingsPage))).colorScheme,
        before,
      );
      tester.state<NavigatorState>(find.byType(Navigator)).pop();
      await tester.pumpAndSettle();
      expect(find.byType(AdminSettingsPage), findsNothing);
      await tester.tap(find.byKey(const ValueKey('admin-nav-settings')));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Đăng xuất'));
      await tester.pumpAndSettle();
      expect(find.byType(AdminLoginPage), findsOneWidget);
    },
  );
  for (final width in [390.0, 800.0, 1280.0]) {
    testWidgets(
      'Settings $width text120 sections scroll above reachable footer',
      (tester) async {
        viewport(tester, width: width, scale: 1.2);
        await tester.pumpWidget(
          AdminApp(initialRoute: '/settings', session: await createSession()),
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byType(SettingsNotificationsSection));
        await tester.pumpAndSettle();
        final footerRect = tester.getRect(
          find.byKey(const ValueKey('settings-save')),
        );
        expect(footerRect.bottom, lessThanOrEqualTo(1400));
        expect(footerRect.left, greaterThanOrEqualTo(0));
        if (width < 960) {
          await tester.tap(find.byTooltip('Mở menu quản trị'));
          await tester.pumpAndSettle();
          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();
          expect(find.byType(Drawer), findsNothing);
        }
        expect(tester.takeException(), isNull);
      },
    );
  }
}
