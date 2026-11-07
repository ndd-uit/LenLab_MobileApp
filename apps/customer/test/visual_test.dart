import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_customer/app/customer_app.dart';
import 'package:lenlab_customer/app/customer_scope.dart';
import 'package:lenlab_customer/features/auth/presentation/login_layout.dart';
import 'package:lenlab_customer/features/products/presentation/product_detail_page.dart';
import 'package:lenlab_customer/features/home/presentation/home_page.dart';
import 'package:lenlab_customer/features/checkout/presentation/cod_success_page.dart';
import 'package:lenlab_customer/features/orders/presentation/order_detail_page.dart';
import 'package:lenlab_customer/features/orders/presentation/order_list_page.dart';
import 'package:lenlab_shared/lenlab_shared.dart';
import 'package:lenlab_customer/features/address_book/presentation/address_editor_page.dart';
import 'package:lenlab_customer/features/profile/presentation/profile_editor_page.dart';
import 'package:lenlab_customer/features/help/presentation/faq_page.dart';
import 'package:lenlab_customer/features/about/presentation/about_page.dart';
import 'package:lenlab_customer/features/reviews/presentation/reviews_page.dart';
import 'package:lenlab_customer/features/comments/presentation/comments_page.dart';
import 'package:lenlab_customer/features/reviews/presentation/post_purchase_review_page.dart';
import 'package:lenlab_customer/shared/navigation/customer_drawer.dart';
import 'package:lenlab_customer/features/reviews/data/review_photo_picker.dart';

class PreviewReviewPhotos implements ReviewPhotoPicker {
  PreviewReviewPhotos(this.photos);
  final List<ReviewPhoto> photos;
  @override
  Future<List<ReviewPhoto>> pick({required int remaining}) async => photos;
}

LenlabStore visualStore({LenlabRepository? repository}) {
  final store = LenlabStore(repository: repository);
  final catalog = (store.repository as MockLenlabRepository).catalog;
  store.addToCart(
    catalog.firstWhere((p) => p.id == 'sweater'),
    1,
    'Xanh \u0111\u1eadm \u00b7 Size M',
  );
  store.addToCart(
    catalog.firstWhere((p) => p.id == 'gloves'),
    2,
    'Xám · Size S',
  );
  store.coupon = 'LEN50';
  return store;
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    for (final font in {
      'BeVietnamPro': 'BeVietnamPro-Regular.ttf',
      'PlayfairDisplay': 'PlayfairDisplay.ttf',
      'Bangers': 'Bangers.ttf',
      'Cousine': 'Cousine-Bold.ttf',
    }.entries) {
      final loader = FontLoader('packages/lenlab_shared/${font.key}');
      loader.addFont(
        rootBundle.load('packages/lenlab_shared/assets/fonts/${font.value}'),
      );
      if (font.key == 'BeVietnamPro') {
        loader.addFont(
          rootBundle.load(
            'packages/lenlab_shared/assets/fonts/BeVietnamPro-Bold.ttf',
          ),
        );
        loader.addFont(
          rootBundle.load(
            'packages/lenlab_shared/assets/fonts/BeVietnamPro-SemiBold.ttf',
          ),
        );
      }
      await loader.load();
    }
    final icons = FontLoader('MaterialIcons');
    icons.addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });
  for (final width in [390.0, 360.0]) {
    testWidgets('Review photo attachments $width render', (tester) async {
      tester.view.physicalSize = Size(width, width == 390 ? 1300 : 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      if (width == 360) {
        tester.platformDispatcher.textScaleFactorTestValue = 1.2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      }
      final image = await rootBundle.load(
        'packages/lenlab_shared/assets/figma/6c7f8.png',
      );
      final picker = PreviewReviewPhotos([
        ReviewPhoto(
          name: 'scarf.png',
          bytes: image.buffer.asUint8List(
            image.offsetInBytes,
            image.lengthInBytes,
          ),
        ),
      ]);
      final store =
          visualStore(repository: MockLenlabRepository(latency: Duration.zero))
            ..signedIn = true
            ..coupon = 'LEN50';
      await tester.pumpWidget(
        CustomerScope(
          store: store,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: P2.theme(),
            home: PostPurchaseReviewPage(
              orderId: 'WOOL-8805',
              photoPicker: picker,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('5 sao'));
      final button = find.byKey(const ValueKey('review-add-photos'));
      await tester.ensureVisible(button);
      await tester.runAsync(() async {
        tester.widget<OutlinedButton>(button).onPressed!();
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        final context = tester.element(find.byType(Scaffold));
        await Future.wait(
          tester
              .widgetList<Image>(find.byType(Image))
              .map((image) => precacheImage(image.image, context)),
        );
      });
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile(
          'goldens/review-photos-${width.toInt()}${width == 360 ? '-text120' : ''}.png',
        ),
      );
    });
  }
  for (final width in [390.0, 360.0]) {
    testWidgets('Local avatar preview $width render', (tester) async {
      tester.view.physicalSize = Size(width, width == 390 ? 1200 : 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      if (width == 360) {
        tester.platformDispatcher.textScaleFactorTestValue = 1.2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      }
      // Explicit test image; runtime never auto-assigns this picture to users.
      final data = await rootBundle.load(
        'packages/lenlab_shared/assets/figma/00fc5.png',
      );
      final store =
          visualStore(repository: MockLenlabRepository(latency: Duration.zero))
            ..signedIn = true
            ..coupon = 'LEN50';
      store.profile.avatarBytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      await tester.pumpWidget(
        CustomerScope(
          store: store,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: P2.theme(),
            home: const ProfileEditorPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        final context = tester.element(find.byType(Scaffold));
        await Future.wait(
          tester
              .widgetList<Image>(find.byType(Image))
              .map((image) => precacheImage(image.image, context)),
        );
      });
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile(
          'goldens/avatar-preview-${width.toInt()}${width == 360 ? '-text120' : ''}.png',
        ),
      );
    });
  }
  for (final width in [390.0, 360.0]) {
    testWidgets('Merino variant sheet $width render', (tester) async {
      tester.view.physicalSize = Size(width, 884);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      if (width == 360) {
        tester.platformDispatcher.textScaleFactorTestValue = 1.2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      }
      final repo = MockLenlabRepository(latency: Duration.zero);
      await tester.pumpWidget(
        CustomerScope(
          store: visualStore(repository: repo),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: P2.theme(),
            home: ProductDetailPage(
              product: repo.catalog.firstWhere((p) => p.id == 'merino'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Thêm vào giỏ'));
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        final context = tester.element(find.byType(Scaffold));
        await Future.wait(
          tester
              .widgetList<Image>(find.byType(Image))
              .map((image) => precacheImage(image.image, context)),
        );
      });
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
          'goldens/merino-variant-${width.toInt()}${width == 360 ? '-text120' : ''}.png',
        ),
      );
    });
  }
  for (final width in [390.0, 360.0]) {
    testWidgets('Address deletion confirmation $width render', (tester) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      if (width == 360) {
        tester.platformDispatcher.textScaleFactorTestValue = 1.2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      }
      final store =
          visualStore(repository: MockLenlabRepository(latency: Duration.zero))
            ..signedIn = true
            ..coupon = 'LEN50';
      store.addresses.add(
        const Address(
          ownerId: mockCustomerAId,
          name: 'Trần Thị B',
          street: '456 Đường Mới',
          isDefault: false,
        ),
      );
      await tester.pumpWidget(
        CustomerApp(store: store, initialRoute: '/addresses'),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Xóa'));
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        final context = tester.element(find.byType(Scaffold));
        await Future.wait(
          tester
              .widgetList<Image>(find.byType(Image))
              .map((image) => precacheImage(image.image, context)),
        );
      });
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
          'goldens/address-delete-${width.toInt()}${width == 360 ? '-text120' : ''}.png',
        ),
      );
    });
  }
  for (final width in [390.0, 360.0]) {
    testWidgets('Buy again picker $width render', (tester) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      if (width == 360) {
        tester.platformDispatcher.textScaleFactorTestValue = 1.2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      }
      final repo = MockLenlabRepository(latency: Duration.zero);
      repo.catalog[1].stock = 0;
      final store = visualStore(repository: repo)
        ..signedIn = true
        ..coupon = 'LEN50';
      store.orders
        ..clear()
        ..add(
          Order(
            ownerId: mockCustomerAId,
            id: 'WOOL-8805',
            lines: [CartLine(repo.catalog.first), CartLine(repo.catalog[1])],
            address: const Address(ownerId: mockCustomerAId),
            state: OrderState.delivered,
          ),
        );
      await tester.pumpWidget(
        CustomerApp(store: store, initialRoute: '/orders'),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mua lại'));
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        final context = tester.element(find.byType(Scaffold));
        await Future.wait(
          tester
              .widgetList<Image>(find.byType(Image))
              .map((image) => precacheImage(image.image, context)),
        );
      });
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
          'goldens/buy-again-${width.toInt()}${width == 360 ? '-text120' : ''}.png',
        ),
      );
    });
  }
  for (final none in [false, true]) {
    testWidgets('Cart selection ${none ? 'none' : 'partial'} render', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store =
          visualStore(repository: MockLenlabRepository(latency: Duration.zero))
            ..signedIn = true
            ..coupon = 'LEN50';
      store.toggleCartLine(store.cart.first);
      if (none) store.toggleCartLine(store.cart.last);
      await tester.pumpWidget(CustomerApp(store: store, initialRoute: '/cart'));
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        final context = tester.element(find.byType(Scaffold));
        await Future.wait(
          tester
              .widgetList<Image>(find.byType(Image))
              .map((image) => precacheImage(image.image, context)),
        );
      });
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile(
          'goldens/cart-selection-${none ? 'none' : 'partial'}.png',
        ),
      );
    });
  }
  for (final width in [390.0, 360.0]) {
    testWidgets('P2 guest cart $width render', (tester) async {
      final shadows = debugDisableShadows;
      try {
        debugDisableShadows = false;
        tester.view.physicalSize = Size(width, 884);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        if (width == 360) {
          tester.platformDispatcher.textScaleFactorTestValue = 1.2;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        }
        await tester.pumpWidget(
          CustomerApp(
            initialRoute: '/cart',
            store: visualStore(
              repository: MockLenlabRepository(latency: Duration.zero),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.runAsync(() async {
          final context = tester.element(find.byType(Navigator));
          await Future.wait(
            tester
                .widgetList<Image>(find.byType(Image))
                .map((img) => precacheImage(img.image, context)),
          );
        });
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await expectLater(
          find.byType(Navigator),
          matchesGoldenFile(
            'goldens/cart-guest${width == 360 ? '-360-text120' : ''}.png',
          ),
        );
      } finally {
        debugDisableShadows = shadows;
      }
    });
  }
  for (final width in [390.0, 360.0]) {
    testWidgets('Post purchase review form $width render', (tester) async {
      final oldShadows = debugDisableShadows;
      try {
        debugDisableShadows = false;
        tester.view.physicalSize = Size(width, width == 390 ? 1000 : 1200);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        if (width == 360) {
          tester.platformDispatcher.textScaleFactorTestValue = 1.2;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        }
        final store =
            visualStore(
                repository: MockLenlabRepository(latency: Duration.zero),
              )
              ..signedIn = true
              ..coupon = 'LEN50';
        await tester.pumpWidget(
          CustomerScope(
            store: store,
            child: MaterialApp(
              theme: P2.theme(),
              home: PostPurchaseReviewPage(orderId: store.orders[1].id),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('4 sao'));
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
            'goldens/write-review${width == 360 ? '-360-text120' : ''}.png',
          ),
        );
      } finally {
        debugDisableShadows = oldShadows;
      }
    });
  }
  for (final width in [390.0, 360.0]) {
    testWidgets('P2 Comments $width render', (tester) async {
      final previousShadows = debugDisableShadows;
      try {
        debugDisableShadows = false;
        tester.view.physicalSize = Size(width, width == 390 ? 1160 : 1800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        if (width == 360) {
          tester.platformDispatcher.textScaleFactorTestValue = 1.2;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        }
        await tester.pumpWidget(
          CustomerScope(
            store: visualStore(
              repository: MockLenlabRepository(latency: Duration.zero),
            ),
            child: MaterialApp(
              theme: P2.theme(),
              home: const CommentsPage(productId: 'merino'),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.runAsync(() async {
          final context = tester.element(find.byType(CommentsPage));
          await Future.wait(
            tester
                .widgetList<Image>(find.byType(Image))
                .map((image) => precacheImage(image.image, context)),
          );
        });
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile(
            'goldens/comments${width == 360 ? '-360-text120' : ''}.png',
          ),
        );
      } finally {
        debugDisableShadows = previousShadows;
      }
    });
  }
  for (final width in [390.0, 360.0]) {
    for (final signedIn in [false, true]) {
      testWidgets('P2 Drawer $width ${signedIn ? 'member' : 'guest'} render', (
        tester,
      ) async {
        final previousShadows = debugDisableShadows;
        try {
          debugDisableShadows = false;
          tester.view.physicalSize = Size(width, 863);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          if (width == 360) {
            tester.platformDispatcher.textScaleFactorTestValue = 1.2;
            addTearDown(
              tester.platformDispatcher.clearTextScaleFactorTestValue,
            );
          }
          final store = visualStore(
            repository: MockLenlabRepository(latency: Duration.zero),
          )..signedIn = signedIn;
          if (signedIn) {
            store.profile.avatar = 'c0c7e.png';
          }
          await tester.pumpWidget(CustomerApp(store: store));
          await tester.pumpAndSettle();
          await tester.tap(find.byTooltip('Mở menu'));
          await tester.pumpAndSettle();
          await tester.runAsync(() async {
            final context = tester.element(find.byType(CustomerDrawer));
            await Future.wait(
              tester
                  .widgetList<Image>(find.byType(Image))
                  .map((image) => precacheImage(image.image, context)),
            );
          });
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await expectLater(
            find.byType(Scaffold).last,
            matchesGoldenFile(
              'goldens/drawer-${signedIn ? 'member' : 'guest'}${width == 360 ? '-360-text120' : ''}.png',
            ),
          );
        } finally {
          debugDisableShadows = previousShadows;
        }
      });
    }
  }
  for (final width in [390.0, 360.0]) {
    testWidgets('P2 Reviews $width render', (tester) async {
      final previousShadows = debugDisableShadows;
      try {
        debugDisableShadows = false;
        tester.view.physicalSize = Size(width, width == 390 ? 1500 : 2000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        if (width == 360) {
          tester.platformDispatcher.textScaleFactorTestValue = 1.2;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        }
        await tester.pumpWidget(
          CustomerScope(
            store: visualStore(
              repository: MockLenlabRepository(latency: Duration.zero),
            ),
            child: MaterialApp(
              theme: P2.theme(),
              home: const ReviewsPage(productId: 'merino'),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.runAsync(() async {
          final context = tester.element(find.byType(ReviewsPage));
          await Future.wait(
            tester
                .widgetList<Image>(find.byType(Image))
                .map((image) => precacheImage(image.image, context)),
          );
        });
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile(
            width == 390
                ? 'goldens/reviews.png'
                : 'goldens/reviews-360-text120.png',
          ),
        );
      } finally {
        debugDisableShadows = previousShadows;
      }
    });
  }
  for (final width in [390.0, 360.0]) {
    testWidgets('P2 About $width render', (tester) async {
      final previousShadows = debugDisableShadows;
      try {
        debugDisableShadows = false;
        tester.view.physicalSize = Size(width, width == 390 ? 1700 : 2200);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        if (width == 360) {
          tester.platformDispatcher.textScaleFactorTestValue = 1.2;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        }
        await tester.pumpWidget(
          CustomerScope(
            store: visualStore(
              repository: MockLenlabRepository(latency: Duration.zero),
            ),
            child: MaterialApp(theme: P2.theme(), home: const AboutPage()),
          ),
        );
        await tester.pumpAndSettle();
        await tester.runAsync(() async {
          final context = tester.element(find.byType(AboutPage));
          await Future.wait(
            tester
                .widgetList<Image>(find.byType(Image))
                .map((image) => precacheImage(image.image, context)),
          );
        });
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile(
            width == 390
                ? 'goldens/about.png'
                : 'goldens/about-360-text120.png',
          ),
        );
      } finally {
        debugDisableShadows = previousShadows;
      }
    });
  }
  for (final width in [390.0, 360.0]) {
    testWidgets('P2 FAQ $width render', (tester) async {
      final previousShadows = debugDisableShadows;
      try {
        debugDisableShadows = false;
        tester.view.physicalSize = Size(width, width == 390 ? 1200 : 1550);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        if (width == 360) {
          tester.platformDispatcher.textScaleFactorTestValue = 1.2;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        }
        final store = visualStore(
          repository: MockLenlabRepository(latency: Duration.zero),
        );
        await tester.pumpWidget(
          CustomerScope(
            store: store,
            child: MaterialApp(theme: P2.theme(), home: const FaqPage()),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile(
            width == 390 ? 'goldens/faq.png' : 'goldens/faq-360-text120.png',
          ),
        );
      } finally {
        debugDisableShadows = previousShadows;
      }
    });
  }
  for (final width in [390.0, 360.0]) {
    testWidgets('P2 profile editor $width render', (tester) async {
      final previousShadows = debugDisableShadows;
      try {
        debugDisableShadows = false;
        tester.view.physicalSize = Size(width, width == 390 ? 1150 : 1450);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        if (width == 360) {
          tester.platformDispatcher.textScaleFactorTestValue = 1.2;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        }
        final store =
            visualStore(
                repository: MockLenlabRepository(latency: Duration.zero),
              )
              ..signedIn = true
              ..coupon = 'LEN50';
        store.profile.avatar = '00fc5.png';
        await tester.pumpWidget(
          CustomerScope(
            store: store,
            child: MaterialApp(
              theme: P2.theme(),
              home: const ProfileEditorPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.runAsync(() async {
          final context = tester.element(find.byType(Scaffold));
          await Future.wait([
            for (final image in tester.widgetList<Image>(find.byType(Image)))
              precacheImage(image.image, context),
          ]);
        });
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile(
            width == 390
                ? 'goldens/profile-editor.png'
                : 'goldens/profile-editor-360-text120.png',
          ),
        );
      } finally {
        debugDisableShadows = previousShadows;
      }
    });
  }
  for (final width in [390.0, 360.0]) {
    testWidgets('P2 vouchers $width render', (tester) async {
      final previousShadows = debugDisableShadows;
      try {
        debugDisableShadows = false;
        tester.view.physicalSize = Size(width, width == 390 ? 1050 : 1550);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        if (width == 360) {
          tester.platformDispatcher.textScaleFactorTestValue = 1.2;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        }
        final store =
            visualStore(
                repository: MockLenlabRepository(latency: Duration.zero),
              )
              ..signedIn = true
              ..coupon = 'LEN50';
        await tester.pumpWidget(
          CustomerApp(store: store, initialRoute: '/vouchers'),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await expectLater(
          find.byType(Scaffold).last,
          matchesGoldenFile(
            width == 390
                ? 'goldens/vouchers.png'
                : 'goldens/vouchers-360-text120.png',
          ),
        );
      } finally {
        debugDisableShadows = previousShadows;
      }
    });
  }
  for (final width in [390.0, 360.0]) {
    testWidgets('P2 address editor $width render', (tester) async {
      tester.view.physicalSize = Size(width, width == 390 ? 1100 : 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      if (width == 360) {
        tester.platformDispatcher.textScaleFactorTestValue = 1.2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      }
      final store =
          visualStore(repository: MockLenlabRepository(latency: Duration.zero))
            ..signedIn = true
            ..coupon = 'LEN50';
      await tester.pumpWidget(
        CustomerScope(
          store: store,
          child: MaterialApp(
            theme: P2.theme(),
            home: const AddressEditorPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile(
          width == 390
              ? 'goldens/address-editor.png'
              : 'goldens/address-editor-360-text120.png',
        ),
      );
    });
  }
  for (final width in [390.0, 360.0]) {
    testWidgets('P2 address book $width render', (tester) async {
      final previousShadows = debugDisableShadows;
      try {
        debugDisableShadows = false;
        tester.view.physicalSize = Size(width, width == 390 ? 884 : 1150);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        if (width == 360) {
          tester.platformDispatcher.textScaleFactorTestValue = 1.2;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        }
        final store =
            visualStore(
                repository: MockLenlabRepository(latency: Duration.zero),
              )
              ..signedIn = true
              ..coupon = 'LEN50';
        store.addresses
          ..clear()
          ..addAll(const [
            Address(
              ownerId: mockCustomerAId,
              street: '123 Đường Len',
              ward: 'Phường 1',
            ),
            Address(
              ownerId: mockCustomerAId,
              name: 'Trần Thị B',
              phone: '0912345678',
              street: '456 Ngõ Hẻm',
              ward: 'Phường 2',
              district: 'Quận 3',
              isDefault: false,
            ),
            Address(
              ownerId: mockCustomerAId,
              name: 'Lê Văn C',
              phone: '0987654321',
              street: '789 Khu Phố',
              ward: 'Phường 5',
              district: 'Quận Gò Vấp',
              isDefault: false,
            ),
          ]);
        await tester.pumpWidget(
          CustomerApp(store: store, initialRoute: '/addresses'),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await expectLater(
          find.byType(Scaffold).last,
          matchesGoldenFile(
            width == 390
                ? 'goldens/address-book.png'
                : 'goldens/address-book-360-text120.png',
          ),
        );
      } finally {
        debugDisableShadows = previousShadows;
      }
    });
  }
  for (final width in [390.0, 360.0]) {
    testWidgets('P2 profile $width render', (tester) async {
      final previousShadows = debugDisableShadows;
      try {
        debugDisableShadows = false;
        tester.view.physicalSize = Size(width, width == 390 ? 1018 : 1250);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        if (width == 360) {
          tester.platformDispatcher.textScaleFactorTestValue = 1.2;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        }
        final store =
            visualStore(
                repository: MockLenlabRepository(latency: Duration.zero),
              )
              ..signedIn = true
              ..coupon = 'LEN50';
        await tester.pumpWidget(
          CustomerApp(store: store, initialRoute: '/profile'),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await expectLater(
          find.byType(Scaffold).last,
          matchesGoldenFile(
            width == 390
                ? 'goldens/profile.png'
                : 'goldens/profile-360-text120.png',
          ),
        );
      } finally {
        debugDisableShadows = previousShadows;
      }
    });
  }
  for (final large in [false, true]) {
    testWidgets('P2 order list ${large ? '360 text120' : '390'} render', (
      tester,
    ) async {
      final previousShadows = debugDisableShadows;
      try {
        debugDisableShadows = false;
        tester.view.physicalSize = Size(large ? 360 : 390, large ? 2050 : 1750);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        if (large) {
          tester.platformDispatcher.textScaleFactorTestValue = 1.2;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        }
        final store =
            visualStore(
                repository: MockLenlabRepository(latency: Duration.zero),
              )
              ..signedIn = true
              ..coupon = 'LEN50';
        await tester.pumpWidget(
          CustomerScope(
            store: store,
            child: MaterialApp(theme: P2.theme(), home: const OrderListPage()),
          ),
        );
        await tester.pumpAndSettle();
        await tester.runAsync(() async {
          final context = tester.element(find.byType(Scaffold));
          await Future.wait([
            for (final image in tester.widgetList<Image>(find.byType(Image)))
              precacheImage(image.image, context),
          ]);
        });
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile(
            large
                ? 'goldens/order-list-360-text120.png'
                : 'goldens/order-list.png',
          ),
        );
        if (!large) {
          final price = tester.getRect(find.text('250.000đ'));
          final buyAgain = tester.getRect(find.text('Mua lại'));
          final review = tester.getRect(find.text('Đánh giá'));
          expect(price.top, lessThan(review.bottom));
          expect(price.bottom, greaterThan(review.top));
          expect((buyAgain.center.dy - review.center.dy).abs(), lessThan(1));
          expect(review.left, greaterThan(price.right));
        }
      } finally {
        debugDisableShadows = previousShadows;
      }
    });
  }
  for (final route in [
    '/login',
    '/products',
    '/cart',
    '/checkout',
    '/order-review',
    '/payment-method',
    '/bank-transfer',
    '/',
  ]) {
    testWidgets('P2 render $route', (tester) async {
      final previousShadows = debugDisableShadows;
      try {
        if (route == '/login' ||
            route == '/' ||
            route == '/cart' ||
            route == '/checkout' ||
            route == '/order-review' ||
            route == '/payment-method' ||
            route == '/bank-transfer') {
          debugDisableShadows = false;
        }
        tester.view.physicalSize = Size(
          390,
          route == '/products'
              ? 1360
              : route == '/checkout'
              ? 929
              : route == '/order-review'
              ? 1074
              : route == '/payment-method'
              ? 886
              : route == '/bank-transfer'
              ? 960
              : 895,
        );
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          CustomerApp(
            initialRoute: route,
            store:
                visualStore(
                    repository: MockLenlabRepository(latency: Duration.zero),
                  )
                  ..signedIn = !['/', '/products', '/login'].contains(route)
                  ..coupon = 'LEN50'
                  ..deliveryAddress =
                      route == '/order-review' ||
                          route == '/payment-method' ||
                          route == '/bank-transfer'
                      ? const Address(ownerId: mockCustomerAId)
                      : null
                  ..bankTransferReference = route == '/bank-transfer'
                      ? 'WOOL8823'
                      : null,
          ),
        );
        await tester.pumpAndSettle();
        await tester.runAsync(() async {
          final context = tester.element(find.byType(Scaffold).last);
          await Future.wait([
            for (final image in tester.widgetList<Image>(find.byType(Image)))
              precacheImage(image.image, context),
          ]);
        });
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final name = route == '/' ? 'home' : route.substring(1);
        await expectLater(
          find.byType(Scaffold).last,
          matchesGoldenFile('goldens/$name.png'),
        );
      } finally {
        debugDisableShadows = previousShadows;
      }
    });
  }
  testWidgets('P2 bank transfer 360 text120 render', (tester) async {
    tester.view.physicalSize = const Size(360, 1150);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final previousShadows = debugDisableShadows;
    try {
      debugDisableShadows = false;
      final store =
          visualStore(repository: MockLenlabRepository(latency: Duration.zero))
            ..signedIn = true
            ..coupon = 'LEN50'
            ..deliveryAddress = const Address(ownerId: mockCustomerAId)
            ..bankTransferReference = 'WOOL8823';
      await tester.pumpWidget(
        CustomerApp(initialRoute: '/bank-transfer', store: store),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(Scaffold).last,
        matchesGoldenFile('goldens/bank-transfer-360-text120.png'),
      );
    } finally {
      debugDisableShadows = previousShadows;
    }
  });
  for (final largeText in [false, true]) {
    testWidgets(
      largeText
          ? 'P2 order detail 360 text120 render'
          : 'P2 order detail render',
      (tester) async {
        tester.view.physicalSize = Size(
          largeText ? 360 : 390,
          largeText ? 1500 : 1229,
        );
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final previousShadows = debugDisableShadows;
        try {
          debugDisableShadows = false;
          final store =
              visualStore(
                  repository: MockLenlabRepository(latency: Duration.zero),
                )
                ..signedIn = true
                ..coupon = 'LEN50';
          final fixture = store.orders.first;
          // P2 2009 shows this order before confirmation; the live seed remains shipping.
          store.orders[0] = Order(
            ownerId: mockCustomerAId,
            id: fixture.id,
            lines: fixture.lines,
            address: fixture.address,
            discount: fixture.discount,
            shipping: fixture.shipping,
            createdAt: DateTime(2023, 10, 20, 10),
            deliveryEstimate: '3 ngày tới',
          );
          await tester.pumpWidget(
            CustomerScope(
              store: store,
              child: MaterialApp(
                theme: P2.theme(),
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(largeText ? 1.2 : 1),
                  ),
                  child: child!,
                ),
                home: OrderDetailPage(orderId: fixture.id),
              ),
            ),
          );
          await tester.pumpAndSettle();
          await tester.runAsync(() async {
            final context = tester.element(find.byType(Scaffold));
            await Future.wait([
              for (final image in tester.widgetList<Image>(find.byType(Image)))
                precacheImage(image.image, context),
            ]);
          });
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await expectLater(
            find.byType(Scaffold),
            matchesGoldenFile(
              largeText
                  ? 'goldens/order-detail-360-text120.png'
                  : 'goldens/order-detail.png',
            ),
          );
        } finally {
          debugDisableShadows = previousShadows;
        }
      },
    );
  }
  for (final largeText in [false, true]) {
    testWidgets(
      largeText ? 'P2 COD success 360 text120 render' : 'P2 COD success render',
      (tester) async {
        tester.view.physicalSize = Size(
          largeText ? 360 : 390,
          largeText ? 1250 : 957,
        );
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final previousShadows = debugDisableShadows;
        try {
          debugDisableShadows = false;
          final store =
              visualStore(
                  repository: MockLenlabRepository(latency: Duration.zero),
                )
                ..signedIn = true
                ..coupon = 'LEN50';
          await tester.pumpWidget(
            CustomerScope(
              store: store,
              child: MaterialApp(
                theme: P2.theme(),
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(largeText ? 1.2 : 1),
                  ),
                  child: child!,
                ),
                home: CodSuccessPage(order: store.orders.first),
              ),
            ),
          );
          await tester.pumpAndSettle();
          await tester.runAsync(() async {
            final context = tester.element(find.byType(Scaffold));
            await Future.wait([
              for (final image in tester.widgetList<Image>(find.byType(Image)))
                precacheImage(image.image, context),
            ]);
          });
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await expectLater(
            find.byType(Scaffold),
            matchesGoldenFile(
              largeText
                  ? 'goldens/cod-success-360-text120.png'
                  : 'goldens/cod-success.png',
            ),
          );
        } finally {
          debugDisableShadows = previousShadows;
        }
      },
    );
  }
  testWidgets('P2 home full page render', (tester) async {
    tester.view.physicalSize = const Size(390, 2405);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final previousShadows = debugDisableShadows;
    try {
      debugDisableShadows = false;
      // Freeze only the visual fixture; runtime resolves the current year.
      await tester.pumpWidget(
        CustomerScope(
          store: visualStore(),
          child: MaterialApp(
            theme: P2.theme(),
            home: const HomePage(copyrightYear: 2026),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        final context = tester.element(find.byType(Scaffold).last);
        await Future.wait([
          for (final image in tester.widgetList<Image>(find.byType(Image)))
            precacheImage(image.image, context),
        ]);
      });
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final fullHeight =
          tester.getSize(find.byType(HomeContent)).height + 66.13;
      tester.view.physicalSize = Size(390, fullHeight.ceilToDouble());
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(Scaffold).last,
        matchesGoldenFile('goldens/home-full.png'),
      );
    } finally {
      debugDisableShadows = previousShadows;
    }
  });
  for (final state in ['error', 'loading']) {
    testWidgets('P2 login $state render', (tester) async {
      tester.view.physicalSize = Size(390, state == 'error' ? 937 : 895);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final identity = TextEditingController(),
          password = TextEditingController();
      addTearDown(identity.dispose);
      addTearDown(password.dispose);
      final previousShadows = debugDisableShadows;
      try {
        debugDisableShadows = false;
        await tester.pumpWidget(
          MaterialApp(
            theme: P2.theme(),
            home: LoginLayout(
              formKey: GlobalKey<FormState>(),
              identity: identity,
              password: password,
              hidden: true,
              busy: state == 'loading',
              error: state == 'error'
                  ? 'Email/số điện thoại hoặc mật khẩu chưa đúng. Vui lòng kiểm tra và thử lại.'
                  : null,
              onTogglePassword: () {},
              onSubmit: () {},
              onForgot: () {},
              onGoogle: () {},
              onRegister: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.runAsync(() async {
          final context = tester.element(find.byType(Scaffold));
          await Future.wait([
            for (final image in tester.widgetList<Image>(find.byType(Image)))
              precacheImage(image.image, context),
          ]);
        });
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile('goldens/login-$state.png'),
        );
      } finally {
        debugDisableShadows = previousShadows;
      }
    });
  }
  for (final state in ['default', 'mismatch']) {
    testWidgets('P2 register $state render', (tester) async {
      tester.view.physicalSize = Size(390, state == 'mismatch' ? 1043 : 1019);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final previousShadows = debugDisableShadows;
      try {
        debugDisableShadows = false;
        await tester.pumpWidget(
          CustomerApp(
            initialRoute: '/register',
            store: visualStore(
              repository: MockLenlabRepository(latency: Duration.zero),
            ),
          ),
        );
        await tester.pumpAndSettle();
        if (state == 'mismatch') {
          for (final entry in [
            'Nguyễn Văn A',
            'khach@example.com',
            'matkhau',
            'khacmatkhau',
          ].asMap().entries) {
            await tester.enterText(
              find.byType(TextFormField).at(entry.key),
              entry.value,
            );
          }
          final submit = find.widgetWithText(ElevatedButton, 'Đăng ký');
          await tester.ensureVisible(submit);
          await tester.tap(submit);
          await tester.pumpAndSettle();
          FocusManager.instance.primaryFocus?.unfocus();
          await tester.pumpAndSettle();
          expect(
            find.text('Mật khẩu xác nhận chưa khớp. Nhập lại mật khẩu.'),
            findsOneWidget,
          );
        }
        await tester.runAsync(() async {
          final context = tester.element(find.byType(Scaffold).last);
          await Future.wait([
            for (final image in tester.widgetList<Image>(find.byType(Image)))
              precacheImage(image.image, context),
          ]);
        });
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await expectLater(
          find.byType(Scaffold).last,
          matchesGoldenFile('goldens/register-$state.png'),
        );
      } finally {
        debugDisableShadows = previousShadows;
      }
    });
  }
  for (final productId in ['merino', 'sheep']) {
    for (final full in productId == 'merino' ? [false, true] : [true]) {
      testWidgets(
        full
            ? 'P2 $productId full render'
            : 'P2 $productId detail at 360 with 120% text',
        (tester) async {
          final previousShadows = debugDisableShadows;
          try {
            debugDisableShadows = false;
            tester.view.physicalSize = full
                ? const Size(390, 1850)
                : const Size(360, 844);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            final repo = MockLenlabRepository(latency: Duration.zero);
            final store = visualStore(repository: repo);
            await tester.pumpWidget(
              CustomerScope(
                store: store,
                child: MaterialApp(
                  theme: P2.theme(),
                  builder: (context, child) => MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(textScaler: TextScaler.linear(full ? 1 : 1.2)),
                    child: child!,
                  ),
                  home: ProductDetailPage(
                    product: repo.catalog.firstWhere((p) => p.id == productId),
                  ),
                ),
              ),
            );
            await tester.pumpAndSettle();
            await tester.runAsync(() async {
              final context = tester.element(find.byType(Scaffold));
              await Future.wait([
                for (final image in tester.widgetList<Image>(
                  find.byType(Image),
                ))
                  precacheImage(image.image, context),
              ]);
            });
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            await expectLater(
              find.byType(Scaffold),
              matchesGoldenFile(
                full
                    ? 'goldens/$productId-full.png'
                    : 'goldens/$productId-360-text120.png',
              ),
            );
          } finally {
            debugDisableShadows = previousShadows;
          }
        },
      );
    }
  }
  testWidgets('login scrolls focused password above keyboard', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 320);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpWidget(CustomerApp(initialRoute: '/login'));
    await tester.pumpAndSettle();
    final password = find.byType(TextFormField).last;
    await tester.ensureVisible(password);
    await tester.tap(password);
    await tester.enterText(password, 'matkhau');
    await tester.pumpAndSettle();
    expect(tester.getBottomRight(password).dy, lessThanOrEqualTo(844 - 320));
    expect(tester.takeException(), isNull);
  });
}
