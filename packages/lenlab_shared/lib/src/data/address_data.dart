import '../domain/models.dart';
import 'mock_lenlab_repository.dart';
import '../state/lenlab_store.dart';

typedef AddressRegions = Map<String, Map<String, List<String>>>;

/// UI fixture, not an authoritative administrative-boundary dataset.
const mockAddressRegions = <String, Map<String, List<String>>>{
  'TP. Hồ Chí Minh': {
    'Quận 1': ['Phường Bến Nghé', 'Phường Đa Kao'],
    'Quận 3': ['Phường Võ Thị Sáu'],
  },
  'Hà Nội': {
    'Quận Hoàn Kiếm': ['Phường Hàng Bạc'],
  },
};

class AddressOptions {
  const AddressOptions({required this.regions, required this.saved});
  final AddressRegions regions;
  final List<Address> saved;
}

abstract interface class CheckoutAddressSource {
  Future<AddressOptions> load();
  Future<void> save(Address address, {Address? replacing});
}

class MockCheckoutAddressSource implements CheckoutAddressSource {
  MockCheckoutAddressSource(this.store);
  final LenlabStore store;
  Future<void> _operation(String name) async {
    store.requireCustomer();
    final actor = store.captureSession();
    if (store.repository case final MockLenlabRepository repository) {
      await repository.operation(name);
    }
    store.requireSession(actor);
  }

  @override
  Future<AddressOptions> load() async {
    store.requireCustomer();
    final actor = store.captureSession();
    await _operation('addresses');
    store.requireSession(actor);
    return AddressOptions(
      regions: mockAddressRegions,
      saved: List.of(store.addresses.where((a) => a.ownerId == store.userId)),
    );
  }

  @override
  Future<void> save(Address address, {Address? replacing}) async {
    store.requireAddressOwner(address);
    if (replacing != null) store.requireAddressOwner(replacing, saved: true);
    store.requireCustomer();
    final actor = store.captureSession();
    await _operation('saveAddress');
    store.requireSession(actor);
    if (replacing != null) store.requireAddressOwner(replacing, saved: true);
    final owned = address.ownedBy(store.requireCustomer().id);
    final index = replacing == null ? -1 : store.addresses.indexOf(replacing);
    if (index >= 0) {
      store.addresses[index] = owned;
    } else {
      final duplicate = store.addresses.any(
        (a) =>
            a.name == address.name &&
            a.phone == address.phone &&
            a.full == address.full,
      );
      if (!duplicate) store.addresses.add(owned);
    }
    store.changed();
  }
}
