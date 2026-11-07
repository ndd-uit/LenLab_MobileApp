import 'package:lenlab_shared/lenlab_shared.dart';

abstract interface class AddressBookActions {
  Future<List<Address>> remove(Address address);
  Future<List<Address>> setDefault(Address address);
}

/// Saved-book flags only. Checkout drafts and order snapshots stay untouched.
void markSavedAddressDefault(List<Address> addresses, Address selected) {
  for (var i = 0; i < addresses.length; i++) {
    final address = addresses[i];
    final isDefault = identical(address, selected);
    if (address.isDefault == isDefault) continue;
    addresses[i] = Address(
      ownerId: address.ownerId,
      name: address.name,
      phone: address.phone,
      street: address.street,
      city: address.city,
      district: address.district,
      ward: address.ward,
      isDefault: isDefault,
    );
  }
}

class MockAddressBookActions implements AddressBookActions {
  MockAddressBookActions(this.store);
  final LenlabStore store;

  Future<void> operation(String name) async {
    store.requireCustomer();
    final session = store.captureSession();
    if (store.repository case final MockLenlabRepository mock) {
      await mock.operation(name);
    } else {
      throw const RepositoryException('Chưa cấu hình thao tác sổ địa chỉ.');
    }
    store.requireSession(session);
  }

  int indexOf(Address address) {
    store.requireAddressOwner(address, saved: true);
    final index = store.addresses.indexOf(address);
    if (index < 0) {
      throw const RepositoryException(
        'Địa chỉ đã thay đổi. Vui lòng tải lại sổ địa chỉ.',
      );
    }
    return index;
  }

  @override
  Future<List<Address>> remove(Address address) async {
    store.requireCustomer();
    final actor = store.captureSession();
    await operation('deleteBookAddress');
    store.requireSession(actor);
    final index = indexOf(address);
    if (store.addresses[index].isDefault) {
      throw const RepositoryException(
        'Hãy đặt địa chỉ khác làm mặc định trước khi xóa địa chỉ này.',
      );
    }
    store.addresses.removeAt(index);
    store.changed();
    return List.unmodifiable(store.addresses);
  }

  @override
  Future<List<Address>> setDefault(Address address) async {
    store.requireCustomer();
    final actor = store.captureSession();
    await operation('setDefaultBookAddress');
    store.requireSession(actor);
    indexOf(address);
    markSavedAddressDefault(store.addresses, address);
    store.changed();
    return List.unmodifiable(store.addresses);
  }
}
