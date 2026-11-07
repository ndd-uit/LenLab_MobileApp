import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_shared/lenlab_shared.dart';
import 'package:lenlab_customer/features/profile/data/profile_editor_source.dart';
import 'package:lenlab_customer/features/profile/data/profile_source.dart';
import 'package:lenlab_customer/features/address_book/data/address_editor_source.dart';
import 'package:lenlab_customer/features/address_book/data/address_book_source.dart';
import 'package:lenlab_customer/features/address_book/data/address_book_actions.dart';

class PendingPrivateRepository extends MockLenlabRepository {
  PendingPrivateRepository(this.blocked) : super(latency: Duration.zero);
  final String blocked;
  final entered = Completer<void>();
  final release = Completer<void>();
  @override
  Future<void> operation(String name) async {
    await super.operation(name);
    if (name == blocked) {
      entered.complete();
      await release.future;
    }
  }
}

void main() {
  for (final next in [mockCustomerA, mockCustomerB]) {
    for (final operation in [
      'profile',
      'profileEditor',
      'saveProfile',
      'addressBook',
      'addressEditor',
      'addresses',
      'saveAddress',
      'saveBookAddress',
      'deleteBookAddress',
      'setDefaultBookAddress',
    ]) {
      test(
        '$operation from A cannot affect ${next.id} in a newer generation',
        () async {
          final repo = PendingPrivateRepository(operation);
          final s = LenlabStore(
            repository: repo,
            authSource: MockCustomerAuthSource(latency: Duration.zero),
          );
          addTearDown(s.dispose);
          await s.signIn(identity: mockCustomerA.email, password: 'mock');
          final aProfile = s.profile;
          final second = const Address(
            ownerId: mockCustomerAId,
            name: 'A private',
            isDefault: false,
          );
          s.addresses.add(second);
          final aAddresses = List.of(s.addresses);
          final pending = switch (operation) {
            'profile' => MockProfileSource(s).load(),
            'profileEditor' => MockProfileEditorSource(s).load(),
            'saveProfile' => MockProfileEditorSource(s).save(
              name: 'Stale write',
              phone: '0901234567',
              gender: 'Nam',
              birthday: '',
            ),
            'addressBook' => MockAddressBookSource(s).load(),
            'addressEditor' => MockAddressEditorSource(s).loadRegions(),
            'addresses' => MockCheckoutAddressSource(s).load(),
            'saveAddress' => MockCheckoutAddressSource(
              s,
            ).save(const Address(name: 'Stale checkout address')),
            'saveBookAddress' => MockAddressEditorSource(
              s,
            ).save(const Address(name: 'Stale address')),
            'deleteBookAddress' => MockAddressBookActions(s).remove(second),
            _ => MockAddressBookActions(s).setDefault(second),
          };
          final rejected = expectLater(
            pending,
            throwsA(isA<RepositoryException>()),
          );
          await repo.entered.future;
          s.logout();
          await s.signIn(identity: next.email, password: 'mock');
          s.profile.email =
              mockCustomerA.email; // Identity must not rely on email.
          repo.release.complete();
          await rejected;
          expect(aProfile.name, mockCustomerA.name);
          expect(
            aAddresses.every((a) => a.ownerId == mockCustomerA.id),
            isTrue,
          );
          expect(s.profile.name, next.name);
          expect(
            s.addresses,
            next.id == mockCustomerA.id ? orderedEquals(aAddresses) : isEmpty,
          );
        },
      );
    }
  }
}
