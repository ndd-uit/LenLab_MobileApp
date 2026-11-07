import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_customer/app/customer_app.dart';
import 'package:lenlab_customer/app/customer_scope.dart';
import 'package:lenlab_customer/features/reviews/data/review_photo_picker.dart';
import 'package:lenlab_customer/features/reviews/presentation/post_purchase_review_page.dart';
import 'package:lenlab_customer/features/reviews/presentation/widgets/review_photo_input.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

ReviewPhoto photo([String name = 'p.png']) => ReviewPhoto(
  name: name,
  bytes: base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
  ),
);

class FakePhotos implements ReviewPhotoPicker {
  List<ReviewPhoto> next = [];
  Object? error;
  Completer<List<ReviewPhoto>>? pending;
  int calls = 0, remaining = 0;
  @override
  Future<List<ReviewPhoto>> pick({required int remaining}) async {
    calls++;
    this.remaining = remaining;
    if (error != null) throw error!;
    return pending?.future ?? next;
  }
}

LenlabStore sample() =>
    LenlabStore(repository: MockLenlabRepository(latency: Duration.zero))
      ..signedIn = true
      ..coupon = 'LEN50';
Finder addPhotos() => find.byKey(const ValueKey('review-add-photos'));
Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));
  await tester.runAsync(() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
  });
  await tester.pumpAndSettle();
}

Future<void> host(WidgetTester tester, LenlabStore s, FakePhotos picker) async {
  await tester.pumpWidget(
    CustomerScope(
      store: s,
      child: MaterialApp(
        theme: P2.theme(),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PostPurchaseReviewPage(
                    orderId: 'WOOL-8805',
                    photoPicker: picker,
                  ),
                ),
              ),
              child: const Text('Open review'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open review'));
  await tester.pumpAndSettle();
}

Future<void> pick(WidgetTester tester) async {
  await tester.ensureVisible(addPhotos());
  await tester.runAsync(() async {
    tester.widget<OutlinedButton>(addPhotos()).onPressed!();
    await Future<void>.delayed(const Duration(milliseconds: 200));
  });
  await settle(tester);
}

void main() {
  testWidgets('Review another product starts with no previous attachments', (
    tester,
  ) async {
    final s = sample(), picker = FakePhotos()..next = [photo()];
    s.orders
        .firstWhere((o) => o.id == 'WOOL-8805')
        .lines
        .add(
          CartLine(
            (s.repository as MockLenlabRepository).catalog.firstWhere(
              (p) => p.id == 'merino',
            ),
          ),
        );
    await host(tester, s, picker);
    tester
        .widget<DropdownButtonFormField<String>>(
          find.byType(DropdownButtonFormField<String>),
        )
        .onChanged!('sheep');
    await tester.pump();
    await tester.tap(find.byTooltip('5 sao'));
    await pick(tester);
    await tester.ensureVisible(find.text('Gửi đánh giá'));
    await tester.tap(find.text('Gửi đánh giá'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Đánh giá sản phẩm khác'));
    await tester.pumpAndSettle();
    tester
        .widget<DropdownButtonFormField<String>>(
          find.byType(DropdownButtonFormField<String>),
        )
        .onChanged!('merino');
    await tester.pump();
    expect(
      tester.widget<ReviewPhotoInput>(find.byType(ReviewPhotoInput)).photos,
      isEmpty,
    );
    expect(s.reviewsFor('sheep').reviews.single.localPhotos.length, 1);
    expect(s.hasReviewed('WOOL-8805', 'merino'), isFalse);
  });
  testWidgets(
    'Five previews, remove and append; no store change before Submit and Back discards',
    (tester) async {
      tester.view.physicalSize = const Size(360, 1000);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final s = sample(),
          picker = FakePhotos()
            ..next = List.generate(5, (i) => photo('$i.png'));
      await host(tester, s, picker);
      await pick(tester);
      expect(
        tester
            .widget<ReviewPhotoInput>(find.byType(ReviewPhotoInput))
            .photos
            .length,
        5,
      );
      expect(tester.widget<OutlinedButton>(addPhotos()).onPressed, isNull);
      expect(s.reviewsFor('sheep').reviews, isEmpty);
      await tester.ensureVisible(find.byTooltip('Bỏ ảnh 2'));
      await tester.tap(find.byTooltip('Bỏ ảnh 2'));
      await tester.pump();
      picker.next = [photo('extra.png')];
      await pick(tester);
      expect(picker.remaining, 1);
      expect(
        tester
            .widget<ReviewPhotoInput>(find.byType(ReviewPhotoInput))
            .photos
            .last
            .name,
        'extra.png',
      );
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(s.reviewsFor('sheep').reviews, isEmpty);
      expect(find.text('Open review'), findsOneWidget);
    },
  );

  testWidgets(
    'Canceled, denied, oversized, invalid and corrupt batches preserve selected draft',
    (tester) async {
      final s = sample(), picker = FakePhotos()..next = [photo()];
      await host(tester, s, picker);
      await pick(tester);
      picker.next = [];
      await pick(tester);
      expect(
        tester
            .widget<ReviewPhotoInput>(find.byType(ReviewPhotoInput))
            .photos
            .length,
        1,
      );
      picker.error = PlatformException(code: 'photo_access_denied');
      await pick(tester);
      expect(
        find.textContaining('Không có quyền truy cập ảnh.'),
        findsOneWidget,
      );
      picker.error = MissingPluginException();
      await pick(tester);
      expect(find.textContaining('Hãy dừng app và chạy lại'), findsOneWidget);
      picker.error = PlatformException(code: 'channel-error');
      await pick(tester);
      expect(find.textContaining('Hãy dừng app và chạy lại'), findsOneWidget);
      picker.error = PlatformException(code: 'already_active');
      await pick(tester);
      expect(find.textContaining('Thư viện ảnh đang mở.'), findsOneWidget);
      picker.error = PlatformException(code: 'native_picker_failed');
      await pick(tester);
      expect(find.textContaining('mã: native_picker_failed'), findsOneWidget);
      picker.error = null;
      for (final invalid in [
        List.generate(5, (_) => photo()),
        [
          ReviewPhoto(
            name: 'big.png',
            bytes: Uint8List(maxReviewPhotoBytes + 1),
          ),
        ],
        [
          ReviewPhoto(name: 'fake.png', bytes: Uint8List.fromList([1, 2, 3])),
        ],
        [
          ReviewPhoto(
            name: 'broken.png',
            bytes: Uint8List.fromList([137, 80, 78, 71, 13, 10, 26, 10]),
          ),
        ],
      ]) {
        picker.next = invalid;
        await pick(tester);
        expect(
          tester
              .widget<ReviewPhotoInput>(find.byType(ReviewPhotoInput))
              .photos
              .length,
          1,
        );
        expect(
          tester.widget<ReviewPhotoInput>(find.byType(ReviewPhotoInput)).error,
          isNotNull,
        );
      }
      expect(s.reviewsFor('sheep').reviews, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Failed Submit retains attachments, retry saves correct pair and image filter renders memory photo',
    (tester) async {
      final s = sample(), picker = FakePhotos()..next = [photo()];
      await host(tester, s, picker);
      await tester.tap(find.byTooltip('5 sao'));
      await pick(tester);
      (s.repository as MockLenlabRepository).failNext('submitReview');
      await tester.ensureVisible(find.text('Gửi đánh giá'));
      await tester.tap(find.text('Gửi đánh giá'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<ReviewPhotoInput>(find.byType(ReviewPhotoInput))
            .photos
            .length,
        1,
      );
      expect(s.reviewsFor('sheep').reviews, isEmpty);
      await tester.ensureVisible(find.text('Gửi đánh giá'));
      await tester.tap(find.text('Gửi đánh giá'));
      await tester.pumpAndSettle();
      final review = s.reviewsFor('sheep').reviews.single;
      expect(review.orderId, 'WOOL-8805');
      expect(review.productId, 'sheep');
      expect(review.localPhotos.length, 1);
      await tester.pumpWidget(CustomerApp(store: s, initialRoute: '/reviews'));
      // Route requires a product ID; explicitly pass the saved product.
      tester
          .state<NavigatorState>(find.byType(Navigator))
          .pushNamed('/reviews', arguments: 'sheep');
      await settle(tester);
      await tester.ensureVisible(find.text('Có hình ảnh (1)'));
      await tester.tap(find.text('Có hình ảnh (1)'));
      await settle(tester);
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Image && (w.image is MemoryImage || w.image is ResizeImage),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Changing product clears attachments; pending picker cannot submit and late result after Back is ignored',
    (tester) async {
      final s = sample(), picker = FakePhotos()..next = [photo()];
      final order = s.orders.firstWhere((o) => o.id == 'WOOL-8805');
      order.lines.add(
        CartLine(
          (s.repository as MockLenlabRepository).catalog.firstWhere(
            (p) => p.id == 'merino',
          ),
        ),
      );
      await host(tester, s, picker);
      final dropdown = find.byType(DropdownButtonFormField<String>);
      tester.widget<DropdownButtonFormField<String>>(dropdown).onChanged!(
        'sheep',
      );
      await tester.pump();
      await pick(tester);
      tester.widget<DropdownButtonFormField<String>>(dropdown).onChanged!(
        'merino',
      );
      await tester.pump();
      expect(
        tester.widget<ReviewPhotoInput>(find.byType(ReviewPhotoInput)).photos,
        isEmpty,
      );
      picker.pending = Completer<List<ReviewPhoto>>();
      await tester.ensureVisible(addPhotos());
      await tester.tap(addPhotos());
      await tester.pump();
      expect(tester.widget<OutlinedButton>(addPhotos()).onPressed, isNull);
      expect(
        tester.widget<DropdownButtonFormField<String>>(dropdown).onChanged,
        isNull,
      );
      await tester.ensureVisible(find.text('Gửi đánh giá'));
      await tester.tap(find.text('Gửi đánh giá'));
      await tester.pump();
      expect(s.hasReviewed('WOOL-8805', 'merino'), isFalse);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      picker.pending!.complete([photo()]);
      await settle(tester);
      expect(find.text('Open review'), findsOneWidget);
      expect(s.hasReviewed('WOOL-8805', 'merino'), isFalse);
      expect(tester.takeException(), isNull);
    },
  );
}
