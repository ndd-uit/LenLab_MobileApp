import 'support/admin_test_session.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_admin/app.dart';
import 'package:lenlab_admin/app/admin_scope.dart';
import 'package:lenlab_admin/app/admin_session.dart';
import 'package:lenlab_admin/features/auth/data/admin_auth_source.dart';
import 'package:lenlab_admin/features/auth/presentation/admin_login_page.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final font = FontLoader('packages/lenlab_shared/Inter');
    font.addFont(
      rootBundle.load('packages/lenlab_shared/assets/fonts/Inter.ttf'),
    );
    await font.load();
    final icons = FontLoader('MaterialIcons');
    icons.addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });
  for (final width in [1280.0, 390.0]) {
    testWidgets('Admin blue login $width render', (tester) async {
      final previousShadows = debugDisableShadows;
      debugDisableShadows = false;
      try {
        tester.view.physicalSize = Size(width, width == 1280 ? 723 : 1100);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        if (width == 390) {
          tester.platformDispatcher.textScaleFactorTestValue = 1.2;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        }
        final session = AdminSession(source: MockAdminAuthSource());
        addTearDown(session.dispose);
        await tester.pumpWidget(
          AdminScope(
            session: session,
            child: MaterialApp(
              theme: P2.theme(admin: true),
              home: const AdminLoginPage(copyrightYear: 2026),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.runAsync(() async {
          final context = tester.element(find.byType(Scaffold));
          await Future.wait(
            tester
                .widgetList<Image>(find.byType(Image))
                .map((img) => precacheImage(img.image, context)),
          );
        });
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile(
            'goldens/admin-login-blue${width == 390 ? '-390-text120' : ''}.png',
          ),
        );
      } finally {
        debugDisableShadows = previousShadows;
      }
    });
  }
  for (final width in [1280.0, 800.0, 390.0]) {
    testWidgets('Products P2 $width render', (tester) async {
      tester.view.physicalSize = Size(width, width == 390 ? 1500 : 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      if (width != 1280) {
        tester.platformDispatcher.textScaleFactorTestValue = 1.2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      }
      await tester.pumpWidget(
        AdminApp(initialRoute: '/products', session: await createSession()),
      );
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        final context = tester.element(find.byType(Scaffold));
        await Future.wait(
          tester
              .widgetList<Image>(find.byType(Image))
              .map((img) => precacheImage(img.image, context)),
        );
      });
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile(
          'goldens/admin-products-${width.toInt()}${width != 1280 ? '-text120' : ''}.png',
        ),
      );
    });
  }
  for (final width in [1280.0, 800.0, 390.0]) {
    testWidgets('Orders P2 $width render', (tester) async {
      tester.view.physicalSize = Size(width, width == 390 ? 1500 : 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      if (width != 1280) {
        tester.platformDispatcher.textScaleFactorTestValue = 1.2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      }
      await tester.pumpWidget(
        AdminApp(initialRoute: '/orders', session: await createSession()),
      );
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        final context = tester.element(find.byType(Scaffold));
        await Future.wait(
          tester
              .widgetList<Image>(find.byType(Image))
              .map((img) => precacheImage(img.image, context)),
        );
      });
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile(
          'goldens/admin-orders-${width.toInt()}${width != 1280 ? '-text120' : ''}.png',
        ),
      );
    });
  }
  for (final width in [1280.0, 800.0, 390.0]) {
    testWidgets('Order detail P2 $width render', (tester) async {
      tester.view.physicalSize = Size(width, width == 390 ? 1700 : 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      if (width != 1280) {
        tester.platformDispatcher.textScaleFactorTestValue = 1.2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      }
      await tester.pumpWidget(
        AdminApp(
          initialRoute: '/orders/detail?id=ORD-202502',
          session: await createSession(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        final context = tester.element(find.byType(Scaffold));
        await Future.wait(
          tester
              .widgetList<Image>(find.byType(Image))
              .map((img) => precacheImage(img.image, context)),
        );
      });
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile(
          'goldens/admin-order-detail-${width.toInt()}${width != 1280 ? '-text120' : ''}.png',
        ),
      );
    });
  }
  for (final width in [1280.0, 800.0, 390.0]) {
    testWidgets('Customers P2 $width render', (tester) async {
      tester.view.physicalSize = Size(width, width == 390 ? 1500 : 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      if (width != 1280) {
        tester.platformDispatcher.textScaleFactorTestValue = 1.2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      }
      await tester.pumpWidget(
        AdminApp(initialRoute: '/customers', session: await createSession()),
      );
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        final context = tester.element(find.byType(Scaffold));
        await Future.wait(
          tester
              .widgetList<Image>(find.byType(Image))
              .map((img) => precacheImage(img.image, context)),
        );
      });
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile(
          'goldens/admin-customers-${width.toInt()}${width != 1280 ? '-text120' : ''}.png',
        ),
      );
    });
  }
  for (final width in [1280.0, 800.0, 390.0]) {
    testWidgets('Customer detail P2 $width render', (tester) async {
      tester.view.physicalSize = Size(width, width == 390 ? 1700 : 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      if (width != 1280) {
        tester.platformDispatcher.textScaleFactorTestValue = 1.2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      }
      await tester.pumpWidget(
        AdminApp(
          initialRoute: '/customers/detail?id=USR-001',
          session: await createSession(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        final context = tester.element(find.byType(Scaffold));
        await Future.wait(
          tester
              .widgetList<Image>(find.byType(Image))
              .map((img) => precacheImage(img.image, context)),
        );
      });
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile(
          'goldens/admin-customer-detail-${width.toInt()}${width != 1280 ? '-text120' : ''}.png',
        ),
      );
    });
  }
  for (final width in [1280.0, 800.0, 390.0]) {
    testWidgets('Reviews P2 $width render', (tester) async {
      tester.view.physicalSize = Size(width, width == 390 ? 1700 : 1500);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      if (width != 1280) {
        tester.platformDispatcher.textScaleFactorTestValue = 1.2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      }
      await tester.pumpWidget(
        AdminApp(initialRoute: '/reviews', session: await createSession()),
      );
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        final context = tester.element(find.byType(Scaffold));
        await Future.wait(
          tester
              .widgetList<Image>(find.byType(Image))
              .map((img) => precacheImage(img.image, context)),
        );
      });
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile(
          'goldens/admin-reviews-${width.toInt()}${width != 1280 ? '-text120' : ''}.png',
        ),
      );
    });
  }
  for (final width in [1280.0, 800.0, 390.0]) {
    testWidgets('Settings P2 $width render', (tester) async {
      tester.view.physicalSize = Size(width, width == 390 ? 1500 : 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      if (width != 1280) {
        tester.platformDispatcher.textScaleFactorTestValue = 1.2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      }
      await tester.pumpWidget(
        AdminApp(initialRoute: '/settings', session: await createSession()),
      );
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        final context = tester.element(find.byType(Scaffold));
        await Future.wait(
          tester
              .widgetList<Image>(find.byType(Image))
              .map((img) => precacheImage(img.image, context)),
        );
      });
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile(
          'goldens/admin-settings-${width.toInt()}${width != 1280 ? '-text120' : ''}.png',
        ),
      );
    });
  }
  for (final width in [1280.0, 800.0, 390.0]) {
    testWidgets('Conversations P2 $width render', (tester) async {
      tester.view.physicalSize = Size(width, width == 390 ? 1900 : 1300);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      if (width != 1280) {
        tester.platformDispatcher.textScaleFactorTestValue = 1.2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      }
      await tester.pumpWidget(
        AdminApp(
          initialRoute: '/conversations',
          session: await createSession(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        final context = tester.element(find.byType(Scaffold));
        await Future.wait(
          tester
              .widgetList<Image>(find.byType(Image))
              .map((img) => precacheImage(img.image, context)),
        );
      });
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile(
          'goldens/admin-conversations-${width.toInt()}${width != 1280 ? '-text120' : ''}.png',
        ),
      );
    });
  }
  for (final width in [1280.0, 800.0, 390.0]) {
    testWidgets('Chatbot P2 $width render', (tester) async {
      tester.view.physicalSize = Size(width, width == 390 ? 1900 : 1300);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      if (width != 1280) {
        tester.platformDispatcher.textScaleFactorTestValue = 1.2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      }
      await tester.pumpWidget(
        AdminApp(
          initialRoute: '/conversations/chatbot',
          session: await createSession(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        final context = tester.element(find.byType(Scaffold));
        await Future.wait(
          tester
              .widgetList<Image>(find.byType(Image))
              .map((img) => precacheImage(img.image, context)),
        );
      });
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile(
          'goldens/admin-chatbot-${width.toInt()}${width != 1280 ? '-text120' : ''}.png',
        ),
      );
    });
  }
  for (final width in [1280.0, 800.0, 390.0]) {
    testWidgets('Percentage coupon P2 $width render', (tester) async {
      tester.view.physicalSize = Size(width, width == 390 ? 1900 : 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      if (width != 1280) {
        tester.platformDispatcher.textScaleFactorTestValue = 1.2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      }
      await tester.pumpWidget(
        AdminApp(
          initialRoute: '/vouchers/percentage',
          session: await createSession(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        final context = tester.element(find.byType(Scaffold));
        await Future.wait(
          tester
              .widgetList<Image>(find.byType(Image))
              .map((img) => precacheImage(img.image, context)),
        );
      });
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile(
          'goldens/admin-percentage-coupon-${width.toInt()}${width != 1280 ? '-text120' : ''}.png',
        ),
      );
    });
  }
  for (final width in [1280.0, 800.0, 390.0]) {
    testWidgets('Fixed coupon P2 $width render', (tester) async {
      tester.view.physicalSize = Size(width, width == 390 ? 1900 : 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      if (width != 1280) {
        tester.platformDispatcher.textScaleFactorTestValue = 1.2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      }
      await tester.pumpWidget(
        AdminApp(
          initialRoute: '/vouchers/fixed',
          session: await createSession(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        final context = tester.element(find.byType(Scaffold));
        await Future.wait(
          tester
              .widgetList<Image>(find.byType(Image))
              .map((img) => precacheImage(img.image, context)),
        );
      });
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile(
          'goldens/admin-fixed-coupon-${width.toInt()}${width != 1280 ? '-text120' : ''}.png',
        ),
      );
    });
  }
  for (final width in [390.0, 800.0]) {
    testWidgets('Dashboard $width text120 render', (tester) async {
      tester.view.physicalSize = Size(width, 1300);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(AdminApp(session: await createSession()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile(
          'goldens/admin-dashboard-${width.toInt()}-text120.png',
        ),
      );
    });
  }
  for (final width in [1280.0, 800.0]) {
    testWidgets('Admin A01 $width render', (tester) async {
      tester.view.physicalSize = Size(width, 1024);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      if (width == 800) {
        tester.platformDispatcher.textScaleFactorTestValue = 1.2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      }
      await tester.pumpWidget(AdminApp(session: await createSession()));
      await tester.pumpAndSettle();
      if (width == 800) {
        await tester.tap(find.byTooltip('Mở menu quản trị'));
        await tester.pumpAndSettle();
      }
      await tester.runAsync(() async {
        final context = tester.element(find.byType(Scaffold));
        await Future.wait(
          tester
              .widgetList<Image>(find.byType(Image))
              .map((img) => precacheImage(img.image, context)),
        );
      });
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile(
          'goldens/admin-shell${width == 800 ? '-800-text120' : ''}.png',
        ),
      );
    });
  }
}
