import 'admin_customer.dart';

class AdminCustomerDetail {
  const AdminCustomerDetail({
    required this.customer,
    this.joinedAt,
    this.totalSpent,
    this.membership,
    this.defaultAddress,
  });
  final AdminCustomer customer;
  final DateTime? joinedAt;
  final int? totalSpent;
  final String? membership, defaultAddress;
}
