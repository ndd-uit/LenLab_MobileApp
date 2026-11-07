import '../domain/customer_identity.dart';
import '../domain/models.dart';
import 'customer_cart_data.dart';

/// Saved account data in RAM; transient checkout remains session-scoped.
class CustomerAccountData {
  CustomerAccountData(CustomerIdentity user)
    : ownerId = user.id,
      profile = CustomerProfile(
        ownerId: user.id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        gender: '',
        birthday: '',
      );
  CustomerAccountData.fixtureA(String owner)
    : ownerId = owner,
      profile = CustomerProfile(ownerId: owner),
      addresses = [Address(ownerId: owner)];
  final String ownerId;
  final CustomerProfile profile;
  List<Address> addresses = [];
  final orders = <Order>[];
  final favorites = <String>{};
  final customs = <CustomRequest>[];
  final cart = CustomerCartData();
}
