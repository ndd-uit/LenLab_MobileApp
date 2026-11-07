import 'package:lenlab_shared/lenlab_shared.dart';

import 'address_book_actions.dart';

abstract interface class AddressEditorSource {
  Future<AddressRegions> loadRegions();
  Future<Address> save(Address address, {Address? replacing});
}

class MockAddressEditorSource implements AddressEditorSource {
  MockAddressEditorSource(this.store);
  final LenlabStore store;
  Future<void> operation(String name) async {
    store.requireCustomer();
    final session = store.captureSession();
    if (store.repository case final MockLenlabRepository mock) {
      await mock.operation(name);
    } else {
      throw const RepositoryException('Chưa cấu hình dịch vụ địa chỉ.');
    }
    store.requireSession(session);
  }

  @override
  Future<AddressRegions> loadRegions() async {
    store.requireCustomer();
    final actor = store.captureSession();
    await operation('addressEditor');
    store.requireSession(actor);
    final result = <String, Map<String, List<String>>>{
      for (final city in mockAddressRegions.entries)
        city.key: {
          for (final district in city.value.entries)
            district.key: List.of(district.value),
        },
    };
    // Preserve legacy saved locations without silently replacing them.
    for (final address in store.addresses) {
      final wards = (result[address.city] ??= {})[address.district] ??= [];
      if (!wards.contains(address.ward)) wards.add(address.ward);
    }
    return result;
  }

  @override
  Future<Address> save(Address address, {Address? replacing}) async {
    store.requireAddressOwner(address);
    if (replacing != null) store.requireAddressOwner(replacing, saved: true);
    store.requireCustomer();
    final actor = store.captureSession();
    await operation('saveBookAddress');
    store.requireSession(actor);
    if (replacing != null) store.requireAddressOwner(replacing, saved: true);
    final index = replacing == null ? -1 : store.addresses.indexOf(replacing);
    if (replacing != null && index < 0) {
      throw const RepositoryException(
        'Địa chỉ đã thay đổi. Vui lòng quay lại sổ địa chỉ.',
      );
    }
    final saved = Address(
      ownerId: store.requireCustomer().id,
      name: address.name,
      phone: address.phone,
      street: address.street,
      city: address.city,
      district: address.district,
      ward: address.ward,
      isDefault: address.isDefault || (replacing?.isDefault ?? false),
    );
    if (index < 0) {
      store.addresses.add(saved);
    } else {
      store.addresses[index] = saved;
    }
    if (saved.isDefault) markSavedAddressDefault(store.addresses, saved);
    store.changed();
    return saved;
  }
}
