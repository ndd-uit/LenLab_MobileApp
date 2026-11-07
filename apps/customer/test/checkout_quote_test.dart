import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_shared/lenlab_shared.dart';
import 'package:lenlab_customer/app/customer_app.dart';
import 'package:lenlab_customer/features/vouchers/data/voucher_source.dart';
import 'package:lenlab_customer/features/checkout/data/mock_checkout_quote_source.dart';
import 'package:lenlab_customer/features/cart/presentation/widgets/cart_summary.dart';
import 'package:lenlab_customer/features/checkout/presentation/widgets/order_review_totals.dart';
import 'package:lenlab_customer/features/checkout/presentation/order_review_page.dart';

import 'voucher_evaluation_test.dart' as v;

PublicVoucherCampaign campaign(VoucherRules? rules) => PublicVoucherCampaign(
  id: 'quote-demo',
  version: 7,
  rules: rules,
  publication: VoucherPublication.published,
  kind: WalletVoucherKind.discount,
  title: 'Quote demo',
  label: 'DEMO',
  description: 'Explicit injected test config only',
  expiry: '01/01/2000',
);

MockCheckoutQuoteSource source(
  LenlabStore s,
  PublicVoucherCampaign c, {
  bool shipping = true,
  DateTime? Function(VoucherEvaluationContext)? expiry,
}) => MockCheckoutQuoteSource(
  s,
  campaigns: MockPublicCampaignSource(s, campaigns: [c]),
  usage: MockCustomerVoucherUsageSource(s, usage: []),
  clock: () => v.now,
  expiresAt: expiry,
  shippingSource: shipping
      ? MockShippingPreviewSource(
          s,
          clock: () => v.now,
          loader: (context) async => ShippingPreview.ready(
            session: context.session,
            contextKey: context.key,
            grossShippingFeeVnd: 17000,
            eligibleShippingFeeVnd: 12000,
          ),
        )
      : null,
);

Future<PublicVoucherCampaign> apply(
  LenlabStore s, {
  VoucherRuleType type = VoucherRuleType.itemsFixed,
}) async {
  s.deliveryAddress = s.addresses.single;
  final c = campaign(v.rules(type: type, amount: 10000, cap: 5000));
  await s.evaluateVoucher(
    v.evaluator(
      s,
      [c],
      shipping: ShippingPreview.ready(
        session: s.captureSession(),
        contextKey: s.voucherContextKey,
        grossShippingFeeVnd: 17000,
        eligibleShippingFeeVnd: 12000,
      ),
    ),
    campaignId: c.id,
  );
  expect(s.appliedVoucher, isNotNull);
  return c;
}

CheckoutQuoteRequest request(LenlabStore s, String? id) => CheckoutQuoteRequest(
  context: s.captureVoucherContext(),
  key: s.checkoutQuoteKey,
  campaignId: id,
);

class WaitingQuote implements CheckoutQuoteSource {
  WaitingQuote(this.delegate);
  final CheckoutQuoteSource delegate;
  final entered = Completer<void>(), release = Completer<void>();
  int calls = 0;
  @override
  Future<CheckoutQuote> load(CheckoutQuoteRequest request) async {
    calls++;
    if (!entered.isCompleted) entered.complete();
    await release.future;
    return delegate.load(request);
  }
}

class FailOnce implements CheckoutQuoteSource {
  FailOnce(this.delegate);
  final CheckoutQuoteSource delegate;
  int calls = 0;
  @override
  Future<CheckoutQuote> load(CheckoutQuoteRequest request) {
    if (calls++ == 0) throw StateError('injected quote error');
    return delegate.load(request);
  }
}

class ForbiddenLegacyReview implements OrderReviewSource {
  int calls = 0;
  @override
  Future<OrderReviewTotals> preview({
    required int subtotal,
    required int discount,
    required Address address,
  }) async {
    calls++;
    throw StateError('New voucher must not fall back to legacy pricing');
  }
}

class InvalidQuoteSource implements CheckoutQuoteSource {
  InvalidQuoteSource(this.foreignOwner);
  final bool foreignOwner;
  @override
  Future<CheckoutQuote> load(CheckoutQuoteRequest request) async =>
      CheckoutQuote(
        id: 'bad',
        version: 1,
        session: foreignOwner
            ? const CustomerSessionStamp(
                userId: 'customer-demo-b',
                generation: 1,
              )
            : request.context.session,
        contextKey: request.key,
        lines: request.context.lines,
        status: CheckoutQuoteStatus.ready,
        reason: 'INJECTED',
        campaignId: request.campaignId,
        itemsSubtotalVnd: request.context.subtotal,
        itemsDiscountVnd: foreignOwner ? 0 : request.context.subtotal + 1,
        shippingFeeVnd: 17000,
        shippingDiscountVnd: 0,
      );
}

void main() {
  for (final foreign in [true, false]) {
    test(
      'invalid ${foreign ? 'owner' : 'money'} quote response never becomes ready',
      () async {
        final s = v.sample();
        await apply(s);
        s.configureCheckoutQuoteSource(InvalidQuoteSource(foreign));
        expect(
          (await s.requestCheckoutQuote())!.status,
          CheckoutQuoteStatus.error,
        );
        expect(s.checkoutQuote!.grandTotalVnd, isNull);
        expect(s.cart.single.quantity, 1);
      },
    );
  }

  test(
    'cached ready quote goes stale on edits and fresh quote uses new selection',
    () async {
      final s = v.sample();
      final c = await apply(s);
      s.configureCheckoutQuoteSource(source(s, c));
      final first = (await s.requestCheckoutQuote())!;
      s.changeQuantity(s.cart.single, 1);
      expect(s.checkoutQuote!.status, CheckoutQuoteStatus.stale);
      expect(s.checkoutQuote!.grandTotalVnd, isNull);
      final second = (await s.requestCheckoutQuote())!;
      expect(second.id, isNot(first.id));
      expect(second.itemsSubtotalVnd, 90000);
      s.toggleCartLine(s.cart.single);
      expect(s.checkoutQuote!.status, CheckoutQuoteStatus.stale);
      expect(
        (await s.requestCheckoutQuote())!.status,
        CheckoutQuoteStatus.needsContext,
      );
      expect(s.checkoutLines, isEmpty);
    },
  );
  for (final type in [
    VoucherRuleType.itemsFixed,
    VoucherRuleType.itemsPercentage,
    VoucherRuleType.shippingFreeFull,
    VoucherRuleType.shippingDiscountCapped,
  ]) {
    test(
      '$type quote has one consistent totals projection and immutable snapshots',
      () async {
        final s = v.sample();
        final repo = s.repository as MockLenlabRepository;
        s.addToCart(
          repo.catalog.singleWhere((p) => p.id == 'sweater'),
          1,
          'not-selected',
        );
        s.toggleCartLine(s.cart.last);
        final c = await apply(s, type: type);
        s.configureCheckoutQuoteSource(source(s, c));
        final q = (await s.requestCheckoutQuote())!;
        expect(q.status, CheckoutQuoteStatus.ready);
        expect(q.id, isNotEmpty);
        expect(q.version, 1);
        expect(q.campaignVersion, 7);
        expect(q.session.userId, mockCustomerAId);
        expect(q.itemsSubtotalVnd, 45000);
        expect(q.shippingFeeVnd, 17000);
        expect(q.itemsDiscountVnd, switch (type) {
          VoucherRuleType.itemsFixed => 10000,
          VoucherRuleType.itemsPercentage => 5000,
          _ => 0,
        });
        expect(q.shippingDiscountVnd, switch (type) {
          VoucherRuleType.shippingFreeFull => 12000,
          VoucherRuleType.shippingDiscountCapped => 10000,
          _ => 0,
        });
        expect(
          q.grandTotalVnd,
          45000 + 17000 - q.itemsDiscountVnd! - q.shippingDiscountVnd!,
        );
        expect(q.reviewTotals.total, q.grandTotalVnd);
        expect(q.reviewTotals.discount, q.itemsDiscountVnd);
        expect(q.lines.single.productId, 'carrot');
        expect(() => q.lines.clear(), throwsUnsupportedError);
        expect(s.checkoutDiscount, 0);
        expect(s.coupon, isEmpty);
        expect(s.orders, hasLength(4));
      },
    );
  }

  test('missing shipping has no grand total, no invented fee or TTL', () async {
    final s = v.sample();
    final c = await apply(s);
    final q = await source(s, c, shipping: false).load(request(s, c.id));
    expect(q.status, CheckoutQuoteStatus.needsContext);
    expect(q.itemsDiscountVnd, 10000);
    expect(q.shippingFeeVnd, isNull);
    expect(q.grandTotalVnd, isNull);
    expect(() => q.reviewTotals, throwsStateError);
  });

  test(
    'no campaign uses explicit shipping with no quote TTL default',
    () async {
      final s = v.sample();
      s.deliveryAddress = s.addresses.single;
      final q = await source(s, campaign(null)).load(request(s, null));
      expect(q.status, CheckoutQuoteStatus.ready);
      expect(q.grandTotalVnd, 62000);
      expect(q.expiresAt, isNull);
    },
  );

  test('missing rules and legacy coupon never fallback or stack', () async {
    final s = v.sample();
    s.deliveryAddress = s.addresses.single;
    final missing = await source(
      s,
      campaign(null),
    ).load(request(s, 'quote-demo'));
    expect(missing.reason, 'CONFIG_INCOMPLETE');
    expect(missing.grandTotalVnd, isNull);
    s.coupon = 'LEN50';
    final conflict = await source(
      s,
      campaign(v.rules()),
    ).load(request(s, 'quote-demo'));
    expect(conflict.reason, 'LEGACY_COUPON_CONFLICT');
    expect(conflict.grandTotalVnd, isNull);
    expect(s.coupon, 'LEN50');
  });

  test('empty selection remains empty and has no final total', () async {
    final s = v.sample();
    final c = await apply(s);
    s.toggleCartLine(s.cart.single);
    final q = await source(s, c).load(request(s, c.id));
    expect(q.status, CheckoutQuoteStatus.needsContext);
    expect(q.reason, 'EMPTY_SELECTION');
    expect(q.grandTotalVnd, isNull);
    expect(s.checkoutLines, isEmpty);
  });

  test(
    'catalog price mismatch rejects quote without silently updating cart',
    () async {
      final s = v.sample();
      final c = await apply(s);
      final old = s.cart.single.product.price;
      (s.repository as MockLenlabRepository).catalog
          .singleWhere((p) => p.id == 'carrot')
          .price++;
      final q = await source(s, c).load(request(s, c.id));
      expect(q.reason, 'PRICE_CHANGED');
      expect(q.grandTotalVnd, isNull);
      expect(s.cart.single.product.price, old);
    },
  );

  for (final change in [
    'quantity',
    'selection',
    'catalog',
    'logout',
    'B',
    'same-A',
  ]) {
    test(
      '$change invalidates old and pending quote; does not write new session',
      () async {
        final s = v.sample();
        final c = await apply(s);
        s.configureCheckoutQuoteSource(source(s, c));
        final ready = (await s.requestCheckoutQuote())!;
        final waiting = WaitingQuote(source(s, c));
        s.configureCheckoutQuoteSource(waiting);
        final pending = s.requestCheckoutQuote();
        final duplicate = s.requestCheckoutQuote();
        expect(identical(pending, duplicate), isTrue);
        await waiting.entered.future;
        switch (change) {
          case 'quantity':
            s.changeQuantity(s.cart.single, 1);
          case 'selection':
            s.toggleCartLine(s.cart.single);
          case 'catalog':
            (s.repository as MockLenlabRepository).catalog.first.price++;
          case 'logout':
            s.logout();
          case 'B':
            await s.signIn(identity: mockCustomerB.email, password: 'mock');
          case 'same-A':
            await s.signIn(identity: mockCustomerA.email, password: 'mock');
        }
        expect(s.checkoutQuote?.grandTotalVnd, isNull);
        waiting.release.complete();
        expect(await pending, isNull);
        expect(waiting.calls, 1);
        expect(ready.lines.single.quantity, 1);
        expect(s.checkoutQuote?.status, isNot(CheckoutQuoteStatus.ready));
      },
    );
  }

  test(
    'quote error preserves draft and force retry succeeds without creating COD',
    () async {
      final s = v.sample();
      final c = await apply(s);
      s.checkoutNote = 'Retain note';
      final address = s.deliveryAddress, lines = s.cart.toList();
      final fail = FailOnce(source(s, c));
      s.configureCheckoutQuoteSource(fail);
      expect(
        (await s.requestCheckoutQuote())!.status,
        CheckoutQuoteStatus.error,
      );
      expect(s.checkoutNote, 'Retain note');
      expect(s.deliveryAddress, same(address));
      expect(s.cart, orderedEquals(lines));
      final ready = (await s.requestCheckoutQuote(force: true))!;
      expect(ready.status, CheckoutQuoteStatus.ready);
      await expectLater(
        s.submitCodOrder(totals: ready.reviewTotals),
        throwsA(isA<RepositoryException>()),
      );
      expect(s.orders, hasLength(4));
      expect(s.checkoutNote, 'Retain note');
    },
  );

  test('latest quote wins over delayed prior request', () async {
    final s = v.sample();
    final c = await apply(s);
    final waiting = WaitingQuote(source(s, c));
    s.configureCheckoutQuoteSource(waiting);
    final first = s.requestCheckoutQuote();
    await waiting.entered.future;
    s.changeQuantity(s.cart.single, 1);
    final second = s.requestCheckoutQuote();
    waiting.release.complete();
    expect(await first, isNull);
    final latest = await second;
    expect(s.checkoutQuote, same(latest));
    expect(latest!.itemsSubtotalVnd, 90000);
    expect(waiting.calls, 2);
  });

  test(
    'source-supplied expiry invalidates cached quote without fixed TTL',
    () async {
      final s = v.sample();
      final c = await apply(s);
      s.configureCheckoutQuoteSource(source(s, c, expiry: (_) => v.now));
      await s.requestCheckoutQuote();
      expect(s.checkoutQuote!.status, CheckoutQuoteStatus.stale);
      expect(s.checkoutQuote!.grandTotalVnd, isNull);
    },
  );

  testWidgets(
    'Cart and Review reuse the same quote and selected discount snapshot',
    (t) async {
      t.view.physicalSize = const Size(430, 1600);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      final s = v.sample();
      final c = (await t.runAsync(() => apply(s)))!;
      s.configureCheckoutQuoteSource(source(s, c));
      await t.pumpWidget(CustomerApp(store: s, initialRoute: '/cart'));
      await t.pumpAndSettle();
      final cart = t.widget<CartSummary>(find.byType(CartSummary));
      final q = s.checkoutQuote!;
      expect(cart.quote, same(q));
      expect(cart.subtotal, q.itemsSubtotalVnd);
      expect(cart.discount, q.itemsDiscountVnd);
      final legacy = ForbiddenLegacyReview();
      t
          .state<NavigatorState>(find.byType(Navigator))
          .push(
            MaterialPageRoute<void>(
              settings: const RouteSettings(name: '/order-review'),
              builder: (_) => OrderReviewPage(source: legacy),
            ),
          );
      await t.pumpAndSettle();
      final review = t.widget<OrderReviewPaymentDetails>(
        find.byType(OrderReviewPaymentDetails),
      );
      expect(review.quote, same(q));
      expect(review.totals.subtotal, cart.subtotal);
      expect(review.totals.discount, cart.discount);
      expect(review.totals.total, q.grandTotalVnd);
      expect(legacy.calls, 0);
      expect(
        t
            .widget<ElevatedButton>(
              find.widgetWithText(ElevatedButton, 'Chọn thanh toán'),
            )
            .onPressed,
        isNull,
      );
      expect(t.takeException(), isNull);
    },
  );

  testWidgets(
    'missing shipping in Cart and Review never shows a final amount',
    (t) async {
      final s = v.sample();
      final c = (await t.runAsync(() => apply(s)))!;
      s.configureCheckoutQuoteSource(source(s, c, shipping: false));
      await t.pumpWidget(CustomerApp(store: s, initialRoute: '/cart'));
      await t.pumpAndSettle();
      expect(find.text('Chưa đủ thông tin'), findsOneWidget);
      expect(s.checkoutQuote!.grandTotalVnd, isNull);
      t
          .state<NavigatorState>(find.byType(Navigator))
          .pushNamed('/order-review');
      await t.pumpAndSettle();
      expect(find.byType(OrderReviewPaymentDetails), findsNothing);
      expect(find.text('Chưa đủ thông tin tính tổng tiền'), findsOneWidget);
      expect(s.checkoutNote, isEmpty);
    },
  );
}
