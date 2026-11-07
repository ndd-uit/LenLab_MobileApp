import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

ReviewPhoto photo() => ReviewPhoto(
  name: 'photo.png',
  bytes: base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
  ),
);
LenlabStore store() =>
    LenlabStore(repository: MockLenlabRepository(latency: Duration.zero))
      ..signedIn = true
      ..coupon = 'LEN50';

class Gate implements PostPurchaseReviewSource {
  final done = Completer<void>();
  ReviewDraft? draft;
  @override
  Future<void> save(ReviewDraft value) {
    draft = value;
    return done.future;
  }
}

void main() {
  test('Five JPG/PNG images and 5 MiB per-image boundary; actual signature required, immutable bytes', () {
    validateReviewPhotos(List.generate(5, (_) => photo()));
    validateReviewPhotos([
      ReviewPhoto(name: 'a.jpg', bytes: Uint8List.fromList([255, 216, 255, 0])),
    ]);
    final boundary = Uint8List(maxReviewPhotoBytes)
      ..setRange(0, 8, photo().bytes);
    validateReviewPhotos([ReviewPhoto(name: 'max.png', bytes: boundary)]);
    for (final invalid in [
      List.generate(6, (_) => photo()),
      [
        ReviewPhoto(
          name: 'large.png',
          bytes: Uint8List(maxReviewPhotoBytes + 1),
        ),
      ],
      [
        ReviewPhoto(name: 'fake.jpg', bytes: Uint8List.fromList([1, 2, 3])),
      ],
      [ReviewPhoto(name: 'empty.png', bytes: Uint8List(0))],
    ]) {
      expect(
        () => validateReviewPhotos(invalid),
        throwsA(isA<RepositoryException>()),
      );
    }
    final p = photo();
    expect(() => p.bytes[0] = 0, throwsUnsupportedError);
  });

  test('Submission snapshot contains exact order/product photos and withImages recognizes local memory', () async {
    final s = store();
    final gate = Gate();
    final photos = [photo()];
    final pending = s.submitProductReview(
      orderId: 'WOOL-8805',
      productId: 'sheep',
      rating: 5,
      photos: photos,
      source: gate,
    );
    photos.clear();
    expect(gate.draft!.orderId, 'WOOL-8805');
    expect(gate.draft!.productId, 'sheep');
    expect(gate.draft!.photos.length, 1);
    expect(() => gate.draft!.photos.clear(), throwsUnsupportedError);
    gate.done.complete();
    final review = await pending;
    expect(review.photos, isEmpty);
    expect(review.localPhotos.single.bytes, orderedEquals(photo().bytes));
    expect(review.hasImages, isTrue);
    expect(s.reviewsFor('sheep').imageCount, 1);
    expect(
      s.reviewsFor('sheep').filtered(ReviewFilter.withImages).single,
      same(review),
    );
    expect(() => review.localPhotos.clear(), throwsUnsupportedError);
  });

  test('Invalid photos and failed save never create review; retry keeps eligibility and attachment', () async {
    final s = store();
    final count = s.productReviews.length;
    await expectLater(
      s.submitProductReview(
        orderId: 'WOOL-8805',
        productId: 'sheep',
        rating: 5,
        photos: List.generate(6, (_) => photo()),
      ),
      throwsA(isA<RepositoryException>()),
    );
    expect(s.productReviews.length, count);
    (s.repository as MockLenlabRepository).failNext('submitReview');
    await expectLater(
      s.submitProductReview(
        orderId: 'WOOL-8805',
        productId: 'sheep',
        rating: 5,
        photos: [photo()],
      ),
      throwsA(isA<RepositoryException>()),
    );
    expect(s.hasReviewed('WOOL-8805', 'sheep'), isFalse);
    final result = await s.submitProductReview(
      orderId: 'WOOL-8805',
      productId: 'sheep',
      rating: 5,
      photos: [photo()],
    );
    expect(result.localPhotos.length, 1);
    expect(s.orders.length, 4);
  });
}
