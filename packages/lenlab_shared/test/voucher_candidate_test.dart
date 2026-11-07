import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

LenlabStore sample() => LenlabStore(
  repository: MockLenlabRepository(latency: Duration.zero),
  authSource: MockCustomerAuthSource(latency: Duration.zero),
);

void main() {
  test('candidate is an ID intent only, without cart or pricing effects', () {
    final s = sample()..signedIn = true;
    addTearDown(s.dispose);
    s.coupon = 'LEN50';
    s.toggleCartLine(s.cart.first);
    s.deliveryAddress = s.addresses.single;
    s.checkoutNote = 'Keep note';
    final lines = s.cart.toList();
    final selected = s.checkoutLines.map((line) => line.key).toList();
    final address = s.deliveryAddress;
    final amounts = [s.checkoutSubtotal, s.checkoutDiscount, s.discount];
    final orders = s.orders.toList();
    s.selectVoucherCandidate(
      'campaign-without-code',
      session: s.captureSession(),
    );
    expect(s.voucherCandidate?.campaignId, 'campaign-without-code');
    expect(s.voucherCandidate?.session.userId, mockCustomerAId);
    expect(s.cart, orderedEquals(lines));
    expect(s.checkoutLines.map((line) => line.key), selected);
    expect(s.deliveryAddress, same(address));
    expect(s.checkoutNote, 'Keep note');
    expect(s.coupon, 'LEN50');
    expect([s.checkoutSubtotal, s.checkoutDiscount, s.discount], amounts);
    expect(s.orders, orderedEquals(orders));
  });

  test('Guest candidate allowed; stale callers and blank ID rejected', () {
    final s = sample();
    addTearDown(s.dispose);
    final guest = s.captureSession();
    s.selectVoucherCandidate('campaign', session: guest);
    expect(s.voucherCandidate?.campaignId, 'campaign');
    s.signedIn = true;
    expect(
      () => s.selectVoucherCandidate('campaign', session: guest),
      throwsA(isA<RepositoryException>()),
    );
    expect(
      () => s.selectVoucherCandidate('  ', session: s.captureSession()),
      throwsA(isA<RepositoryException>()),
    );
    expect(s.voucherCandidate, isNull);
  });

  test(
    'logout and A B A clear candidate, even with same user generation',
    () async {
      final s = sample()..signedIn = true;
      addTearDown(s.dispose);
      final old = s.captureSession();
      s.selectVoucherCandidate('A-campaign', session: old);
      await s.signIn(identity: mockCustomerB.email, password: 'mock');
      expect(s.voucherCandidate, isNull);
      s.selectVoucherCandidate('B-campaign', session: s.captureSession());
      await s.signIn(identity: mockCustomerA.email, password: 'mock');
      expect(s.voucherCandidate, isNull);
      expect(
        () => s.selectVoucherCandidate('stale', session: old),
        throwsA(isA<RepositoryException>()),
      );
      s.selectVoucherCandidate('A-new', session: s.captureSession());
      s.logout();
      expect(s.voucherCandidate, isNull);
      await s.signIn(identity: mockCustomerA.email, password: 'mock');
      expect(s.voucherCandidate, isNull);
      s.selectVoucherCandidate('same-user', session: s.captureSession());
      await s.signIn(identity: mockCustomerA.email, password: 'mock');
      expect(s.voucherCandidate, isNull);
    },
  );

  test('failed auth preserves current intent and applied coupon', () async {
    final s = sample()..signedIn = true;
    addTearDown(s.dispose);
    s.coupon = 'LEN50';
    s.selectVoucherCandidate('campaign', session: s.captureSession());
    final candidate = s.voucherCandidate;
    await expectLater(
      s.signIn(identity: 'unknown@example.com', password: 'mock'),
      throwsA(isA<RepositoryException>()),
    );
    expect(s.voucherCandidate, same(candidate));
    expect(s.coupon, 'LEN50');
  });

  test('candidate is RAM-only; disposed Store rejects retained requests', () {
    final s = sample()..signedIn = true;
    final stamp = s.captureSession();
    s.selectVoucherCandidate('campaign', session: stamp);
    s.dispose();
    expect(s.voucherCandidate, isNull);
    expect(
      () => s.selectVoucherCandidate('old', session: stamp),
      throwsA(isA<RepositoryException>()),
    );
    final fresh = sample()..signedIn = true;
    addTearDown(fresh.dispose);
    expect(fresh.voucherCandidate, isNull);
  });
}
