import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

final now = DateTime.utc(2026, 11, 5);
LenlabStore sample({bool guest = false, bool address = true}) {
  final repo = MockLenlabRepository(latency: Duration.zero);
  final s = LenlabStore(
    repository: repo,
    authSource: MockCustomerAuthSource(latency: Duration.zero),
  );
  if (!guest) {
    s.signedIn = true;
    if (address) s.deliveryAddress = s.addresses.single;
  } else {
    s.addToCart(repo.catalog.singleWhere((p) => p.id == 'carrot'), 1, 'Guest');
  }
  addTearDown(s.dispose);
  return s;
}

ShippingPreview ready(
  VoucherEvaluationContext c, {
  int gross = 17000,
  int eligible = 12000,
  DateTime? until,
  int? version,
}) => ShippingPreview.ready(
  contextKey: c.key,
  session: c.session,
  grossShippingFeeVnd: gross,
  eligibleShippingFeeVnd: eligible,
  validUntil: until,
  sourceVersion: version,
);

void main() {
  test(
    'READY has immutable explicit fees and optional metadata, no default TTL',
    () async {
      final s = sample();
      var calls = 0;
      final source = MockShippingPreviewSource(
        s,
        clock: () => now,
        loader: (c) async {
          calls++;
          return ready(c, version: 7);
        },
      );
      final c = s.captureVoucherContext();
      final first = source.load(c), duplicate = source.load(c);
      expect(identical(first, duplicate), isTrue);
      final p = await first;
      expect(p.status, ShippingPreviewStatus.ready);
      expect(p.grossShippingFeeVnd, 17000);
      expect(p.eligibleShippingFeeVnd, 12000);
      expect(p.sourceVersion, 7);
      expect(p.validUntil, isNull);
      expect(await source.load(c), same(p));
      expect(source.currentPreview, same(p));
      expect(calls, 1);
    },
  );

  test(
    'known free shipping fee is READY zero, missing/error amounts are null',
    () async {
      final s = sample();
      final c = s.captureVoucherContext();
      final source = MockShippingPreviewSource(
        s,
        loader: (c) async => ready(c, gross: 0, eligible: 0),
      );
      final zero = await source.load(c);
      expect(zero.status, ShippingPreviewStatus.ready);
      expect(zero.grossShippingFeeVnd, 0);
      for (final p in [
        ShippingPreview.needsContext(
          contextKey: c.key,
          session: c.session,
          reason: 'ADDRESS_REQUIRED',
        ),
        ShippingPreview.error(
          contextKey: c.key,
          session: c.session,
          reason: 'SHIPPING_UNAVAILABLE',
        ),
      ]) {
        expect(p.grossShippingFeeVnd, isNull);
        expect(p.eligibleShippingFeeVnd, isNull);
      }
    },
  );

  for (final pair in [(-1, 0), (17000, -1), (12000, 17000)]) {
    test(
      'invalid gross/eligible $pair cannot produce READY or a fallback fee',
      () async {
        final s = sample();
        final c = s.captureVoucherContext();
        expect(
          () => ready(c, gross: pair.$1, eligible: pair.$2),
          throwsArgumentError,
        );
        final source = MockShippingPreviewSource(
          s,
          loader: (c) async => ready(c, gross: pair.$1, eligible: pair.$2),
        );
        final p = await source.load(c);
        expect(p.status, ShippingPreviewStatus.error);
        expect(p.reason, 'INVALID_SHIPPING_FEE');
        expect(p.grossShippingFeeVnd, isNull);
        expect(source.currentPreview, isNull);
      },
    );
  }

  test(
    'missing address and empty selection do not invoke the fee loader',
    () async {
      final s = sample(address: false);
      var calls = 0;
      final source = MockShippingPreviewSource(
        s,
        loader: (c) async {
          calls++;
          return ready(c);
        },
      );
      final missing = await source.load(s.captureVoucherContext());
      expect(missing.status, ShippingPreviewStatus.needsContext);
      expect(missing.reason, 'ADDRESS_REQUIRED');
      expect(missing.grossShippingFeeVnd, isNull);
      s.deliveryAddress = s.addresses.single;
      for (final line in s.cart) {
        s.toggleCartLine(line);
      }
      expect(
        (await source.load(s.captureVoucherContext())).reason,
        'EMPTY_SELECTION',
      );
      expect(calls, 0);
    },
  );

  test(
    'ERROR retry succeeds and force error never falls back to an older READY',
    () async {
      final s = sample();
      var calls = 0;
      final source = MockShippingPreviewSource(
        s,
        loader: (c) async {
          calls++;
          if (calls == 1 || calls == 3) throw StateError('fee service failed');
          return ready(c);
        },
      );
      final c = s.captureVoucherContext();
      expect((await source.load(c)).status, ShippingPreviewStatus.error);
      final p = await source.load(c);
      expect(p.status, ShippingPreviewStatus.ready);
      final error = await source.load(c, force: true);
      expect(error.reason, 'SHIPPING_UNAVAILABLE');
      expect(error.grossShippingFeeVnd, isNull);
      expect(source.currentPreview, isNull);
      expect((await source.load(c)).status, ShippingPreviewStatus.ready);
      expect(calls, 4);
    },
  );

  for (final change in [
    'quantity',
    'selection',
    'address',
    'quantity-ABA',
    'logout',
    'B',
    'same-A',
  ]) {
    test(
      '$change invalidates cached and delayed preview without writing old fees',
      () async {
        final s = sample();
        final release = Completer<ShippingPreview>();
        var calls = 0;
        final source = MockShippingPreviewSource(
          s,
          loader: (c) async {
            calls++;
            return calls == 1 ? ready(c) : release.future;
          },
        );
        final c = s.captureVoucherContext();
        await source.load(c);
        final pending = source.load(c, force: true);
        switch (change) {
          case 'quantity':
            s.changeQuantity(s.cart.first, 1);
          case 'selection':
            s.toggleCartLine(s.cart.first);
          case 'address':
            s.deliveryAddress = const Address(
              ownerId: mockCustomerAId,
              street: 'New street',
            );
          case 'quantity-ABA':
            s.changeQuantity(s.cart.first, 1);
            s.changeQuantity(s.cart.first, -1);
          case 'logout':
            s.logout();
          case 'B':
            await s.signIn(identity: mockCustomerB.email, password: 'mock');
          case 'same-A':
            await s.signIn(identity: mockCustomerA.email, password: 'mock');
        }
        expect(source.currentPreview, isNull);
        release.complete(ready(c));
        final stale = await pending;
        expect(stale.status, ShippingPreviewStatus.error);
        expect(stale.reason, 'SHIPPING_CONTEXT_CHANGED');
        expect(stale.grossShippingFeeVnd, isNull);
        expect(source.currentPreview, isNull);
      },
    );
  }

  test('A delayed response/finally cannot overwrite B or clear the pending B Future', () async {
    final s = sample();
    final requests = <VoucherEvaluationContext>[],
        releases = <Completer<ShippingPreview>>[];
    final source = MockShippingPreviewSource(
      s,
      loader: (c) {
        requests.add(c);
        final release = Completer<ShippingPreview>();
        releases.add(release);
        return release.future;
      },
    );
    final a = source.load(s.captureVoucherContext());
    await Future<void>.delayed(Duration.zero);
    await s.signIn(identity: mockCustomerB.email, password: 'mock');
    final repo = s.repository as MockLenlabRepository;
    s.addToCart(repo.catalog.singleWhere((p) => p.id == 'carrot'), 1, 'B');
    s.deliveryAddress = const Address(
      ownerId: 'customer-demo-b',
      street: 'B street',
    );
    final contextB = s.captureVoucherContext();
    final b = source.load(contextB);
    await Future<void>.delayed(Duration.zero);
    releases.first.complete(ready(requests.first));
    expect((await a).status, ShippingPreviewStatus.error);
    expect(source.load(contextB), same(b));
    expect(releases, hasLength(2));
    releases.last.complete(ready(requests.last, gross: 27000));
    final resultB = await b;
    expect(resultB.session.userId, 'customer-demo-b');
    expect(resultB.grossShippingFeeVnd, 27000);
    expect(source.currentPreview, same(resultB));
  });

  test('force latest request wins even for identical context', () async {
    final s = sample();
    final releases = <Completer<ShippingPreview>>[];
    final source = MockShippingPreviewSource(
      s,
      loader: (c) {
        final release = Completer<ShippingPreview>();
        releases.add(release);
        return release.future;
      },
    );
    final c = s.captureVoucherContext();
    final first = source.load(c), second = source.load(c, force: true);
    releases[1].complete(ready(c, gross: 27000));
    final latest = await second;
    releases[0].complete(ready(c));
    expect((await first).status, ShippingPreviewStatus.error);
    expect(source.currentPreview, same(latest));
  });

  test('Guest cannot replay A address/context or fake a selected shipping snapshot', () async {
    final s = sample();
    final a = s.captureVoucherContext();
    var calls = 0;
    final source = MockShippingPreviewSource(
      s,
      loader: (c) async {
        calls++;
        return ready(c);
      },
    );
    await source.load(a);
    s.logout();
    final repo = s.repository as MockLenlabRepository;
    s.addToCart(repo.catalog.singleWhere((p) => p.id == 'carrot'), 1, 'Guest');
    final guest = s.captureVoucherContext();
    expect(source.currentPreview, isNull);
    expect((await source.load(a)).reason, 'SHIPPING_CONTEXT_CHANGED');
    expect((await source.load(guest)).reason, 'ADDRESS_REQUIRED');
    final forged = VoucherEvaluationContext(
      session: guest.session,
      key: guest.key,
      lines: guest.lines,
      hasAddress: true,
      legacyCoupon: guest.legacyCoupon,
    );
    expect((await source.load(forged)).reason, 'SHIPPING_CONTEXT_CHANGED');
    expect(calls, 1);
    expect(s.deliveryAddress, isNull);
  });

  test(
    'foreign response stamp is rejected, not cached as current owner',
    () async {
      final s = sample();
      final source = MockShippingPreviewSource(
        s,
        loader: (c) async => ShippingPreview.ready(
          contextKey: c.key,
          session: const CustomerSessionStamp(
            userId: 'customer-demo-b',
            generation: 1,
          ),
          grossShippingFeeVnd: 17000,
          eligibleShippingFeeVnd: 12000,
        ),
      );
      expect(
        (await source.load(s.captureVoucherContext())).reason,
        'SHIPPING_CONTEXT_CHANGED',
      );
      expect(source.currentPreview, isNull);
    },
  );

  test('supplied expiry is honored and expired data does not create a TTL fallback', () async {
    final s = sample();
    var clock = now;
    var end = now.add(const Duration(seconds: 10));
    var calls = 0;
    final source = MockShippingPreviewSource(
      s,
      clock: () => clock,
      loader: (c) async {
        calls++;
        return ready(c, until: end);
      },
    );
    final c = s.captureVoucherContext();
    await source.load(c);
    clock = end;
    expect(source.currentPreview, isNull);
    final expired = await source.load(c);
    expect(expired.reason, 'SHIPPING_PREVIEW_EXPIRED');
    expect(expired.grossShippingFeeVnd, isNull);
    end = clock.add(const Duration(seconds: 20));
    expect((await source.load(c)).validUntil, end);
    expect(calls, 3);
  });
}
