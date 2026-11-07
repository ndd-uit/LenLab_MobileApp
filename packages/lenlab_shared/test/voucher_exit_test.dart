import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

LenlabStore sample({bool guest = false}) {
  final s = LenlabStore(
    repository: MockLenlabRepository(latency: Duration.zero),
    authSource: MockCustomerAuthSource(latency: Duration.zero),
  );
  if (!guest) {
    s.signedIn = true;
    s.deliveryAddress = s.addresses.single;
    s.checkoutNote = 'Retain checkout note';
    s.bankTransferReference = 'Retain reference';
  }
  addTearDown(s.dispose);
  return s;
}

VoucherExitIntent intent(LenlabStore s) => VoucherExitIntent(
  session: s.captureSession(),
  expectedSelectionRevision: s.voucherSelectionRevision,
  expectedCampaignId: s.voucherExitCampaignId,
  expectedLegacyCouponCode: s.coupon.isEmpty ? null : s.coupon,
);

Map<String, Object?> data(LenlabStore s) => {
  'identity': s.currentUser,
  'generation': s.sessionGeneration,
  'cart': s.cart
      .map((l) => (l.key, l.quantity, l.product.price, l.product.stock))
      .toList(),
  'selected': s.checkoutLines.map((l) => l.key).toList(),
  'address': s.deliveryAddress,
  'note': s.checkoutNote,
  'bankReference': s.bankTransferReference,
  'payment': s.checkoutPaymentMethod,
  'orders': s.orders.map((o) => (o.id, o.ownerId, o.total, o.state)).toList(),
  'addresses': s.addresses
      .map((a) => (a.ownerId, a.full, a.isDefault))
      .toList(),
  'profile': (s.profile.name, s.profile.email, s.profile.phone),
};

VoucherEvaluation evaluation(VoucherEvaluationContext c, String? id) =>
    VoucherEvaluation(
      status: VoucherEligibilityStatus.eligible,
      reason: 'INJECTED_TEST_ONLY',
      contextKey: c.key,
      campaignId: id ?? 'manual-code-id',
      itemsDiscountVnd: 10000,
    );

class Eligible implements VoucherEligibilitySource {
  @override
  Future<VoucherEvaluation> evaluate(
    VoucherEvaluationContext context, {
    String? campaignId,
    String? code,
  }) async => evaluation(context, campaignId);
}

class WaitingEligibility implements VoucherEligibilitySource {
  final entered = Completer<void>(), release = Completer<VoucherEvaluation>();
  late VoucherEvaluationContext context;
  String? id;
  @override
  Future<VoucherEvaluation> evaluate(
    VoucherEvaluationContext context, {
    String? campaignId,
    String? code,
  }) {
    this.context = context;
    id = campaignId;
    entered.complete();
    return release.future;
  }

  void finish({bool error = false}) {
    if (error) {
      release.completeError(StateError('old eligibility error'));
    } else {
      release.complete(evaluation(context, id));
    }
  }
}

CheckoutQuote quote(CheckoutQuoteRequest r) => CheckoutQuote(
  id: 'test-quote',
  version: 1,
  session: r.context.session,
  contextKey: r.key,
  lines: r.context.lines,
  status: CheckoutQuoteStatus.ready,
  reason: 'INJECTED_TEST_ONLY',
  campaignId: r.campaignId,
  itemsSubtotalVnd: r.context.subtotal,
  itemsDiscountVnd: r.campaignId == null ? 0 : 10000,
  shippingFeeVnd: 17000,
  shippingDiscountVnd: 0,
);

class ReadyQuote implements CheckoutQuoteSource {
  int calls = 0;
  @override
  Future<CheckoutQuote> load(CheckoutQuoteRequest request) async {
    calls++;
    return quote(request);
  }
}

class WaitingQuote implements CheckoutQuoteSource {
  final entered = Completer<void>(), release = Completer<CheckoutQuote>();
  late CheckoutQuoteRequest request;
  @override
  Future<CheckoutQuote> load(CheckoutQuoteRequest request) {
    this.request = request;
    entered.complete();
    return release.future;
  }

  void finish({bool error = false}) {
    if (error) {
      release.completeError(StateError('old quote error'));
    } else {
      release.complete(quote(request));
    }
  }
}

class WaitingCod implements CodOrderSource {
  final entered = Completer<void>(), release = Completer<Order>();
  late CodOrderDraft draft;
  @override
  Future<Order> submit(CodOrderDraft draft) {
    this.draft = draft;
    entered.complete();
    return release.future;
  }

  void finish() => release.complete(
    Order(
      ownerId: draft.ownerId,
      id: draft.id,
      lines: draft.lines,
      address: draft.address,
      discount: draft.discount,
      shipping: draft.shipping,
      note: draft.note,
    ),
  );
}

Future<void> apply(LenlabStore s, [String id = 'campaign-A']) async {
  await s.evaluateVoucher(Eligible(), campaignId: id);
  expect(s.appliedVoucher?.campaignId, id);
}

void cleared(LenlabStore s) {
  expect(s.voucherCandidate, isNull);
  expect(s.voucherEvaluation, isNull);
  expect(s.appliedVoucher, isNull);
  expect(s.checkoutQuote, isNull);
  expect(s.voucherExitCampaignId, isNull);
  expect(s.hasUnquotedVoucherSelection, isFalse);
  expect(s.isEvaluatingVoucher, isFalse);
}

void main() {
  test('candidate-only exit is atomic, notifies once and preserves all account/cart data', () {
    final s = sample();
    s.changeQuantity(s.cart.last, 1);
    s.toggleCartLine(s.cart.first);
    final before = data(s);
    final lines = s.cart.toList();
    s.selectVoucherCandidate('candidate', session: s.captureSession());
    final old = intent(s);
    var notifications = 0;
    s.addListener(() {
      notifications++;
      cleared(s);
      expect(data(s), before);
    });
    expect(s.exitVoucher(old), isTrue);
    expect(notifications, 1);
    expect(s.cart, orderedEquals(lines));
    expect(
      s.voucherSelectionRevision,
      greaterThan(old.expectedSelectionRevision),
    );
    expect(s.exitVoucher(intent(s)), isFalse);
    expect(notifications, 1);
  });

  test('READY applied/quote exit clears promotion only, never requotes or creates an order', () async {
    final s = sample();
    await apply(s);
    final source = ReadyQuote();
    s.configureCheckoutQuoteSource(source);
    final ready = await s.requestCheckoutQuote();
    expect(ready!.status, CheckoutQuoteStatus.ready);
    final before = data(s),
        subtotal = s.checkoutSubtotal,
        discount = s.checkoutDiscount;
    expect(s.exitVoucher(intent(s)), isTrue);
    cleared(s);
    await Future<void>.delayed(Duration.zero);
    expect(source.calls, 1);
    expect(data(s), before);
    expect(s.checkoutSubtotal, subtotal);
    expect(s.checkoutDiscount, discount);
    // An old 17k quote must not bypass the unchanged 30k legacy validator.
    await expectLater(
      s.submitCodOrder(totals: ready.reviewTotals),
      throwsA(isA<CodValidationException>()),
    );
    expect(data(s), before);
  });

  test('stale applied can be explicitly exited using raw target, without resetting session', () async {
    final s = sample();
    await apply(s);
    s.changeQuantity(s.cart.first, 1);
    expect(s.appliedVoucher, isNull);
    expect(s.hasUnquotedVoucherSelection, isTrue);
    expect(s.voucherExitCampaignId, 'campaign-A');
    final before = data(s);
    expect(s.exitVoucher(intent(s)), isTrue);
    cleared(s);
    expect(data(s), before);
    expect(s.requireVoucherCheckoutReady, returnsNormally);
  });

  test('exact explicit LEN50 target removes only promotion/discount', () {
    final s = sample()..coupon = 'LEN50';
    final before = data(s), subtotal = s.checkoutSubtotal;
    expect(s.checkoutDiscount, 50000);
    expect(s.exitVoucher(intent(s)), isTrue);
    expect(s.coupon, isEmpty);
    expect(s.checkoutSubtotal, subtotal);
    expect(s.checkoutDiscount, 0);
    expect(data(s), before);
    cleared(s);
  });

  for (final invalid in [
    'campaign-wrong',
    'campaign-omitted',
    'legacy-wrong',
    'legacy-omitted',
    'revision-old',
  ]) {
    test('$invalid rejects before any partial mutation or notification', () {
      final s = sample()..coupon = 'LEN50';
      s.selectVoucherCandidate('candidate', session: s.captureSession());
      final before = data(s), old = intent(s), candidate = s.voucherCandidate;
      var notifications = 0;
      s.addListener(() => notifications++);
      final bad = VoucherExitIntent(
        session: old.session,
        expectedSelectionRevision: invalid == 'revision-old'
            ? old.expectedSelectionRevision - 1
            : old.expectedSelectionRevision,
        expectedCampaignId: invalid == 'campaign-wrong'
            ? 'other'
            : invalid == 'campaign-omitted'
            ? null
            : old.expectedCampaignId,
        expectedLegacyCouponCode: invalid == 'legacy-wrong'
            ? 'len50'
            : invalid == 'legacy-omitted'
            ? null
            : 'LEN50',
      );
      expect(() => s.exitVoucher(bad), throwsA(isA<RepositoryException>()));
      expect(s.coupon, 'LEN50');
      expect(s.voucherCandidate, same(candidate));
      expect(s.voucherSelectionRevision, old.expectedSelectionRevision);
      expect(data(s), before);
      expect(notifications, 0);
    });
  }

  test('none is a no-op without requests; unrelated ready no-voucher quote is preserved', () async {
    final s = sample();
    var notifications = 0;
    s.addListener(() => notifications++);
    final old = intent(s);
    expect(s.exitVoucher(old), isFalse);
    expect(notifications, 0);
    expect(s.voucherSelectionRevision, old.expectedSelectionRevision);
    s.configureCheckoutQuoteSource(ReadyQuote());
    final ready = await s.requestCheckoutQuote();
    notifications = 0;
    expect(s.exitVoucher(intent(s)), isFalse);
    expect(s.checkoutQuote, same(ready));
    expect(notifications, 0);
  });

  for (final error in [false, true]) {
    test(
      'pending eligibility ${error ? 'error' : 'success'} cannot revive exited state',
      () async {
        final s = sample();
        final source = WaitingEligibility();
        final pending = s.evaluateVoucher(source, campaignId: 'pending');
        await source.entered.future;
        final before = data(s);
        expect(s.exitVoucher(intent(s)), isTrue);
        final revision = s.voucherSelectionRevision;
        var notifications = 0;
        s.addListener(() => notifications++);
        source.finish(error: error);
        expect(await pending, isNull);
        cleared(s);
        expect(s.voucherSelectionRevision, revision);
        expect(notifications, 0);
        expect(data(s), before);
      },
    );

    test(
      'pending quote ${error ? 'error' : 'success'} cannot revive exited state',
      () async {
        final s = sample();
        await apply(s);
        final source = WaitingQuote();
        s.configureCheckoutQuoteSource(source);
        final pending = s.requestCheckoutQuote();
        await source.entered.future;
        final before = data(s);
        expect(s.exitVoucher(intent(s)), isTrue);
        var notifications = 0;
        s.addListener(() => notifications++);
        source.finish(error: error);
        expect(await pending, isNull);
        cleared(s);
        expect(notifications, 0);
        expect(data(s), before);
      },
    );
  }

  test('manual unresolved code changes revision and can be cancelled without a fake campaign ID', () async {
    final s = sample();
    final before = intent(s);
    final source = WaitingEligibility();
    final pending = s.evaluateVoucher(source, code: 'manual-code');
    await source.entered.future;
    expect(s.voucherExitCampaignId, isNull);
    expect(() => s.exitVoucher(before), throwsA(isA<RepositoryException>()));
    expect(s.exitVoucher(intent(s)), isTrue);
    source.finish();
    expect(await pending, isNull);
    cleared(s);
  });

  test('pending no-voucher quote is cancelled by explicit none', () async {
    final s = sample();
    final source = WaitingQuote();
    s.configureCheckoutQuoteSource(source);
    final pending = s.requestCheckoutQuote();
    await source.entered.future;
    expect(s.exitVoucher(intent(s)), isTrue);
    source.finish();
    expect(await pending, isNull);
    cleared(s);
  });

  for (final actor in ['B', 'logout', 'same-A']) {
    test('old exit intent cannot touch $actor session data', () async {
      final s = sample();
      await apply(s);
      final old = intent(s);
      if (actor == 'logout') {
        s.logout();
      } else {
        await s.signIn(
          identity: actor == 'B' ? mockCustomerB.email : mockCustomerA.email,
          password: 'mock',
        );
      }
      s.selectVoucherCandidate('new-session', session: s.captureSession());
      s.coupon = 'LEN50';
      final before = data(s), current = intent(s);
      expect(() => s.exitVoucher(old), throwsA(isA<RepositoryException>()));
      expect(s.voucherExitCampaignId, 'new-session');
      expect(s.coupon, 'LEN50');
      expect(s.voucherSelectionRevision, current.expectedSelectionRevision);
      expect(data(s), before);
    });
  }

  test(
    'candidate same-ID ABA and coupon ABA both invalidate rendered intent',
    () {
      final s = sample();
      s.selectVoucherCandidate('same', session: s.captureSession());
      final old = intent(s);
      s.selectVoucherCandidate('other', session: s.captureSession());
      s.selectVoucherCandidate('same', session: s.captureSession());
      expect(() => s.exitVoucher(old), throwsA(isA<RepositoryException>()));
      s.coupon = 'LEN50';
      final oldCoupon = intent(s);
      s.coupon = 'different';
      s.coupon = 'LEN50';
      expect(
        () => s.exitVoucher(oldCoupon),
        throwsA(isA<RepositoryException>()),
      );
      expect(s.coupon, 'LEN50');
    },
  );

  test(
    'applied target takes precedence over a failed/uncommitted candidate',
    () async {
      final s = sample();
      await apply(s);
      s.selectVoucherCandidate('uncommitted-B', session: s.captureSession());
      final old = intent(s);
      expect(old.expectedCampaignId, 'campaign-A');
      expect(
        () => s.exitVoucher(
          VoucherExitIntent(
            session: old.session,
            expectedSelectionRevision: old.expectedSelectionRevision,
            expectedCampaignId: 'uncommitted-B',
          ),
        ),
        throwsA(isA<RepositoryException>()),
      );
      expect(s.hasUnquotedVoucherSelection, isTrue);
      expect(s.exitVoucher(old), isTrue);
      cleared(s);
    },
  );

  test(
    'late eligibility finally cannot clear a fresh request started after exit',
    () async {
      final s = sample();
      final old = WaitingEligibility();
      final first = s.evaluateVoucher(old, campaignId: 'old');
      await old.entered.future;
      s.exitVoucher(intent(s));
      final fresh = WaitingEligibility();
      final second = s.evaluateVoucher(fresh, campaignId: 'fresh');
      await fresh.entered.future;
      old.finish();
      expect(await first, isNull);
      expect(s.isEvaluatingVoucher, isTrue);
      expect(s.voucherCandidate?.campaignId, 'fresh');
      fresh.finish();
      expect((await second)!.campaignId, 'fresh');
      expect(s.appliedVoucher?.campaignId, 'fresh');
    },
  );

  test(
    'late quote cannot overwrite a fresh no-voucher quote after exit',
    () async {
      final s = sample();
      await apply(s);
      final old = WaitingQuote();
      s.configureCheckoutQuoteSource(old);
      final first = s.requestCheckoutQuote();
      await old.entered.future;
      s.exitVoucher(intent(s));
      s.configureCheckoutQuoteSource(ReadyQuote());
      final fresh = await s.requestCheckoutQuote();
      old.finish();
      expect(await first, isNull);
      expect(s.checkoutQuote, same(fresh));
      expect(fresh!.campaignId, isNull);
      expect(s.appliedVoucher, isNull);
    },
  );

  test(
    'COD pending rejects exit before mutation and does not cancel the order',
    () async {
      final s = sample()..coupon = 'LEN50';
      final source = WaitingCod();
      final pending = s.submitCodOrder(
        totals: OrderReviewTotals(
          subtotal: s.checkoutSubtotal,
          discount: s.checkoutDiscount,
          shipping: 30000,
        ),
        source: source,
      );
      await source.entered.future;
      final before = data(s), old = intent(s);
      var notifications = 0;
      s.addListener(() => notifications++);
      expect(() => s.exitVoucher(old), throwsA(isA<RepositoryException>()));
      expect(s.coupon, 'LEN50');
      expect(s.voucherSelectionRevision, old.expectedSelectionRevision);
      expect(data(s), before);
      expect(notifications, 0);
      expect(s.isSubmittingCod, isTrue);
      source.finish();
      final order = await pending;
      expect(order.ownerId, mockCustomerAId);
      expect(s.orders.where((o) => o.id == order.id), hasLength(1));
    },
  );

  test('pending A only locks A; Guest/B exit works and new A generation stays locked', () async {
    final s = sample()..coupon = 'LEN50';
    final source = WaitingCod();
    final pending = s.submitCodOrder(
      totals: OrderReviewTotals(
        subtotal: s.checkoutSubtotal,
        discount: s.checkoutDiscount,
        shipping: 30000,
      ),
      source: source,
    );
    await source.entered.future;
    s.logout();
    s.selectVoucherCandidate('Guest', session: s.captureSession());
    expect(s.exitVoucher(intent(s)), isTrue);
    await s.signIn(identity: mockCustomerB.email, password: 'mock');
    s.selectVoucherCandidate('B', session: s.captureSession());
    expect(s.exitVoucher(intent(s)), isTrue);
    expect(s.orders, isEmpty);
    await s.signIn(identity: mockCustomerA.email, password: 'mock');
    expect(s.isSubmittingCod, isTrue);
    expect(() => s.exitVoucher(intent(s)), throwsA(isA<RepositoryException>()));
    expect(s.coupon, 'LEN50');
    source.finish();
    final order = await pending;
    expect(order.ownerId, mockCustomerAId);
    expect(s.orders.where((o) => o.id == order.id), hasLength(1));
  });
}
