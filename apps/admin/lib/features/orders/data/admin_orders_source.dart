import 'admin_order_detail.dart';

import 'admin_order_summary.dart';
export 'admin_order_summary.dart';

class AdminOrdersQuery {
  const AdminOrdersQuery({
    this.search = '',
    this.status,
    this.payment,
    this.page = 1,
  });
  static const pageSize = 5;
  final String search;
  final AdminOrderStatus? status;
  final AdminOrderPayment? payment;
  final int page;
}

class AdminOrdersResult {
  AdminOrdersResult({
    required List<AdminOrderSummary> items,
    required this.total,
    required this.page,
  }) : items = List.unmodifiable(items);
  final List<AdminOrderSummary> items;
  final int total, page;
  int get pages => (total / AdminOrdersQuery.pageSize).ceil();
  int get start => total == 0 ? 0 : (page - 1) * AdminOrdersQuery.pageSize + 1;
  int get end => total == 0 ? 0 : start + items.length - 1;
}

abstract interface class AdminOrdersSource {
  Future<AdminOrdersResult> fetch(AdminOrdersQuery query);
  Future<AdminOrderDetail?> detail(String id);
}

class MockAdminOrdersSource implements AdminOrdersSource {
  MockAdminOrdersSource({
    this.latency = const Duration(milliseconds: 300),
    List<AdminOrderSummary>? orders,
  }) : orders = List.unmodifiable(orders ?? adminOrderFixtures);
  final Duration latency;
  final List<AdminOrderSummary> orders;
  bool failNext = false;

  @override
  Future<AdminOrderDetail?> detail(String id) async {
    await Future<void>.delayed(latency);
    if (failNext) {
      failNext = false;
      throw StateError('Mock order detail unavailable');
    }
    for (final order in orders) {
      if (order.id == id) return mockAdminOrderDetail(order);
    }
    return null;
  }

  @override
  Future<AdminOrdersResult> fetch(AdminOrdersQuery query) async {
    await Future<void>.delayed(latency);
    if (failNext) {
      failNext = false;
      throw StateError('Mock orders unavailable');
    }
    final search = query.search.trim().toLowerCase();
    final matching = orders
        .where(
          (order) =>
              (search.isEmpty ||
                  '#${order.id}'.toLowerCase().contains(search) ||
                  order.customerName.toLowerCase().contains(search)) &&
              (query.status == null || order.status == query.status) &&
              (query.payment == null || order.payment == query.payment),
        )
        .toList();
    // Preserve source order; do not infer missing timestamps or a sorting policy.
    final pages = (matching.length / AdminOrdersQuery.pageSize).ceil();
    final page = pages == 0 ? 1 : query.page.clamp(1, pages);
    return AdminOrdersResult(
      items: matching
          .skip((page - 1) * AdminOrdersQuery.pageSize)
          .take(AdminOrdersQuery.pageSize)
          .toList(),
      total: matching.length,
      page: page,
    );
  }
}

final adminOrderFixtures = List<AdminOrderSummary>.unmodifiable([
  AdminOrderSummary(
    id: 'ORD-202501',
    customerName: 'Nguyễn Văn A',
    phone: '0901234567',
    placedAt: DateTime(2023, 10, 20),
    total: 250000,
    payment: AdminOrderPayment.cod,
    status: AdminOrderStatus.pending,
    note: 'Giao giờ hành chính...',
  ),
  AdminOrderSummary(
    id: 'ORD-202502',
    customerName: 'Trần Thị B',
    phone: '0912345678',
    placedAt: DateTime(2023, 10, 19),
    total: 500000,
    payment: AdminOrderPayment.bankTransfer,
    status: AdminOrderStatus.shipping,
    note: 'Gói quà cẩn thận...',
  ),
  AdminOrderSummary(
    id: 'ORD-202503',
    customerName: 'Lê Văn C',
    phone: '0987654321',
    placedAt: DateTime(2023, 10, 18),
    total: 120000,
    payment: AdminOrderPayment.cod,
    status: AdminOrderStatus.delivered,
  ),
  AdminOrderSummary(
    id: 'ORD-202504',
    customerName: 'Phạm Thị D',
    phone: '0909090909',
    placedAt: DateTime(2023, 10, 15),
    total: 1200000,
    payment: AdminOrderPayment.bankTransfer,
    status: AdminOrderStatus.cancelled,
    note: 'Khách hủy vì đổi ý',
  ),
  AdminOrderSummary(
    id: 'ORD-202505',
    customerName: 'Hoàng Văn E',
    phone: '0888888888',
    placedAt: DateTime(2023, 10, 14),
    total: 340000,
    payment: AdminOrderPayment.cod,
    status: AdminOrderStatus.delivered,
  ),
  // Explicit demo records for pagination; no real customers/orders are created.
  for (var i = 6; i <= 12; i++)
    AdminOrderSummary(
      id: 'DEMO-ORD-${i.toString().padLeft(3, '0')}',
      customerName: 'Khách minh họa $i',
      phone: 'Chưa có SĐT',
      placedAt: null,
      total: 100000 + i * 10000,
      payment: i.isEven
          ? AdminOrderPayment.cod
          : AdminOrderPayment.bankTransfer,
      status: AdminOrderStatus.values[(i - 6) % AdminOrderStatus.values.length],
      note: 'Dữ liệu mock',
    ),
]);
