import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_shared/lenlab_shared.dart';
import 'package:lenlab_customer/app/customer_app.dart';
import 'package:lenlab_customer/app/customer_scope.dart';
import 'package:lenlab_customer/features/vouchers/data/voucher_source.dart';
import 'package:lenlab_customer/features/vouchers/data/voucher_eligibility_source.dart';
import 'package:lenlab_customer/features/vouchers/presentation/voucher_page.dart';
import 'package:lenlab_customer/features/cart/presentation/cart_page.dart';
import 'package:lenlab_customer/features/checkout/presentation/address_page.dart';

final now = DateTime.utc(2026, 11, 5);
VoucherRules rules({
  VoucherRuleType type = VoucherRuleType.itemsFixed,
  int minimum = 0,
  int amount = 50000,
  int rate = 3333,
  int cap = 50000,
  VoucherLimit global = const VoucherLimit.unlimited(),
  VoucherLimit personal = const VoucherLimit.unlimited(),
  DateTime? start,
  DateTime? end,
}) => VoucherRules(
  type: type,
  minimumVnd: minimum,
  fixedAmountVnd: amount,
  rateBps: rate,
  maxDiscountVnd: cap,
  shippingDiscountVnd: amount,
  globalLimit: global,
  perCustomerLimit: personal,
  startsAt: start ?? now,
  endsAt: end ?? now.add(const Duration(days: 1)),
);

PublicVoucherCampaign demo({
  String id = 'demo',
  String? code,
  VoucherRules? rule,
  VoucherPublication publication = VoucherPublication.published,
  WalletVoucherKind kind = WalletVoucherKind.discount,
}) => PublicVoucherCampaign(
  id: id,
  code: code,
  rules: rule,
  publication: publication,
  kind: kind,
  label: 'DEMO',
  title: 'Demo',
  description: 'Explicit test rules only',
  expiry: '01/01/2000',
); // Label deliberately contradicts the injected clock.

LenlabStore sample({bool guest = false, int price = 45000}) {
  final repo = MockLenlabRepository(latency: Duration.zero);
  final s = LenlabStore(
    repository: repo,
    voucherClock: () => now,
    authSource: MockCustomerAuthSource(latency: Duration.zero),
  );
  if (!guest) s.signedIn = true;
  s.cart.clear();
  final p = repo.catalog.singleWhere((p) => p.id == 'carrot');
  p.price = price;
  s.addToCart(p, 1, 'demo-variant');
  addTearDown(s.dispose);
  return s;
}

MockVoucherEligibilitySource evaluator(
  LenlabStore s,
  List<PublicVoucherCampaign> campaigns, {
  List<CustomerVoucherUsage> usage = const [],
  Map<String, int> global = const {},
  ShippingPreview? shipping,
  ShippingPreviewSource? shippingSource,
  CustomerVoucherUsageSource? usageSource,
}) => MockVoucherEligibilitySource(
  s,
  publicSource: MockPublicCampaignSource(s, campaigns: campaigns),
  usageSource: usageSource ?? MockCustomerVoucherUsageSource(s, usage: usage),
  globalUsedCounts: global,
  clock: () => now,
  shippingSource:
      shippingSource ??
      (shipping == null
          ? null
          : MockShippingPreviewSource(
              s,
              clock: () => now,
              loader: (_) async => shipping,
            )),
);

class ForbiddenUsage implements CustomerVoucherUsageSource {
  int calls = 0;
  @override
  Future<List<CustomerVoucherUsage>> load() async {
    calls++;
    throw StateError('Guest must never load private usage');
  }
}

class WaitingEvaluation implements VoucherEligibilitySource {
  final entered = Completer<VoucherEvaluationContext>();
  final release = Completer<void>();
  int calls = 0;
  bool fail = false;
  @override
  Future<VoucherEvaluation> evaluate(
    VoucherEvaluationContext context, {
    String? campaignId,
    String? code,
  }) async {
    calls++;
    entered.complete(context);
    await release.future;
    if (fail) throw StateError('old failure');
    return VoucherEvaluation(
      status: VoucherEligibilityStatus.eligible,
      reason: 'MOCK_PREVIEW_ONLY',
      campaignId: campaignId,
      contextKey: context.key,
      itemsDiscountVnd: 10000,
    );
  }
}

void main() {
  test(
    'fixed clamp, exact ID without code and no consume or pricing mutation',
    () async {
      final s = sample();
      final campaign = demo(rule: rules());
      final source = evaluator(s, [campaign]);
      final result = await s.evaluateVoucher(source, campaignId: 'demo');
      expect(result!.itemsDiscountVnd, 45000);
      expect(result.shippingDiscountVnd, 0);
      expect(s.appliedVoucher, same(result));
      expect(
        (await s.evaluateVoucher(source, campaignId: ''))!.reason,
        'INVALID_SELECTION',
      );
      expect(s.isEvaluatingVoucher, isFalse);
      expect(s.appliedVoucher, same(result));
      expect(s.coupon, isEmpty);
      expect(s.checkoutDiscount, 0);
      expect(s.orders, hasLength(4));
      expect(
        await MockCustomerVoucherUsageSource(s, usage: []).load(),
        isEmpty,
      );
      expect(
        (await s.evaluateVoucher(source, campaignId: 'demo'))!.status,
        VoucherEligibilityStatus.eligible,
      );
    },
  );

  test('integer percentage floor then cap without floating point', () async {
    final s = sample(price: 301);
    for (final cap in [500, 80]) {
      final r = await s.evaluateVoucher(
        evaluator(s, [
          demo(
            rule: rules(type: VoucherRuleType.itemsPercentage, cap: cap),
          ),
        ]),
        campaignId: 'demo',
      );
      expect(r!.itemsDiscountVnd, cap == 80 ? 80 : 100);
    }
  });

  for (final type in [
    VoucherRuleType.shippingFreeFull,
    VoucherRuleType.shippingDiscountCapped,
  ]) {
    test(
      '$type exact shipping reduction and remaining fee including excluded fee',
      () async {
        final s = sample();
        s.deliveryAddress = s.addresses.single;
        final context = s.captureVoucherContext();
        final source = evaluator(
          s,
          [demo(rule: rules(type: type, amount: 10000))],
          shipping: ShippingPreview.ready(
            session: s.captureSession(),
            contextKey: context.key,
            grossShippingFeeVnd: 45000,
            eligibleShippingFeeVnd: 30000,
          ),
        );
        final r = await s.evaluateVoucher(source, campaignId: 'demo');
        expect(
          r!.shippingDiscountVnd,
          type == VoucherRuleType.shippingFreeFull ? 30000 : 10000,
        );
        expect(
          r.remainingShippingVnd,
          type == VoucherRuleType.shippingFreeFull ? 15000 : 35000,
        );
        expect(r.itemsDiscountVnd, 0);
      },
    );
  }

  test('shipping capped amount cannot exceed eligible fee', () async {
    final s = sample();
    s.deliveryAddress = s.addresses.single;
    final source = evaluator(
      s,
      [demo(rule: rules(type: VoucherRuleType.shippingDiscountCapped))],
      shipping: ShippingPreview.ready(
        session: s.captureSession(),
        contextKey: s.voucherContextKey,
        grossShippingFeeVnd: 30000,
        eligibleShippingFeeVnd: 30000,
      ),
    );
    expect(
      (await s.evaluateVoucher(
        source,
        campaignId: 'demo',
      ))!.shippingDiscountVnd,
      30000,
    );
  });

  test(
    'missing address or shipping fee does not use pricing fixture 30000',
    () async {
      final s = sample();
      final source = evaluator(s, [
        demo(rule: rules(type: VoucherRuleType.shippingFreeFull)),
      ]);
      for (final address in [null, s.addresses.single]) {
        s.deliveryAddress = address;
        final r = await s.evaluateVoucher(source, campaignId: 'demo');
        expect(r!.reason, 'SHIPPING_CONTEXT_REQUIRED');
        expect(r.status, VoucherEligibilityStatus.needsContext);
        expect(s.appliedVoucher, isNull);
      }
    },
  );

  test(
    'minimum counts selected subtotal only and empty selection stays empty',
    () async {
      final s = sample();
      final repo = s.repository as MockLenlabRepository;
      s.addToCart(
        repo.catalog.singleWhere((p) => p.id == 'sweater'),
        1,
        'unselected',
      );
      s.toggleCartLine(s.cart.last);
      final source = evaluator(s, [demo(rule: rules(minimum: 50000))]);
      expect(
        (await s.evaluateVoucher(source, campaignId: 'demo'))!.reason,
        'MINIMUM_NOT_MET',
      );
      s.changeQuantity(s.cart.first, 1);
      expect(
        (await s.evaluateVoucher(source, campaignId: 'demo'))!.status,
        VoucherEligibilityStatus.eligible,
      );
      s.toggleCartLine(s.cart.first);
      expect(
        (await s.evaluateVoucher(source, campaignId: 'demo'))!.reason,
        'EMPTY_SELECTION',
      );
      expect(s.checkoutLines, isEmpty);
      expect(s.appliedVoucher, isNull);
    },
  );

  for (final publication in [
    VoucherPublication.draft,
    VoucherPublication.hidden,
  ]) {
    test('$publication cannot be selected by known ID', () async {
      final s = sample();
      expect(
        (await s.evaluateVoucher(
          evaluator(s, [demo(rule: rules(), publication: publication)]),
          campaignId: 'demo',
        ))!.reason,
        'VOUCHER_NOT_AVAILABLE',
      );
    });
  }

  for (final kind in [WalletVoucherKind.gift, WalletVoucherKind.firstOrder]) {
    test('$kind without approved rules cannot apply', () async {
      final s = sample();
      expect(
        (await s.evaluateVoucher(
          evaluator(s, [demo(kind: kind)]),
          campaignId: 'demo',
        ))!.reason,
        'TYPE_UNSUPPORTED',
      );
      expect(s.appliedVoucher, isNull);
    });
  }

  test(
    'missing typed config and invalid limits do not become unlimited or LEN50',
    () async {
      final s = sample();
      for (final rule in [
        null,
        const VoucherRules(type: VoucherRuleType.itemsFixed),
        rules(global: const VoucherLimit.limited(0)),
        rules(type: VoucherRuleType.itemsPercentage, cap: 0),
      ]) {
        expect(
          (await s.evaluateVoucher(
            evaluator(s, [demo(rule: rule)]),
            campaignId: 'demo',
          ))!.reason,
          'CONFIG_INCOMPLETE',
        );
      }
      expect(s.coupon, isEmpty);
    },
  );

  test('clock uses half-open explicit instants, never date label', () async {
    final s = sample();
    for (final entry in [
      (rules(start: now.add(const Duration(seconds: 1))), 'NOT_STARTED'),
      (
        rules(start: now.subtract(const Duration(days: 1)), end: now),
        'EXPIRED',
      ),
      (rules(), 'MOCK_PREVIEW_ONLY'),
    ]) {
      expect(
        (await s.evaluateVoucher(
          evaluator(s, [demo(rule: entry.$1)]),
          campaignId: 'demo',
        ))!.reason,
        entry.$2,
      );
    }
  });

  test(
    'configured quotas permit multiple uses and enforce both explicit limits',
    () async {
      final s = sample();
      final c = demo(
        rule: rules(
          global: const VoucherLimit.limited(10),
          personal: const VoucherLimit.limited(3),
        ),
      );
      for (final entry in [
        (2, 9, 'MOCK_PREVIEW_ONLY'),
        (3, 9, 'CUSTOMER_LIMIT_REACHED'),
        (0, 10, 'GLOBAL_QUOTA_EXHAUSTED'),
      ]) {
        final source = evaluator(
          s,
          [c],
          global: {'demo': entry.$2},
          usage: [
            CustomerVoucherUsage(
              userId: mockCustomerAId,
              campaignId: 'demo',
              usedCount: entry.$1,
            ),
          ],
        );
        expect(
          (await s.evaluateVoucher(source, campaignId: 'demo'))!.reason,
          entry.$3,
        );
      }
      final unlimited = evaluator(
        s,
        [demo(rule: rules())],
        usage: const [
          CustomerVoucherUsage(
            userId: mockCustomerAId,
            campaignId: 'demo',
            usedCount: 99,
          ),
        ],
      );
      expect(
        (await s.evaluateVoucher(unlimited, campaignId: 'demo'))!.status,
        VoucherEligibilityStatus.eligible,
      );
    },
  );

  test(
    'Guest preview never invokes personal usage or claims final eligibility',
    () async {
      final s = sample(guest: true);
      final private = ForbiddenUsage();
      final c = demo(rule: rules(personal: const VoucherLimit.limited(3)));
      final public = MockPublicCampaignSource(s, campaigns: [c]);
      final wallet = MockVoucherSource(
        s,
        publicSource: public,
        usageSource: private,
      );
      expect(
        (await wallet.load()).single.status,
        WalletVoucherStatus.available,
      );
      final r = await s.evaluateVoucher(
        evaluator(s, [c], usageSource: private),
        campaignId: 'demo',
      );
      expect(r!.reason, 'AUTH_REQUIRED');
      expect(r.itemsDiscountVnd, 45000);
      expect(s.voucherCandidate?.campaignId, 'demo');
      expect(s.appliedVoucher, isNull);
      expect(private.calls, 0);
      await expectLater(
        MockCustomerVoucherUsageSource(s).load(),
        throwsA(isA<RepositoryException>()),
      );
      await s.signIn(identity: mockCustomerA.email, password: 'mock');
      expect(s.voucherCandidate, isNull);
      expect(s.voucherEvaluation, isNull);
    },
  );

  test('wrong code preserves prior valid applied; no inferred code for null-code campaign', () async {
    final s = sample();
    final source = evaluator(s, [
      demo(rule: rules()),
      demo(id: 'coded', code: 'REAL', rule: rules()),
    ]);
    await s.evaluateVoucher(source, campaignId: 'demo');
    final old = s.appliedVoucher;
    expect(
      (await s.evaluateVoucher(source, code: 'Demo'))!.reason,
      'VOUCHER_NOT_AVAILABLE',
    );
    expect(s.appliedVoucher, same(old));
    expect(
      (await s.evaluateVoucher(source, code: 'REAL'))!.campaignId,
      'coded',
    );
  });

  test('no stacking or silent replacement of existing LEN50', () async {
    final s = sample()..coupon = 'LEN50';
    final discount = s.checkoutDiscount;
    expect(
      (await s.evaluateVoucher(
        evaluator(s, [demo(rule: rules())]),
        campaignId: 'demo',
      ))!.reason,
      'LEGACY_COUPON_CONFLICT',
    );
    expect(s.coupon, 'LEN50');
    expect(s.checkoutDiscount, discount);
    expect(s.appliedVoucher, isNull);
    expect(s.requireVoucherCheckoutReady, returnsNormally);
  });

  test(
    'applied mock and stale applied cannot create COD or erase draft',
    () async {
      final s = sample();
      s.deliveryAddress = s.addresses.single;
      s.checkoutNote = 'Keep';
      await s.evaluateVoucher(
        evaluator(s, [demo(rule: rules())]),
        campaignId: 'demo',
      );
      for (final stale in [false, true]) {
        if (stale) s.changeQuantity(s.cart.single, 1);
        expect(s.hasUnquotedVoucherSelection, isTrue);
        await expectLater(
          s.submitCodOrder(
            totals: OrderReviewTotals(
              subtotal: s.checkoutSubtotal,
              discount: 0,
              shipping: 30000,
            ),
          ),
          throwsA(isA<RepositoryException>()),
        );
        expect(s.checkoutNote, 'Keep');
        expect(s.cart, hasLength(1));
        expect(s.orders, hasLength(4));
      }
    },
  );

  for (final change in [
    'quantity-revert',
    'selection',
    'catalog-price',
    'logout',
    'B',
    'same-A',
  ]) {
    test(
      'pending response drops after $change; double tap invokes only one request',
      () async {
        final s = sample();
        final source = WaitingEvaluation();
        final request = s.evaluateVoucher(source, campaignId: 'demo');
        await source.entered.future;
        expect(await s.evaluateVoucher(source, campaignId: 'demo'), isNull);
        expect(source.calls, 1);
        switch (change) {
          case 'quantity-revert':
            s.changeQuantity(s.cart.single, 1);
            s.changeQuantity(s.cart.single, -1);
          case 'selection':
            s.toggleCartLine(s.cart.single);
          case 'catalog-price':
            (s.repository as MockLenlabRepository).catalog.first.price++;
          case 'logout':
            s.logout();
          case 'B':
            await s.signIn(identity: mockCustomerB.email, password: 'mock');
          case 'same-A':
            await s.signIn(identity: mockCustomerA.email, password: 'mock');
        }
        source.release.complete();
        expect(await request, isNull);
        expect(s.appliedVoucher, isNull);
      },
    );
  }

  test(
    'latest request wins after context changes; old success cannot replace it',
    () async {
      final s = sample();
      final old = WaitingEvaluation();
      final first = s.evaluateVoucher(old, campaignId: 'old');
      await old.entered.future;
      s.changeQuantity(s.cart.single, 1);
      final latest = await s.evaluateVoucher(
        evaluator(s, [demo(rule: rules())]),
        campaignId: 'demo',
      );
      old.release.complete();
      expect(await first, isNull);
      expect(s.appliedVoucher, same(latest));
      expect(s.voucherCandidate?.campaignId, 'demo');
    },
  );

  test(
    'validity expiry invalidates applied preview without becoming a quote TTL',
    () async {
      var clock = now;
      final repo = MockLenlabRepository(latency: Duration.zero);
      final s = LenlabStore(repository: repo, voucherClock: () => clock)
        ..signedIn = true;
      addTearDown(s.dispose);
      final r = rules(end: now.add(const Duration(minutes: 2)));
      await s.evaluateVoucher(
        evaluator(s, [demo(rule: r)]),
        campaignId: 'demo',
      );
      expect(s.appliedVoucher, isNotNull);
      clock = r.endsAt!;
      expect(s.appliedVoucher, isNull);
      expect(s.hasUnquotedVoucherSelection, isTrue);
      expect(
        s.requireVoucherCheckoutReady,
        throwsA(isA<RepositoryException>()),
      );
    },
  );

  test('late failure after logout and caller cancellation do not apply or overwrite', () async {
    final s = sample();
    final source = WaitingEvaluation()..fail = true;
    final request = s.evaluateVoucher(source, campaignId: 'demo');
    await source.entered.future;
    s.logout();
    source.release.complete();
    expect(await request, isNull);
    await s.signIn(identity: mockCustomerA.email, password: 'mock');
    final cancelled = WaitingEvaluation();
    var mounted = true;
    final pending = s.evaluateVoucher(
      cancelled,
      campaignId: 'demo',
      canApply: () => mounted,
    );
    await cancelled.entered.future;
    mounted = false;
    cancelled.release.complete();
    expect(await pending, isNull);
    expect(s.appliedVoucher, isNull);
    expect(s.isEvaluatingVoucher, isFalse);
  });

  test('private usage from foreign principal is rejected; exhausted global config explicit', () async {
    final s = sample();
    final private = _ForeignUsage();
    expect(
      (await s.evaluateVoucher(
        evaluator(s, [demo(rule: rules())], usageSource: private),
        campaignId: 'demo',
      ))!.reason,
      'USAGE_UNAVAILABLE',
    );
    expect(
      (await s.evaluateVoucher(
        evaluator(s, [
          demo(rule: rules(global: const VoucherLimit.limited(3))),
        ]),
        campaignId: 'demo',
      ))!.reason,
      'CONFIG_INCOMPLETE',
    );
  });

  testWidgets('Guest direct wallet public; A B Guest usage does not leak', (
    t,
  ) async {
    final s = sample(guest: true);
    await t.pumpWidget(CustomerApp(store: s, initialRoute: '/vouchers'));
    await t.pumpAndSettle();
    expect(find.text('LEN20'), findsOneWidget);
    expect(find.text('Đã dùng'), findsNothing);
    await t.runAsync(
      () => s.signIn(identity: mockCustomerA.email, password: 'mock'),
    );
    await t.pumpAndSettle();
    expect(find.text('Đã dùng'), findsOneWidget);
    await t.runAsync(
      () => s.signIn(identity: mockCustomerB.email, password: 'mock'),
    );
    await t.pumpAndSettle();
    expect(find.text('Đã dùng'), findsNothing);
    s.logout();
    await t.pumpAndSettle();
    expect(find.text('LEN20'), findsOneWidget);
    expect(find.text('Đã dùng'), findsNothing);
  });

  testWidgets(
    'typed campaign used before but remaining uses is selectable by ID',
    (t) async {
      final s = sample();
      final c = demo(rule: rules(personal: const VoucherLimit.limited(3)));
      const usage = [
        CustomerVoucherUsage(userId: mockCustomerAId, campaignId: 'demo'),
      ];
      await t.pumpWidget(
        CustomerScope(
          store: s,
          child: MaterialApp(
            theme: P2.theme(),
            routes: {
              '/cart': (_) => const CartPage(),
              '/checkout': (_) => const AddressPage(),
            },
            home: VoucherPage(
              source: MockVoucherSource(s, campaigns: [c], usage: usage),
              eligibilitySource: evaluator(s, [c], usage: usage),
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      expect(find.text('Đã dùng'), findsNothing);
      await t.tap(find.text('Dùng ngay'));
      await t.pumpAndSettle();
      expect(s.appliedVoucher?.campaignId, 'demo');
      expect(s.checkoutDiscount, 0);
      expect(find.byType(CartPage), findsOneWidget);
      await t.tap(find.text('Thanh toán'));
      await t.pumpAndSettle();
      expect(find.byType(AddressPage), findsOneWidget);
      expect(s.orders, hasLength(4));
    },
  );

  testWidgets(
    'Back while evaluation is pending does not apply or navigate later',
    (t) async {
      final s = sample();
      final source = WaitingEvaluation();
      final c = demo(rule: rules());
      await t.pumpWidget(
        CustomerScope(
          store: s,
          child: MaterialApp(
            theme: P2.theme(),
            routes: {
              '/vouchers': (_) => VoucherPage(
                source: MockVoucherSource(s, campaigns: [c]),
                eligibilitySource: source,
              ),
            },
            home: const Scaffold(body: Text('Public')),
          ),
        ),
      );
      final navigator = t.state<NavigatorState>(find.byType(Navigator));
      navigator.pushNamed('/vouchers');
      await t.pumpAndSettle();
      await t.tap(find.text('Dùng ngay'));
      await t.pump();
      expect(source.calls, 1);
      navigator.pop();
      await t.pumpAndSettle();
      source.release.complete();
      await t.pumpAndSettle();
      expect(s.appliedVoucher, isNull);
      expect(find.text('Public'), findsOneWidget);
      expect(t.takeException(), isNull);
    },
  );
}

class _ForeignUsage implements CustomerVoucherUsageSource {
  @override
  Future<List<CustomerVoucherUsage>> load() async => const [
    CustomerVoucherUsage(userId: 'customer-demo-b', campaignId: 'demo'),
  ];
}
