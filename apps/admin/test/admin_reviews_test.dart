import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_admin/app.dart';
import 'package:lenlab_admin/features/products/presentation/admin_products_content.dart';
import 'package:lenlab_admin/features/auth/presentation/admin_login_page.dart';
import 'package:lenlab_admin/features/reviews/data/admin_reviews_source.dart';
import 'package:lenlab_admin/features/reviews/presentation/admin_reviews_page.dart';
import 'package:lenlab_admin/features/reviews/presentation/widgets/review_card.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

import 'support/admin_test_session.dart';

Widget host(AdminReviewsSource source) => MaterialApp(
  theme: P2.theme(admin: true),
  home: Scaffold(body: AdminReviewsPage(source: source)),
);
void viewport(WidgetTester tester, {double width = 1280, double scale = 1}) {
  tester.view.physicalSize = Size(width, 1700);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

class ControlledReviews implements AdminReviewsSource {
  final queries = <AdminReviewsQuery>[];
  final requests = <Completer<AdminReviewsResult>>[];
  @override
  Future<AdminReviewsResult> fetch(AdminReviewsQuery query) {
    queries.add(query);
    final request = Completer<AdminReviewsResult>();
    requests.add(request);
    return request.future;
  }
}

AdminReviewsResult result([int index = 0]) => AdminReviewsResult(
  items: [adminReviewFixtures[index]],
  total: 1,
  page: 1,
  pendingCount: 2,
);

void main() {
  test(
    'Source combines search, stars, group before paging and clamps page',
    () async {
      final source = MockAdminReviewsSource(latency: Duration.zero);
      final first = await source.fetch(const AdminReviewsQuery());
      final last = await source.fetch(const AdminReviewsQuery(page: 100));
      expect(first.total, 8);
      expect(first.pendingCount, 2);
      expect(first.items.length, 3);
      expect(first.pages, 3);
      expect(first.start, 1);
      expect(first.end, 3);
      expect(last.page, 3);
      expect(last.start, 7);
      expect(last.end, 8);
      expect((await source.fetch(const AdminReviewsQuery(page: -2))).page, 1);
      final matching = await source.fetch(
        const AdminReviewsQuery(
          search: '  MERINO  ',
          stars: 5,
          filter: AdminReviewFilter.withImages,
        ),
      );
      expect(matching.items.single.id, 'REVIEW-P2-001');
      expect(
        (await source.fetch(const AdminReviewsQuery(search: 'TRẦN VĂN BẢO')))
            .items
            .single
            .rating,
        4,
      );
      expect(
        (await source.fetch(
          const AdminReviewsQuery(filter: AdminReviewFilter.pending),
        )).total,
        2,
      );
      final none = await source.fetch(
        const AdminReviewsQuery(filter: AdminReviewFilter.fiveStars, stars: 4),
      );
      expect(none.total, 0);
      expect(none.start, 0);
      expect(none.end, 0);
      expect(() => first.items.clear(), throwsUnsupportedError);
      expect(() => source.reviews.clear(), throwsUnsupportedError);
    },
  );
  testWidgets('Loading, pagination reset, filters combined and clear', (
    tester,
  ) async {
    viewport(tester);
    await tester.pumpWidget(host(MockAdminReviewsSource()));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byType(ReviewCard), findsNWidgets(3));
    expect(find.text('Chờ duyệt (2)'), findsOneWidget);
    await tester.ensureVisible(find.byTooltip('Trang 2'));
    await tester.tap(find.byTooltip('Trang 2'));
    await tester.pumpAndSettle();
    expect(find.text('Khách minh họa 4'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('reviews-search')),
      'merino',
    );
    await tester.pumpAndSettle();
    expect(find.byType(ReviewCard), findsOneWidget);
    expect(find.text('Hiển thị 1-1 trong số 1 đánh giá'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('reviews-stars')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('4 sao'));
    await tester.pumpAndSettle();
    expect(find.text('Không có đánh giá'), findsOneWidget);
    await tester.tap(find.text('Xóa bộ lọc').first);
    await tester.pumpAndSettle();
    expect(find.byType(ReviewCard), findsNWidgets(3));
    await tester.tap(find.byKey(const ValueKey('reviews-filter-pending')));
    await tester.pumpAndSettle();
    expect(find.byType(ReviewCard), findsNWidgets(2));
    await tester.tap(find.byKey(const ValueKey('reviews-filter-withImages')));
    await tester.pumpAndSettle();
    expect(find.byType(ReviewCard), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });
  testWidgets('Empty source, failure and retry keep query and page', (
    tester,
  ) async {
    viewport(tester);
    await tester.pumpWidget(
      host(MockAdminReviewsSource(reviews: [], latency: Duration.zero)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Danh sách đánh giá hiện đang trống.'), findsOneWidget);
    final source = MockAdminReviewsSource(latency: Duration.zero);
    await tester.pumpWidget(host(source));
    await tester.pumpAndSettle();
    source.failNext = true;
    await tester.ensureVisible(find.byTooltip('Trang 2'));
    await tester.tap(find.byTooltip('Trang 2'));
    await tester.pumpAndSettle();
    expect(find.text('Không thể tải đánh giá'), findsOneWidget);
    await tester.tap(find.text('Thử lại'));
    await tester.pumpAndSettle();
    expect(find.text('Hiển thị 4-6 trong số 8 đánh giá'), findsOneWidget);
    source.failNext = true;
    await tester.enterText(find.byKey(const ValueKey('reviews-search')), 'Bảo');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Thử lại'));
    await tester.pumpAndSettle();
    expect(find.text('Trần Văn Bảo'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'Bảo',
    );
  });
  testWidgets('Ignore old success/error and late error after disposal', (
    tester,
  ) async {
    viewport(tester);
    final source = ControlledReviews();
    await tester.pumpWidget(host(source));
    await tester.enterText(find.byKey(const ValueKey('reviews-search')), 'Tú');
    await tester.pump(const Duration(milliseconds: 260));
    source.requests[1].complete(result(2));
    await tester.pumpAndSettle();
    source.requests[0].complete(result(0));
    await tester.pumpAndSettle();
    expect(find.text('Lê Minh Tú'), findsOneWidget);
    expect(find.text('Nguyễn Thị Lan'), findsNothing);
    await tester.enterText(find.byKey(const ValueKey('reviews-search')), 'Lan');
    await tester.pump(const Duration(milliseconds: 260));
    await tester.enterText(find.byKey(const ValueKey('reviews-search')), 'Bảo');
    await tester.pump(const Duration(milliseconds: 260));
    source.requests[3].complete(result(1));
    await tester.pumpAndSettle();
    source.requests[2].completeError(StateError('old'));
    await tester.pumpAndSettle();
    expect(find.text('Trần Văn Bảo'), findsOneWidget);
    expect(find.text('Không thể tải đánh giá'), findsNothing);
    await tester.enterText(
      find.byKey(const ValueKey('reviews-search')),
      'pending',
    );
    await tester.pump(const Duration(milliseconds: 260));
    await tester.pumpWidget(const SizedBox());
    source.requests.last.completeError(StateError('disposed'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
  testWidgets('Source replacement discards old request', (tester) async {
    viewport(tester);
    final old = ControlledReviews();
    await tester.pumpWidget(host(old));
    await tester.pumpWidget(
      host(
        MockAdminReviewsSource(
          reviews: [adminReviewFixtures[1]],
          latency: Duration.zero,
        ),
      ),
    );
    await tester.pumpAndSettle();
    old.requests.single.completeError(StateError('old source'));
    await tester.pumpAndSettle();
    expect(find.text('Trần Văn Bảo'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Moderation disabled and star menu Escape preserves selection', (
    tester,
  ) async {
    viewport(tester);
    await tester.pumpWidget(
      host(MockAdminReviewsSource(latency: Duration.zero)),
    );
    await tester.pumpAndSettle();
    for (final button in tester.widgetList<TextButton>(
      find.descendant(
        of: find.byType(ReviewCard),
        matching: find.byType(TextButton),
      ),
    )) {
      expect(button.onPressed, isNull);
    }
    await tester.tap(find.byKey(const ValueKey('reviews-stars')));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(ReviewCard), findsNWidgets(3));
    expect(find.byType(PopupMenuItem<int>), findsNothing);
  });
  testWidgets('Route guard, sidebar navigation and Back', (tester) async {
    viewport(tester);
    await tester.pumpWidget(const AdminApp(initialRoute: '/reviews'));
    await tester.pumpAndSettle();
    expect(find.byType(AdminLoginPage), findsOneWidget);
    expect(find.byType(AdminReviewsPage), findsNothing);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      AdminApp(initialRoute: '/products', session: await createSession()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('admin-nav-reviews')));
    await tester.pumpAndSettle();
    expect(find.byType(AdminReviewsPage), findsOneWidget);
    expect(
      ModalRoute.of(tester.element(find.byType(AdminReviewsPage)))!
          .settings
          .name,
      '/reviews',
    );
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();
    expect(find.byType(AdminReviewsPage), findsNothing);
    expect(find.byType(AdminProductsContent), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  for (final width in [390.0, 800.0, 1280.0]) {
    testWidgets(
      'Reviews $width text120 scrolls to pagination without overflow',
      (tester) async {
        viewport(tester, width: width, scale: 1.2);
        await tester.pumpWidget(
          AdminApp(initialRoute: '/reviews', session: await createSession()),
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byTooltip('Trang sau'));
        await tester.tap(find.byTooltip('Trang sau'));
        await tester.pumpAndSettle();
        expect(find.text('Khách minh họa 4'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
