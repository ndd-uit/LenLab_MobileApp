import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

class GateReviewSource implements PostPurchaseReviewSource {
  final gate = Completer<void>();
  final drafts = <ReviewDraft>[];
  @override
  Future<void> save(ReviewDraft draft) {
    drafts.add(draft);
    return gate.future;
  }
}

void main() {
  LenlabStore store() =>
      LenlabStore(repository: MockLenlabRepository(latency: Duration.zero))
        ..signedIn = true
        ..coupon = 'LEN50';
  test(
    'Only delivered purchases can be reviewed; bad inputs never commit',
    () async {
      final s = store();
      final count = s.productReviews.length;
      final order = s.orders[1];
      final product = order.lines.single.product.id;
      Future<ProductReview> save({String? id, String? pid, int rating = 5}) =>
          s.submitProductReview(
            orderId: id ?? order.id,
            productId: pid ?? product,
            rating: rating,
          );
      s.signedIn = false;
      await expectLater(save(), throwsA(isA<RepositoryException>()));
      s.signedIn = true;
      s.coupon = 'LEN50';
      for (final state in OrderState.values.where(
        (v) => v != OrderState.delivered,
      )) {
        order.state = state;
        await expectLater(save(), throwsA(isA<RepositoryException>()));
      }
      order.state = OrderState.delivered;
      for (final invalid in [
        save(id: 'missing'),
        save(pid: 'merino'),
        save(rating: 0),
        save(rating: 6),
      ]) {
        await expectLater(invalid, throwsA(isA<RepositoryException>()));
      }
      expect(s.productReviews.length, count);
    },
  );
  test('Concurrent submit commits once, keeps association, shares summary and rejects duplicates', () async {
    final s = store(), gate = GateReviewSource();
    final order = s.orders[1], product = s.orders[1].lines.single.product;
    final count = s.productReviews.length;
    final a = s.submitProductReview(
      orderId: order.id,
      productId: product.id,
      rating: 4,
      text: '  Rất mềm  ',
      source: gate,
    );
    final b = s.submitProductReview(
      orderId: order.id,
      productId: product.id,
      rating: 4,
      source: gate,
    );
    expect(gate.drafts.length, 1);
    gate.gate.complete();
    final results = await Future.wait([a, b]);
    expect(results[0], same(results[1]));
    final review = results.first;
    expect(review.orderId, order.id);
    expect(review.productId, product.id);
    expect(review.authorId, s.userId);
    expect(review.text, 'Rất mềm');
    expect(review.rating, 4);
    expect(review.purchased, isTrue);
    expect(s.productReviews.length, count + 1);
    expect(s.reviewsFor(product.id).average, 4);
    expect(s.reviewsFor('carrot').reviews, isEmpty);
    expect(s.hasReviewed(order.id, product.id), isTrue);
    await expectLater(
      s.submitProductReview(
        orderId: order.id,
        productId: product.id,
        rating: 5,
      ),
      throwsA(isA<RepositoryException>()),
    );
    expect(s.cartCount, 3);
    expect(s.orders.length, 4);
    expect(order.state, OrderState.delivered);
  });
  test(
    'Failed submission preserves data and permits retry with optional text',
    () async {
      final s = store();
      (s.repository as MockLenlabRepository).failNext('submitReview');
      final order = s.orders[1], pid = s.orders[1].lines.single.product.id;
      await expectLater(
        s.submitProductReview(orderId: order.id, productId: pid, rating: 1),
        throwsA(isA<RepositoryException>()),
      );
      expect(s.hasReviewed(order.id, pid), isFalse);
      final review = await s.submitProductReview(
        orderId: order.id,
        productId: pid,
        rating: 1,
      );
      expect(review.text, isEmpty);
      expect(s.reviewsFor(pid).reviews.length, 1);
      s.orders.add(
        Order(
          ownerId: mockCustomerAId,
          id: 'OTHER',
          lines: order.lines,
          address: order.address,
          state: OrderState.delivered,
        ),
      );
      await s.submitProductReview(orderId: 'OTHER', productId: pid, rating: 5);
      expect(s.reviewsFor(pid).average, 3);
    },
  );
  for (final change in ['logout', 'account', 'state', 'product']) {
    test('Recheck $change during save prevents stale local commit', () async {
      final s = store(), gate = GateReviewSource();
      final order = s.orders[1], pid = s.orders[1].lines.single.product.id;
      final request = s.submitProductReview(
        orderId: order.id,
        productId: pid,
        rating: 5,
        source: gate,
      );
      switch (change) {
        case 'logout':
          s.signedIn = false;
        case 'account':
          s.logout();
          s.signedIn = true;
          s.coupon = 'LEN50';
        case 'state':
          order.state = OrderState.cancelled;
        case 'product':
          order.lines.clear();
      }
      final expectation = expectLater(
        request,
        throwsA(isA<RepositoryException>()),
      );
      gate.gate.complete();
      await expectation;
      expect(s.reviewsFor(pid).reviews, isEmpty);
    });
  }
}
