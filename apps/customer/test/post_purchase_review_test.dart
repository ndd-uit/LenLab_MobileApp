import 'package:lenlab_customer/features/auth/presentation/auth_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_customer/app/customer_app.dart';
import 'package:lenlab_customer/app/customer_scope.dart';
import 'package:lenlab_customer/features/reviews/presentation/post_purchase_review_page.dart';
import 'package:lenlab_customer/features/reviews/presentation/reviews_page.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

void main() {
  testWidgets('Keyboard form scrolls on 360; back discards unsent draft', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    final s =
        LenlabStore(repository: MockLenlabRepository(latency: Duration.zero))
          ..signedIn = true
          ..coupon = 'LEN50';
    await tester.pumpWidget(CustomerApp(store: s));
    await tester.pumpAndSettle();
    final nav = tester.state<NavigatorState>(find.byType(Navigator));
    nav.pushNamed('/write-review', arguments: s.orders[1].id);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Chưa gửi');
    tester.view.viewInsets = const FakeViewPadding(bottom: 320);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Gửi đánh giá'));
    await tester.pumpAndSettle();
    expect(tester.getRect(find.text('Gửi đánh giá')).bottom, lessThan(480));
    FocusManager.instance.primaryFocus?.unfocus();
    tester.view.resetViewInsets();
    await tester.pumpAndSettle();
    nav.pop();
    await tester.pumpAndSettle();
    expect(s.hasReviewed(s.orders[1].id, 'sheep'), isFalse);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'Open reviews refresh from shared data and changed order loses write access',
    (tester) async {
      final s =
          LenlabStore(repository: MockLenlabRepository(latency: Duration.zero))
            ..signedIn = true
            ..coupon = 'LEN50';
      await tester.pumpWidget(CustomerApp(store: s));
      await tester.pumpAndSettle();
      final nav = tester.state<NavigatorState>(find.byType(Navigator));
      nav.pushNamed('/reviews', arguments: 'sheep');
      await tester.pumpAndSettle();
      expect(find.text('Chưa có đánh giá cho sản phẩm này'), findsOneWidget);
      final save = s.submitProductReview(
        orderId: s.orders[1].id,
        productId: 'sheep',
        rating: 2,
      );
      await tester.pumpAndSettle();
      await save;
      expect(find.text('Nguyễn Văn A'), findsOneWidget);
      expect(find.text('2.0'), findsOneWidget);
      s.orders.first.state = OrderState.delivered;
      nav.pushNamed('/write-review', arguments: s.orders.first.id);
      await tester.pumpAndSettle();
      s.orders.first.state = OrderState.cancelled;
      s.changed();
      await tester.pumpAndSettle();
      expect(find.text('Chưa thể đánh giá'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  for (final width in [360.0, 390.0, 430.0]) {
    testWidgets(
      'Post purchase $width text120 validates, preserves failed draft and saves once',
      (tester) async {
        tester.view.physicalSize = Size(width, 850);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 1.2;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final repo = MockLenlabRepository(
          latency: const Duration(milliseconds: 200),
        );
        final s = LenlabStore(repository: repo)
          ..signedIn = true
          ..coupon = 'LEN50';
        await tester.pumpWidget(CustomerApp(store: s, initialRoute: '/orders'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Đánh giá'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Đánh giá'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Đánh giá'));
        await tester.pumpAndSettle();
        expect(find.byType(PostPurchaseReviewPage), findsOneWidget);
        expect(find.text('Đơn #WOOL-8805'), findsOneWidget);
        expect(find.text('Thú Bông Cừu Handmade Size L'), findsOneWidget);
        await tester.ensureVisible(find.text('Gửi đánh giá'));
        await tester.tap(find.text('Gửi đánh giá'));
        await tester.pumpAndSettle();
        expect(find.text('Vui lòng chọn từ 1 đến 5 sao.'), findsOneWidget);
        await tester.ensureVisible(find.byTooltip('4 sao'));
        await tester.tap(find.byTooltip('4 sao'));
        await tester.enterText(
          find.byType(TextField),
          'Len mềm, đúng sản phẩm đã mua',
        );
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        repo.failNext('submitReview');
        await tester.ensureVisible(find.text('Gửi đánh giá'));
        await tester.tap(find.text('Gửi đánh giá'));
        await tester.pumpAndSettle();
        expect(find.text('Đã gửi đánh giá'), findsNothing);
        expect(
          tester.widget<TextField>(find.byType(TextField)).controller!.text,
          'Len mềm, đúng sản phẩm đã mua',
        );
        await tester.ensureVisible(find.text('Gửi đánh giá'));
        await tester.tap(find.text('Gửi đánh giá'));
        await tester.pump(const Duration(milliseconds: 20));
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        await tester.pumpAndSettle();
        expect(find.text('Đã gửi đánh giá'), findsOneWidget);
        final review = s.reviewsFor('sheep').reviews.single;
        expect(review.orderId, 'WOOL-8805');
        expect(review.rating, 4);
        expect(s.cartCount, 3);
        expect(s.orders.length, 4);
        await tester.ensureVisible(find.text('Về đơn hàng'));
        await tester.tap(find.text('Về đơn hàng'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Đánh giá'));
        await tester.tap(find.text('Đánh giá'));
        await tester.pumpAndSettle();
        expect(find.textContaining('Bạn đã đánh giá'), findsOneWidget);
        expect(find.text('Gửi đánh giá'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'Detail entry carries same order and multi product selection cannot reuse a draft',
    (tester) async {
      final s =
          LenlabStore(repository: MockLenlabRepository(latency: Duration.zero))
            ..signedIn = true
            ..coupon = 'LEN50';
      final order = s.orders.first..state = OrderState.delivered;
      await tester.pumpWidget(CustomerApp(store: s));
      await tester.pumpAndSettle();
      final nav = tester.state<NavigatorState>(find.byType(Navigator));
      nav.pushNamed('/order-detail', arguments: order.id);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Đánh giá'));
      await tester.pumpAndSettle();
      expect(find.text('Đơn #${order.id}'), findsOneWidget);
      await tester.ensureVisible(find.text('Gửi đánh giá'));
      await tester.tap(find.text('Gửi đánh giá'));
      await tester.pumpAndSettle();
      expect(find.text('Vui lòng chọn sản phẩm đã mua.'), findsOneWidget);
      await tester.ensureVisible(find.byType(DropdownButtonFormField<String>));
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text(order.lines.first.product.name).last);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byTooltip('3 sao'));
      await tester.tap(find.byTooltip('3 sao'));
      await tester.enterText(find.byType(TextField), 'Draft áo');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(DropdownButtonFormField<String>));
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text(order.lines.last.product.name).last);
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
      await tester.ensureVisible(find.byTooltip('5 sao'));
      await tester.tap(find.byTooltip('5 sao'));
      await tester.ensureVisible(find.text('Gửi đánh giá'));
      await tester.tap(find.text('Gửi đánh giá'));
      await tester.pumpAndSettle();
      expect(s.reviewsFor('gloves').reviews.single.orderId, order.id);
      expect(s.reviewsFor('sweater').reviews, isEmpty);
      nav.pushNamed('/reviews', arguments: 'gloves');
      await tester.pumpAndSettle();
      expect(find.byType(ReviewsPage), findsOneWidget);
      expect(find.text('Nguyễn Văn A'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'Direct route guards guest, invalid order, empty products and reload failure',
    (tester) async {
      final repo = MockLenlabRepository(
        latency: const Duration(milliseconds: 200),
      );
      final s = LenlabStore(repository: repo);
      Widget app(String id) => CustomerScope(
        store: s,
        child: MaterialApp(
          theme: P2.theme(),
          home: PostPurchaseReviewPage(key: ValueKey(id), orderId: id),
        ),
      );
      await tester.pumpWidget(app('WOOL-8805'));
      await tester.pumpAndSettle();
      expect(find.text('Đăng nhập'), findsOneWidget);
      expect(find.byType(AuthPage), findsOneWidget);
      expect(find.text('Gửi đánh giá'), findsNothing);
      s.signedIn = true;
      s.coupon = 'LEN50';
      await tester.pumpWidget(app('missing'));
      await tester.pumpAndSettle();
      expect(find.text('Chưa thể đánh giá'), findsOneWidget);
      repo.failNext('reviewEligibility');
      await tester.pumpWidget(app('WOOL-8805'));
      await tester.pumpAndSettle();
      expect(find.text('Thử lại'), findsOneWidget);
      await tester.tap(find.text('Thử lại'));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);
      s.orders.add(
        Order(
          ownerId: mockCustomerAId,
          id: 'EMPTY',
          lines: [],
          address: const Address(ownerId: mockCustomerAId),
          state: OrderState.delivered,
        ),
      );
      await tester.pumpWidget(app('EMPTY'));
      await tester.pumpAndSettle();
      expect(find.text('Đơn hàng chưa có sản phẩm'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
