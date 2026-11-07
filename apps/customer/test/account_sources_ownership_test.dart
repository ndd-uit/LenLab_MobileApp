import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_shared/lenlab_shared.dart';
import 'package:lenlab_customer/features/address_book/data/address_book_actions.dart';
import 'package:lenlab_customer/features/address_book/data/address_editor_source.dart';
import 'package:lenlab_customer/features/profile/data/profile_editor_source.dart';
import 'package:lenlab_customer/features/profile/data/profile_source.dart';
import 'package:lenlab_customer/features/vouchers/data/voucher_source.dart';

void main() {
  LenlabStore sample() =>
      LenlabStore(repository: MockLenlabRepository(latency: Duration.zero));
  Future<void> login(LenlabStore s, CustomerIdentity user) async {
    await s.signIn(identity: user.email, password: 'mock');
  }

  test('B cannot update delete or make default an A address', () async {
    final s = sample();
    addTearDown(s.dispose);
    await login(s, mockCustomerA);
    final original = s.addresses.single;
    await login(s, mockCustomerB);
    await expectLater(
      MockAddressEditorSource(s).save(const Address(), replacing: original),
      throwsA(isA<RepositoryException>()),
    );
    await expectLater(
      MockAddressBookActions(s).remove(original),
      throwsA(isA<RepositoryException>()),
    );
    await expectLater(
      MockAddressBookActions(s).setDefault(original),
      throwsA(isA<RepositoryException>()),
    );
    expect(s.addresses, isEmpty);
    await login(s, mockCustomerA);
    expect(s.addresses.single, same(original));
  });

  test('profile source and save use the current ID even if profile emails coincide', () async {
    final s = sample();
    addTearDown(s.dispose);
    await login(s, mockCustomerA);
    final a = s.profile;
    await login(s, mockCustomerB);
    s.profile.email = a.email;
    await MockProfileEditorSource(s)
        .save(name: 'B edited', phone: '0901234568', gender: '', birthday: '');
    expect((await MockProfileSource(s).load()).name, 'B edited');
    expect(a.name, mockCustomerA.name);
    await login(s, mockCustomerA);
    expect(s.profile, same(a));
  });

  test(
    'public campaigns are shared while A usage is not inherited by B',
    () async {
      final s = sample();
      addTearDown(s.dispose);
      await login(s, mockCustomerA);
      final a = await MockVoucherSource(s).load();
      expect(
        a.firstWhere((v) => v.id == 'p2-first').status,
        WalletVoucherStatus.used,
      );
      await login(s, mockCustomerB);
      final b = await MockVoucherSource(s).load();
      expect(b.map((v) => v.id), orderedEquals(a.map((v) => v.id)));
      expect(
        b.firstWhere((v) => v.id == 'p2-first').status,
        WalletVoucherStatus.available,
      );
    },
  );
}
