class DashboardSnapshot {
  DashboardSnapshot({
    required this.salesLabel,
    required this.newOrders,
    required this.newCustomers,
    required this.lowStock,
    this.salesChange,
    this.ordersChange,
    this.customersChange,
    List<DashboardProductPreview> products = const [],
  }) : products = List.unmodifiable(products);

  final String salesLabel;
  final int newOrders;
  final int newCustomers;
  final int lowStock;
  final List<DashboardProductPreview> products;
  final String? salesChange, ordersChange, customersChange;
}

abstract interface class DashboardSource {
  /// Null means there is no snapshot for the selected period, not zero sales.
  Future<DashboardSnapshot?> load();
}

class MockDashboardSource implements DashboardSource {
  MockDashboardSource({
    this.latency = const Duration(milliseconds: 300),
    this.empty = false,
  });
  final Duration latency;
  final bool empty;
  bool failNext = false;

  @override
  Future<DashboardSnapshot?> load() async {
    await Future<void>.delayed(latency);
    if (failNext) {
      failNext = false;
      throw StateError('Mock dashboard unavailable');
    }
    if (empty) return null;
    return DashboardSnapshot(
      salesLabel: '45.2M ₫',
      newOrders: 128,
      newCustomers: 34,
      lowStock: 3,
      salesChange: '+12%',
      ordersChange: '+5',
      customersChange: '+18%',
      products: dashboardProductFixtures,
    );
  }
}

class DashboardProductPreview {
  const DashboardProductPreview(
    this.name,
    this.priceLabel,
    this.stock,
    this.badge,
    this.imageAlias,
  );
  final String name, priceLabel, badge;
  final int stock;
  final String? imageAlias;
}

// P2 illustration only; these previews are not linked to catalog SKU records.
const dashboardProductFixtures = [
  DashboardProductPreview(
    'Gấu bông len nhỏ',
    '120k',
    12,
    'Còn hàng',
    'imgGuBongLenNh',
  ),
  DashboardProductPreview(
    'Áo khoác len Cardigan',
    '450k',
    5,
    'Còn hàng',
    'imgAoKhoacLenCardigan',
  ),
  DashboardProductPreview(
    'Khăn choàng cổ điển',
    '210k',
    2,
    'Sắp hết',
    'imgKhanChoangCDin',
  ),
  DashboardProductPreview('Set len tự đan', '199k', 50, 'Mới', null),
];
