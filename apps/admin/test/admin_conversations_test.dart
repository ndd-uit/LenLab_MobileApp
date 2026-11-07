import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_admin/app.dart';
import 'package:lenlab_admin/features/auth/presentation/admin_login_page.dart';
import 'package:lenlab_admin/features/conversations/data/admin_conversations_source.dart';
import 'package:lenlab_admin/features/conversations/presentation/admin_conversations_page.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

import 'support/admin_test_session.dart';

void viewport(WidgetTester tester, {double width = 1280, double scale = 1}) {
  tester.view.physicalSize = Size(width, 1300);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

Widget host(AdminConversationsSource source) => MaterialApp(
  theme: P2.theme(admin: true),
  home: Scaffold(
    backgroundColor: const Color(0xFFF3F4F6),
    body: AdminConversationsPage(source: source),
  ),
);
Finder input = find.byKey(const ValueKey('conversation-search'));
Finder selectedName = find.byKey(const ValueKey('conversation-selected-name'));
Finder preview(String id) => find.byKey(ValueKey('conversation-$id'));
const customerMessage =
    'Mình muốn hỏi báo giá 550.000đ đã gồm phí vận chuyển chưa?';

class ControlledConversations implements AdminConversationsSource {
  final result = Completer<List<AdminConversation>>();
  @override
  Future<List<AdminConversation>> fetch() => result.future;
}

void main() {
  test(
    'P2 immutable fixtures, known history only, search semantics and retry',
    () async {
      final source = MockAdminConversationsSource(latency: Duration.zero);
      final items = await source.fetch();
      expect(items.length, 3);
      expect(items.first.messages!.length, 2);
      expect(items[1].messages, isNull);
      expect(items[2].messages, isNull);
      expect(items.first.unreadCount, 2);
      expect(() => items.clear(), throwsUnsupportedError);
      expect(() => items.first.messages!.clear(), throwsUnsupportedError);
      expect(items.first.matches('  cus-202501 '), isTrue);
      expect(items.first.matches('NGUYỄN VĂN A'), isTrue);
      expect(items.first.matches('  '), isTrue);
      expect(items.first.matches('unknown'), isFalse);
      final emailOnly = AdminConversation(
        id: 'email',
        name: 'Mẫu',
        preview: 'Mẫu',
        email: 'sample@example.com',
      );
      expect(emailOnly.matches('EXAMPLE.COM'), isTrue);
      source.failNext = true;
      await expectLater(source.fetch(), throwsStateError);
      expect(await source.fetch(), same(items));
    },
  );
  testWidgets(
    'Loading, exact P2 messages, selection has no invented history or unread mutation',
    (tester) async {
      viewport(tester);
      final source = MockAdminConversationsSource();
      await tester.pumpWidget(host(source));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(selectedName).data, 'Nguyễn Văn A');
      expect(find.text(customerMessage), findsOneWidget);
      await tester.tap(preview('P2-CHAT-002'));
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(selectedName).data, 'Trần Thị Bích');
      expect(find.text(customerMessage), findsNothing);
      expect(find.text('Chưa có dữ liệu nội dung hội thoại'), findsOneWidget);
      expect(find.text('Chưa có dữ liệu trạng thái hỗ trợ'), findsOneWidget);
      await tester.tap(preview('P2-CHAT-003'));
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(selectedName).data, 'Lê Hoàng Cường');
      await tester.tap(preview('P2-CHAT-001'));
      await tester.pumpAndSettle();
      expect(find.text(customerMessage), findsOneWidget);
      expect(source.conversations.first.unreadCount, 2);
      for (final key in ['conversation-send', 'conversation-resolve']) {
        expect(
          tester.widget<FilledButton>(find.byKey(ValueKey(key))).onPressed,
          isNull,
        );
      }
      expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey('conversation-reply')))
            .enabled,
        isFalse,
      );
    },
  );
  testWidgets(
    'Search trimmed name/reference/email, clear no matches, no hidden stale selection',
    (tester) async {
      viewport(tester);
      final sample = AdminConversation(
        id: 'email',
        name: 'Email mẫu',
        preview: 'Hỗ trợ',
        email: 'sample@example.com',
      );
      await tester.pumpWidget(
        host(
          MockAdminConversationsSource(
            conversations: [...adminConversationFixtures, sample],
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(input, ' cus-202501 ');
      await tester.pumpAndSettle();
      expect(preview('P2-CHAT-001'), findsOneWidget);
      expect(preview('P2-CHAT-002'), findsNothing);
      await tester.enterText(input, 'TRẦN THỊ BÍCH');
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(selectedName).data, 'Trần Thị Bích');
      expect(find.text(customerMessage), findsNothing);
      await tester.enterText(input, 'EXAMPLE.COM');
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(selectedName).data, 'Email mẫu');
      await tester.enterText(input, 'not found');
      await tester.pumpAndSettle();
      expect(find.text('Không có hội thoại phù hợp'), findsOneWidget);
      expect(selectedName, findsNothing);
      expect(find.byKey(const ValueKey('conversation-send')), findsNothing);
      await tester.tap(find.byTooltip('Xóa tìm kiếm hội thoại'));
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(selectedName).data, 'Nguyễn Văn A');
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'Source empty differs from missing history and known empty messages',
    (tester) async {
      viewport(tester);
      await tester.pumpWidget(
        host(MockAdminConversationsSource(conversations: [])),
      );
      await tester.pumpAndSettle();
      expect(find.text('Chưa có hội thoại'), findsOneWidget);
      expect(input, findsNothing);
      await tester.pumpWidget(
        host(
          MockAdminConversationsSource(
            conversations: [
              AdminConversation(
                id: 'empty',
                name: 'Trống',
                preview: 'Trống',
                messages: [],
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Hội thoại chưa có tin nhắn'), findsOneWidget);
      expect(find.text('Chưa có dữ liệu nội dung hội thoại'), findsNothing);
    },
  );
  testWidgets(
    'Failure retry restores same source without old content during load',
    (tester) async {
      viewport(tester);
      final source = MockAdminConversationsSource()..failNext = true;
      await tester.pumpWidget(host(source));
      await tester.pumpAndSettle();
      expect(find.text('Không thể tải hội thoại'), findsOneWidget);
      expect(selectedName, findsNothing);
      await tester.tap(find.text('Thử lại'));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text(customerMessage), findsOneWidget);
    },
  );
  testWidgets(
    'Changed source ignores late data/errors and clears stale selection; dispose safe',
    (tester) async {
      viewport(tester);
      final old = ControlledConversations();
      final current = ControlledConversations();
      await tester.pumpWidget(host(old));
      await tester.pumpWidget(host(current));
      current.result.complete([adminConversationFixtures[1]]);
      await tester.pumpAndSettle();
      old.result.complete(adminConversationFixtures);
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(selectedName).data, 'Trần Thị Bích');
      expect(find.text(customerMessage), findsNothing);
      final lateError = ControlledConversations();
      await tester.pumpWidget(host(lateError));
      await tester.pump();
      expect(selectedName, findsNothing);
      final fresh = ControlledConversations();
      await tester.pumpWidget(host(fresh));
      lateError.result.completeError(StateError('old error'));
      fresh.result.complete([adminConversationFixtures[2]]);
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(selectedName).data, 'Lê Hoàng Cường');
      final disposed = ControlledConversations();
      await tester.pumpWidget(host(disposed));
      await tester.pumpWidget(const SizedBox());
      disposed.result.completeError(StateError('disposed'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'Route guard, injected source, sidebar navigation, Back and logout',
    (tester) async {
      viewport(tester);
      await tester.pumpWidget(const AdminApp(initialRoute: '/conversations'));
      await tester.pumpAndSettle();
      expect(find.byType(AdminLoginPage), findsOneWidget);
      expect(find.byType(AdminConversationsPage), findsNothing);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(
        AdminApp(
          session: await createSession(),
          conversationsSource: MockAdminConversationsSource(
            conversations: [adminConversationFixtures[1]],
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('admin-nav-conversations')));
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(selectedName).data, 'Trần Thị Bích');
      expect(
        tester
            .widget<Semantics>(
              find.byKey(const ValueKey('admin-nav-conversations')),
            )
            .properties
            .selected,
        isTrue,
      );
      await tester.tap(find.byKey(const ValueKey('admin-nav-orders')));
      await tester.pumpAndSettle();
      tester.state<NavigatorState>(find.byType(Navigator)).pop();
      await tester.pumpAndSettle();
      expect(find.byType(AdminConversationsPage), findsOneWidget);
      await tester.tap(find.byTooltip('Đăng xuất'));
      await tester.pumpAndSettle();
      expect(find.byType(AdminLoginPage), findsOneWidget);
      expect(find.byType(AdminConversationsPage), findsNothing);
      expect(
        tester.state<NavigatorState>(find.byType(Navigator)).canPop(),
        isFalse,
      );
    },
  );
  for (final width in [390.0, 800.0, 1280.0]) {
    testWidgets('Web $width text120 keyboard, scroll actions and Drawer', (
      tester,
    ) async {
      viewport(tester, width: width, scale: 1.2);
      await tester.pumpWidget(
        AdminApp(
          initialRoute: '/conversations',
          session: await createSession(),
        ),
      );
      await tester.pumpAndSettle();
      if (width < 960) {
        await tester.tap(find.byTooltip('Mở menu quản trị'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('admin-nav-conversations')));
        await tester.pumpAndSettle();
        expect(find.byType(Drawer), findsNothing);
      }
      await tester.enterText(input, 'Trần');
      await tester.pumpAndSettle();
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const ValueKey('conversation-resolve')),
      );
      await tester.pumpAndSettle();
      final rect = tester.getRect(
        find.byKey(const ValueKey('conversation-resolve')),
      );
      expect(rect.bottom, lessThanOrEqualTo(1000));
      expect(rect.left, greaterThanOrEqualTo(0));
      expect(rect.right, lessThanOrEqualTo(width));
      expect(tester.widget<Text>(selectedName).data, 'Trần Thị Bích');
      expect(tester.takeException(), isNull);
    });
  }
}
