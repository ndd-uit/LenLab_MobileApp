import 'admin_customer.dart';
import 'admin_customer_detail.dart';
export 'admin_customer.dart';

class AdminCustomersQuery {
  const AdminCustomersQuery({
    this.search = '',
    this.role,
    this.status,
    this.page = 1,
  });
  static const pageSize = 4;
  final String search;
  final AdminCustomerRole? role;
  final AdminCustomerStatus? status;
  final int page;
}

class AdminCustomersResult {
  AdminCustomersResult({
    required List<AdminCustomer> items,
    required this.total,
    required this.page,
  }) : items = List.unmodifiable(items);
  final List<AdminCustomer> items;
  final int total, page;
  int get pages => (total / AdminCustomersQuery.pageSize).ceil();
  int get start =>
      total == 0 ? 0 : (page - 1) * AdminCustomersQuery.pageSize + 1;
  int get end => total == 0 ? 0 : start + items.length - 1;
}

abstract interface class AdminCustomersSource {
  Future<AdminCustomersResult> fetch(AdminCustomersQuery query);
  Future<AdminCustomerDetail?> detail(String id);
}

class MockAdminCustomersSource implements AdminCustomersSource {
  MockAdminCustomersSource({
    this.latency = const Duration(milliseconds: 300),
    List<AdminCustomer>? customers,
  }) : customers = List.unmodifiable(customers ?? adminCustomerFixtures);
  final Duration latency;
  final List<AdminCustomer> customers;
  bool failNext = false;

  @override
  Future<AdminCustomerDetail?> detail(String id) async {
    await Future<void>.delayed(latency);
    if (failNext) {
      failNext = false;
      throw StateError('Mock customer detail unavailable');
    }
    for (final customer in customers) {
      if (customer.id == id) return AdminCustomerDetail(customer: customer);
    }
    return null;
  }

  @override
  Future<AdminCustomersResult> fetch(AdminCustomersQuery query) async {
    await Future<void>.delayed(latency);
    if (failNext) {
      failNext = false;
      throw StateError('Mock customers unavailable');
    }
    final search = query.search.trim().toLowerCase();
    final phoneSearch = search.replaceAll(RegExp(r'[\s()+.\-]'), '');
    final isPhone = RegExp(r'^\d+$').hasMatch(phoneSearch);
    final matching = customers
        .where(
          (customer) =>
              (search.isEmpty ||
                  customer.name.toLowerCase().contains(search) ||
                  customer.email.toLowerCase().contains(search) ||
                  (isPhone &&
                      customer.phone
                          .replaceAll(RegExp(r'\D'), '')
                          .contains(phoneSearch))) &&
              (query.role == null || customer.role == query.role) &&
              (query.status == null || customer.status == query.status),
        )
        .toList();
    final pages = (matching.length / AdminCustomersQuery.pageSize).ceil();
    final page = pages == 0 ? 1 : query.page.clamp(1, pages);
    return AdminCustomersResult(
      items: matching
          .skip((page - 1) * AdminCustomersQuery.pageSize)
          .take(AdminCustomersQuery.pageSize)
          .toList(),
      total: matching.length,
      page: page,
    );
  }
}

final adminCustomerFixtures = List<AdminCustomer>.unmodifiable([
  const AdminCustomer(
    id: 'USR-001',
    name: 'Nguyễn Văn Huy',
    email: 'huy.nguyen@example.com',
    phone: '0912 345 678',
    role: AdminCustomerRole.customer,
    status: AdminCustomerStatus.active,
    orderCount: 5,
    initials: 'NH',
  ),
  const AdminCustomer(
    id: 'USR-002',
    name: 'Trần Thị Linh',
    email: 'linh.tran@lenlab.vn',
    phone: '0987 654 321',
    role: AdminCustomerRole.staff,
    status: AdminCustomerStatus.active,
    avatarAlias: 'imgAvatar',
    initials: 'TL',
  ),
  const AdminCustomer(
    id: 'USR-003',
    name: 'Lê Tuấn Anh',
    email: 'tuananh.le@example.com',
    phone: '0909 000 111',
    role: AdminCustomerRole.customer,
    status: AdminCustomerStatus.blocked,
    orderCount: 1,
    initials: 'LA',
  ),
  const AdminCustomer(
    id: 'USR-004',
    name: 'Phạm Thị Mai',
    email: 'mai.pham@example.com',
    phone: '0933 888 999',
    role: AdminCustomerRole.customer,
    status: AdminCustomerStatus.active,
    orderCount: 12,
    avatarAlias: 'imgAvatar1',
    initials: 'PM',
  ),
  // Explicit extra records only for exercising pagination; no real users created.
  for (var i = 5; i <= 10; i++)
    AdminCustomer(
      id: 'DEMO-USR-${i.toString().padLeft(3, '0')}',
      name: 'Người dùng minh họa $i',
      email: 'demo$i@example.com',
      phone: 'Chưa có SĐT',
      role: i % 3 == 0 ? AdminCustomerRole.staff : AdminCustomerRole.customer,
      status: i.isEven
          ? AdminCustomerStatus.active
          : AdminCustomerStatus.blocked,
      initials: 'MH',
    ),
]);
