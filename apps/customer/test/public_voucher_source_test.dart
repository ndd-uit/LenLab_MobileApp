import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_shared/lenlab_shared.dart';
import 'package:lenlab_customer/features/vouchers/data/voucher_source.dart';

PublicVoucherCampaign campaign(
  String id, {
  VoucherPublication publication = VoucherPublication.draft,
}) => PublicVoucherCampaign(
  id: id,
  kind: WalletVoucherKind.cash,
  label: 'Test',
  title: 'Same title',
  description: 'Not an eligibility rule',
  expiry: '01/01/2000',
  publication: publication,
);

class WaitingVouchers extends MockLenlabRepository {
  WaitingVouchers() : super(latency: Duration.zero);
  final entered = Completer<void>(), release = Completer<void>();
  @override
  Future<void> operation(String name) async {
    if (name == 'vouchers') {
      entered.complete();
      await release.future;
    } else {
      await super.operation(name);
    }
  }
}

void main() {
  late LenlabStore s;
  Future<void> login(CustomerIdentity user) async {
    await s.signIn(identity: user.email, password: 'mock');
  }

  setUp(() {
    s = LenlabStore(repository: MockLenlabRepository(latency: Duration.zero));
  });
  tearDown(() => s.dispose());

  test('A B share public campaign IDs and metadata but not usage, including return to A', () async {
    final source = MockVoucherSource(s);
    await login(mockCustomerA);
    final a = await source.load();
    await login(mockCustomerB);
    final b = await source.load();
    expect(b.map((v) => v.id), orderedEquals(a.map((v) => v.id)));
    expect(
      b.map((v) => v.description),
      orderedEquals(a.map((v) => v.description)),
    );
    expect(b.map((v) => v.code), orderedEquals(a.map((v) => v.code)));
    expect(
      a.firstWhere((v) => v.id == 'p2-first').status,
      WalletVoucherStatus.used,
    );
    expect(
      b.firstWhere((v) => v.id == 'p2-first').status,
      WalletVoucherStatus.available,
    );
    await login(mockCustomerA);
    expect(
      (await source.load()).firstWhere((v) => v.id == 'p2-first').status,
      WalletVoucherStatus.used,
    );
    expect(() => b.clear(), throwsUnsupportedError);
  });

  test(
    'hidden and implicit draft campaigns never enter public read list',
    () async {
      await login(mockCustomerA);
      final source = MockVoucherSource(
        s,
        campaigns: [
          campaign('draft'),
          campaign('hidden', publication: VoucherPublication.hidden),
          campaign('public', publication: VoucherPublication.published),
        ],
        usage: const [],
      );
      expect((await source.load()).map((v) => v.id), ['public']);
      expect(
        await MockVoucherSource(s, campaigns: [campaign('draft')]).load(),
        isEmpty,
      );
    },
  );

  test(
    'usage keyed by owner and campaign ID, never matching title or email',
    () async {
      await login(mockCustomerB);
      s.profile.email = mockCustomerA.email;
      final source = MockVoucherSource(
        s,
        campaigns: [
          campaign('one', publication: VoucherPublication.published),
          campaign('two', publication: VoucherPublication.published),
        ],
        usage: const [
          CustomerVoucherUsage(userId: mockCustomerAId, campaignId: 'one'),
          CustomerVoucherUsage(userId: 'customer-demo-b', campaignId: 'two'),
        ],
      );
      final b = await source.load();
      expect(b[0].title, b[1].title);
      expect(b[0].status, WalletVoucherStatus.available);
      expect(b[1].status, WalletVoucherStatus.used);
    },
  );

  test(
    'blank or duplicate campaign IDs rejected instead of name/index fallback',
    () {
      expect(
        () => MockVoucherSource(s, campaigns: [campaign('')]),
        throwsArgumentError,
      );
      expect(
        () => MockVoucherSource(
          s,
          campaigns: [campaign('same'), campaign('same')],
        ),
        throwsArgumentError,
      );
    },
  );

  test(
    'no inferred code, expiry, discount or Admin publication from P2 copy',
    () async {
      await login(mockCustomerB);
      final values = await MockVoucherSource(
        s,
        campaigns: [
          campaign('explicit-demo', publication: VoucherPublication.published),
        ],
      ).load();
      expect(values.single.expiry, '01/01/2000');
      expect(values.single.status, WalletVoucherStatus.available);
      expect(values.single.code, isNull);
      expect(s.coupon, isEmpty);
      expect(s.checkoutDiscount, 0);
    },
  );

  test(
    'Guest public read; read failure and retry do not change cart or checkout',
    () async {
      final source = MockVoucherSource(s);
      final guest = await source.load();
      expect(guest, hasLength(5));
      expect(guest.any((v) => v.status == WalletVoucherStatus.used), isFalse);
      await login(mockCustomerA);
      s.coupon = 'LEN50';
      s.deliveryAddress = s.addresses.single;
      s.checkoutNote = 'Keep note';
      final lines = List.of(s.cart), address = s.deliveryAddress;
      final discount = s.checkoutDiscount, total = s.checkoutSubtotal;
      (s.repository as MockLenlabRepository).failNext('vouchers');
      await expectLater(source.load(), throwsA(isA<RepositoryException>()));
      expect(await source.load(), hasLength(5));
      expect(s.cart, orderedEquals(lines));
      expect(s.coupon, 'LEN50');
      expect(s.deliveryAddress, same(address));
      expect(s.checkoutNote, 'Keep note');
      expect(s.checkoutDiscount, discount);
      expect(s.checkoutSubtotal, total);
      expect(s.orders.length, 4);
    },
  );

  test('pending A read rejected after logout and B login', () async {
    s.dispose();
    final repo = WaitingVouchers();
    s = LenlabStore(
      repository: repo,
      authSource: MockCustomerAuthSource(latency: Duration.zero),
    );
    await login(mockCustomerA);
    final pending = MockVoucherSource(s).load();
    final rejected = expectLater(pending, throwsA(isA<RepositoryException>()));
    await repo.entered.future;
    s.logout();
    await login(mockCustomerB);
    repo.release.complete();
    await rejected;
    expect(s.userId, mockCustomerB.id);
    expect(s.coupon, isEmpty);
  });

  test(
    'new account reads campaigns without assigning personal vouchers',
    () async {
      await s.register(
        name: 'New',
        identity: 'public-voucher@example.com',
        password: 'mock',
      );
      final vouchers = await MockVoucherSource(s).load();
      expect(
        vouchers.map((v) => v.id),
        mockPublicVoucherCampaigns.map((c) => c.id),
      );
      expect(
        vouchers.where((v) => v.status == WalletVoucherStatus.used),
        isEmpty,
      );
      expect(s.coupon, isEmpty);
      expect(s.cart, isEmpty);
      expect(s.orders, isEmpty);
    },
  );
}
