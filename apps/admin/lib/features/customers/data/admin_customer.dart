enum AdminCustomerRole {
  customer('Khách hàng'),
  staff('Nhân viên');

  const AdminCustomerRole(this.label);
  final String label;
}

enum AdminCustomerStatus {
  active('Hoạt động'),
  blocked('Bị khóa');

  const AdminCustomerStatus(this.label);
  final String label;
}

class AdminCustomer {
  const AdminCustomer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.status,
    this.orderCount,
    this.avatarAlias,
    required this.initials,
  });
  final String id, name, email, phone, initials;
  final AdminCustomerRole role;
  final AdminCustomerStatus status;
  final int? orderCount;
  final String? avatarAlias;
}
