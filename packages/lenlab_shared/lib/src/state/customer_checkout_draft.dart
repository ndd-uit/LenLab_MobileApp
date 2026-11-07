import '../domain/models.dart';

/// Private transient state for one generation, never an account's saved data.
class CustomerCheckoutDraft {
  CustomerCheckoutDraft({required this.ownerId, required this.generation});
  final String? ownerId;
  final int generation;
  Address? address;
  String note = '';
  String? bankReference;
  CheckoutPaymentMethod payment = CheckoutPaymentMethod.cod;
}
