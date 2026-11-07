import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_customer/app/customer_app.dart';
import 'package:lenlab_customer/app/customer_scope.dart';
import 'package:lenlab_customer/features/about/data/about_source.dart';
import 'package:lenlab_customer/features/about/presentation/about_page.dart';
import 'package:lenlab_customer/features/catalog/presentation/catalog_page.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

void main() {
  for (final width in [360.0, 390.0, 430.0]) {
    testWidgets(
      'about $width text120 scrolls timeline above fixed CTA and opens catalog',
      (tester) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
        tester.platformDispatcher.textScaleFactorTestValue = 1.2;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPadding);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final store = LenlabStore(
          repository: MockLenlabRepository(latency: Duration.zero),
        );
        await tester.pumpWidget(
          CustomerApp(store: store, initialRoute: '/about'),
        );
        await tester.pumpAndSettle();
        expect(find.text('SINCE 2021'), findsOneWidget);
        expect(find.text(mockAboutContent.introduction), findsOneWidget);
        final lastText = find.text(
          mockAboutContent.milestones.last.description,
        );
        await tester.ensureVisible(lastText);
        await tester.pumpAndSettle();
        expect(
          tester.getRect(lastText).bottom,
          lessThan(tester.getRect(find.text('Khám phá sản phẩm')).top),
        );
        expect(
          tester.getRect(find.text('Khám phá sản phẩm')).bottom,
          lessThan(876),
        );
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('Khám phá sản phẩm'));
        await tester.pumpAndSettle();
        expect(find.byType(CatalogPage), findsOneWidget);
        expect(store.signedIn, isFalse);
        expect(store.cartCount, 0);
        expect(store.orders, isEmpty);
        expect(store.coupon, isEmpty);
      },
    );
  }

  testWidgets('about load error retries, CTA remains usable', (tester) async {
    final repo = MockLenlabRepository(
      latency: const Duration(milliseconds: 200),
    );
    repo.failNext('about');
    await tester.pumpWidget(
      CustomerApp(
        store: LenlabStore(repository: repo),
        initialRoute: '/about',
      ),
    );
    await tester.pump(const Duration(milliseconds: 20));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Khám phá sản phẩm'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('Không thể tải giới thiệu'), findsOneWidget);
    await tester.tap(find.text('Thử lại'));
    await tester.pumpAndSettle();
    expect(find.text(mockAboutContent.introduction), findsOneWidget);
  });

  testWidgets('missing about content shows empty state and retry', (
    tester,
  ) async {
    await tester.pumpWidget(
      CustomerScope(
        store: LenlabStore(),
        child: MaterialApp(
          theme: P2.theme(),
          home: const AboutPage(source: EmptyAboutSource()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Nội dung giới thiệu đang được cập nhật'), findsOneWidget);
    expect(find.text('SINCE 2021'), findsNothing);
    await tester.tap(find.text('Thử lại'));
    await tester.pumpAndSettle();
    expect(find.text('Nội dung giới thiệu đang được cập nhật'), findsOneWidget);
  });

  testWidgets('drawer about opens page and back returns home', (tester) async {
    await tester.pumpWidget(
      CustomerApp(
        store: LenlabStore(
          repository: MockLenlabRepository(latency: Duration.zero),
        ),
      ),
    );
    await tester.pumpAndSettle();
    tester.state<ScaffoldState>(find.byType(Scaffold).first).openDrawer();
    await tester.pumpAndSettle();
    final aboutLink = find.descendant(
      of: find.byType(Drawer),
      matching: find.text('Về chúng tôi'),
    );
    await tester.scrollUntilVisible(
      aboutLink,
      150,
      scrollable: find
          .descendant(
            of: find.byType(Drawer),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(aboutLink);
    await tester.pumpAndSettle();
    expect(find.byType(AboutPage), findsOneWidget);
    await tester.tap(find.byTooltip('Quay lại'));
    await tester.pumpAndSettle();
    expect(find.byType(AboutPage), findsNothing);
  });

  testWidgets('home footer about link opens public introduction', (
    tester,
  ) async {
    await tester.pumpWidget(
      CustomerApp(
        store: LenlabStore(
          repository: MockLenlabRepository(latency: Duration.zero),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Về chúng tôi'));
    await tester.tap(find.text('Về chúng tôi'));
    await tester.pumpAndSettle();
    expect(find.byType(AboutPage), findsOneWidget);
    expect(find.text(mockAboutContent.vision), findsOneWidget);
  });
}

class EmptyAboutSource implements AboutSource {
  const EmptyAboutSource();
  @override
  Future<AboutContent?> load() async => null;
}
