import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_admin/app.dart';
import 'package:lenlab_admin/features/auth/presentation/admin_login_page.dart';
import 'package:lenlab_admin/features/conversations/data/admin_chatbot_source.dart';
import 'package:lenlab_admin/features/conversations/presentation/admin_chatbot_page.dart';
import 'package:lenlab_admin/features/conversations/presentation/admin_conversations_page.dart';
import 'package:lenlab_admin/shared/layout/admin_sidebar_item.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

import 'support/admin_test_session.dart';

void viewport(WidgetTester tester, {double width = 1280}) {
  tester.view.physicalSize = Size(width, 1300);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Widget host(AdminChatbotSource source) => MaterialApp(
  theme: P2.theme(admin: true),
  home: Scaffold(body: AdminChatbotPage(source: source)),
);
Finder save = find.byKey(const ValueKey('chatbot-save'));

class ControlledChatbot implements AdminChatbotSource {
  final result = Completer<AdminChatbotScenario?>();
  @override
  Future<AdminChatbotScenario?> fetch() => result.future;
}

void main() {
  test(
    'Source keeps exact P2 data, supports null and one-shot failure',
    () async {
      final source = MockAdminChatbotSource(latency: Duration.zero);
      expect(await source.fetch(), same(adminChatbotScenarioFixture));
      expect(source.scenario!.topic, 'Ước tính số lượng len');
      expect(source.scenario!.enabled, isTrue);
      expect(
        source.scenario!.requiredInformation,
        'Loại sản phẩm, kích thước, trọng lượng mẫu thử, trọng lượng và chiều dài mỗi cuộn.',
      );
      source.failNext = true;
      await expectLater(source.fetch(), throwsStateError);
      expect(await source.fetch(), same(adminChatbotScenarioFixture));
      expect(
        await MockAdminChatbotSource(
          latency: Duration.zero,
          scenario: null,
        ).fetch(),
        isNull,
      );
    },
  );
  testWidgets(
    'Loading then all six P2 fields readonly, save disabled, no editor or AI inputs',
    (tester) async {
      viewport(tester);
      await tester.pumpWidget(host(MockAdminChatbotSource()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
      final data = adminChatbotScenarioFixture;
      for (final value in [
        data.topic,
        data.requiredInformation,
        data.limitNotice,
        data.missingInformation,
        data.unableToAnswer,
        'Đang bật',
      ]) {
        expect(find.text(value!), findsOneWidget);
      }
      expect(find.byType(TextField), findsNothing);
      expect(find.byType(Switch), findsNothing);
      expect(tester.widget<FilledButton>(save).onPressed, isNull);
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(SnackBar), findsNothing);
      expect(
        find.text('Dữ liệu minh họa P2 • Chỉ đọc • Chưa kết nối chatbot'),
        findsOneWidget,
      );
    },
  );
  testWidgets('Empty source, missing fields, and false status are distinct', (
    tester,
  ) async {
    viewport(tester);
    await tester.pumpWidget(host(MockAdminChatbotSource(scenario: null)));
    await tester.pumpAndSettle();
    expect(find.text('Chưa có kịch bản chatbot'), findsOneWidget);
    expect(save, findsNothing);
    await tester.pumpWidget(
      host(
        MockAdminChatbotSource(
          scenario: const AdminChatbotScenario(topic: '  '),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Chưa có dữ liệu'), findsNWidgets(6));
    expect(find.text('Đang bật'), findsNothing);
    expect(find.text('Đang tắt'), findsNothing);
    await tester.pumpWidget(
      host(
        MockAdminChatbotSource(
          scenario: const AdminChatbotScenario(enabled: false),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Đang tắt'), findsOneWidget);
    expect(find.text('Chưa có dữ liệu'), findsNWidgets(5));
  });
  testWidgets(
    'Error retry uses same source and displays no fixture while loading',
    (tester) async {
      viewport(tester);
      final source = MockAdminChatbotSource()..failNext = true;
      await tester.pumpWidget(host(source));
      await tester.pumpAndSettle();
      expect(find.text('Không thể tải kịch bản chatbot'), findsOneWidget);
      expect(save, findsNothing);
      await tester.tap(find.text('Thử lại'));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Ước tính số lượng len'), findsNothing);
      await tester.pumpAndSettle();
      expect(find.text('Ước tính số lượng len'), findsOneWidget);
    },
  );
  testWidgets(
    'Source changes hide previous data and ignore late data/errors/disposal',
    (tester) async {
      viewport(tester);
      final old = ControlledChatbot();
      final fresh = ControlledChatbot();
      await tester.pumpWidget(host(old));
      await tester.pumpWidget(host(fresh));
      fresh.result.complete(
        const AdminChatbotScenario(topic: 'Nguồn hiện tại', enabled: false),
      );
      await tester.pumpAndSettle();
      old.result.complete(adminChatbotScenarioFixture);
      await tester.pumpAndSettle();
      expect(find.text('Nguồn hiện tại'), findsOneWidget);
      expect(find.text('Ước tính số lượng len'), findsNothing);
      final error = ControlledChatbot();
      await tester.pumpWidget(host(error));
      await tester.pump();
      expect(find.text('Nguồn hiện tại'), findsNothing);
      final current = ControlledChatbot();
      await tester.pumpWidget(host(current));
      error.result.completeError(StateError('old'));
      current.result.complete(null);
      await tester.pumpAndSettle();
      expect(find.text('Chưa có kịch bản chatbot'), findsOneWidget);
      expect(find.text('Không thể tải kịch bản chatbot'), findsNothing);
      final disposed = ControlledChatbot();
      await tester.pumpWidget(host(disposed));
      await tester.pumpWidget(const SizedBox());
      disposed.result.completeError(StateError('disposed'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'Direct URL guard, injected source, selected submenu, Back and logout',
    (tester) async {
      viewport(tester);
      await tester.pumpWidget(
        const AdminApp(initialRoute: '/conversations/chatbot'),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AdminLoginPage), findsOneWidget);
      expect(find.byType(AdminChatbotPage), findsNothing);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(
        AdminApp(
          initialRoute: '/conversations',
          session: await createSession(),
          chatbotSource: MockAdminChatbotSource(
            scenario: const AdminChatbotScenario(topic: 'Nguồn từ App'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('admin-nav-chatbot')));
      await tester.pumpAndSettle();
      expect(find.byType(AdminChatbotPage), findsOneWidget);
      expect(find.text('Nguồn từ App'), findsOneWidget);
      final submenu = tester.widget<AdminSidebarSubitem>(
        find.ancestor(
          of: find.byKey(const ValueKey('admin-nav-chatbot')),
          matching: find.byType(AdminSidebarSubitem),
        ),
      );
      expect(submenu.active, isTrue);
      expect(
        tester
            .widget<Semantics>(
              find.byKey(const ValueKey('admin-nav-conversations')),
            )
            .properties
            .selected,
        isTrue,
      );
      tester.state<NavigatorState>(find.byType(Navigator)).pop();
      await tester.pumpAndSettle();
      expect(find.byType(AdminConversationsPage), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('admin-nav-chatbot')));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Đăng xuất'));
      await tester.pumpAndSettle();
      expect(find.byType(AdminLoginPage), findsOneWidget);
      expect(find.byType(AdminChatbotPage), findsNothing);
      expect(
        tester.state<NavigatorState>(find.byType(Navigator)).canPop(),
        isFalse,
      );
    },
  );
  for (final width in [390.0, 800.0, 1280.0]) {
    testWidgets(
      'Web $width text120 fields wrap, save reachable and menu navigates',
      (tester) async {
        viewport(tester, width: width);
        tester.platformDispatcher.textScaleFactorTestValue = 1.2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpWidget(
          AdminApp(
            initialRoute: '/conversations/chatbot',
            session: await createSession(),
          ),
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(save);
        await tester.pumpAndSettle();
        final rect = tester.getRect(save);
        expect(rect.left, greaterThanOrEqualTo(0));
        expect(rect.right, lessThanOrEqualTo(width));
        expect(rect.bottom, lessThanOrEqualTo(1300));
        expect(find.byType(TextField), findsNothing);
        if (width < 960) {
          await tester.drag(
            find.byType(SingleChildScrollView).first,
            const Offset(0, 2000),
          );
          await tester.pumpAndSettle();
          await tester.tap(find.byTooltip('Mở menu quản trị'));
          await tester.pumpAndSettle();
          await tester.tap(
            find.byKey(const ValueKey('admin-nav-conversations')),
          );
          await tester.pumpAndSettle();
          expect(find.byType(Drawer), findsNothing);
          expect(find.byType(AdminConversationsPage), findsOneWidget);
        }
        expect(tester.takeException(), isNull);
      },
    );
  }
}
