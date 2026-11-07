import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_customer/app/customer_app.dart';
import 'package:lenlab_customer/app/customer_scope.dart';
import 'package:lenlab_customer/features/comments/data/comment_source.dart';
import 'package:lenlab_customer/features/comments/presentation/comments_page.dart';
import 'package:lenlab_customer/features/products/presentation/product_unavailable_page.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

void main() {
  test('Mock comments isolate IDs and return immutable results', () async {
    final source = MockCommentSource(
      MockLenlabRepository(latency: Duration.zero),
    );
    final comments = await source.load('merino');
    expect(comments.length, 4);
    expect(comments.where((c) => c.reply != null).length, 1);
    expect(() => comments.clear(), throwsUnsupportedError);
    expect(await source.load('cashmere'), isEmpty);
    expect(await source.load('unknown'), isEmpty);
  });
  testWidgets(
    'Loading, error, retry, change product without leaking comments',
    (tester) async {
      final repo = MockLenlabRepository(
        latency: const Duration(milliseconds: 200),
      );
      repo.failNext('comments');
      final store = LenlabStore(repository: repo);
      Widget app(String id) => CustomerScope(
        store: store,
        child: MaterialApp(
          theme: P2.theme(),
          home: CommentsPage(productId: id),
        ),
      );
      await tester.pumpWidget(app('merino'));
      await tester.pump(const Duration(milliseconds: 20));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('Không tải được bình luận'), findsOneWidget);
      await tester.tap(find.text('Thử lại'));
      await tester.pumpAndSettle();
      expect(find.text('4 bình luận'), findsOneWidget);
      expect(find.text('Len Merino'), findsOneWidget);
      await tester.pumpWidget(app('cashmere'));
      await tester.pumpAndSettle();
      expect(find.text('Chưa có bình luận cho sản phẩm này'), findsOneWidget);
      expect(find.text('Minh Anh'), findsNothing);
    },
  );
  for (final width in [360.0, 390.0, 430.0]) {
    testWidgets('Comments $width text120 read only and scrollable', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final store = LenlabStore(
        repository: MockLenlabRepository(latency: Duration.zero),
      );
      final cart = store.cartCount, orders = store.orders.length;
      await tester.pumpWidget(
        CustomerScope(
          store: store,
          child: MaterialApp(
            theme: P2.theme(),
            home: const CommentsPage(productId: 'merino'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Thêm bình luận...'));
      await tester.pumpAndSettle();
      expect(find.text('Bản dùng thử'), findsOneWidget);
      await tester.tap(find.text('Đóng'));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsNothing);
      await tester.tap(find.byTooltip('Gửi bình luận (chưa hỗ trợ)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Đóng'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Tuấn'), 250);
      await tester.ensureVisible(find.text('Trả lời').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Trả lời').last);
      await tester.pumpAndSettle();
      expect(find.text('Bản dùng thử'), findsOneWidget);
      expect(store.cartCount, cart);
      expect(store.orders.length, orders);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
    'Comments route guards payload and back restores preceding route',
    (tester) async {
      await tester.pumpWidget(
        CustomerApp(
          store: LenlabStore(
            repository: MockLenlabRepository(latency: Duration.zero),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      for (final invalid in [null, '', 42]) {
        navigator.pushNamed('/comments', arguments: invalid);
        await tester.pumpAndSettle();
        expect(find.byType(ProductUnavailablePage), findsOneWidget);
        navigator.pop();
        await tester.pumpAndSettle();
      }
      navigator.pushNamed('/comments', arguments: 'merino');
      await tester.pumpAndSettle();
      expect(find.text('4 bình luận'), findsOneWidget);
      navigator.pop();
      await tester.pumpAndSettle();
      expect(find.byType(CommentsPage), findsNothing);
    },
  );
}
