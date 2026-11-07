import 'package:lenlab_shared/lenlab_shared.dart';

abstract interface class AddressBookSource {
  Future<List<Address>> load();
}

/// Shares saved addresses with checkout, never its current delivery draft.
class MockAddressBookSource implements AddressBookSource {
  MockAddressBookSource(this.store);
  final LenlabStore store;
  @override
  Future<List<Address>> load() async {
    store.requireCustomer();
    final actor = store.captureSession();
    if (store.repository case final MockLenlabRepository mock) {
      await mock.operation('addressBook');
    } else {
      throw const RepositoryException('Chưa cấu hình nguồn sổ địa chỉ.');
    }
    store.requireSession(actor);
    return List<Address>.unmodifiable(
      store.addresses.where((a) => a.ownerId == store.userId),
    );
  }
}
