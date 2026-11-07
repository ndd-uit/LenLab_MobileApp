enum ProductCategory {
  toys('Thú bông len'),
  fashion('Thời trang & Phụ kiện');

  const ProductCategory(this.label);
  final String label;
}

enum ProductVisibility { all, visible, hidden }

enum ProductStockTone { available, warning, empty }

enum ProductThumbnail { image, camera, pending }

class AdminProduct {
  const AdminProduct({
    required this.sku,
    required this.name,
    required this.variant,
    required this.price,
    required this.stock,
    required this.category,
    required this.visible,
    required this.stockTone,
    required this.thumbnail,
  });
  final String sku, name, variant;
  final int price, stock;
  final ProductCategory category;
  final bool visible;
  // Explicit fixture tone; no unapproved low-stock threshold is inferred.
  final ProductStockTone stockTone;
  final ProductThumbnail thumbnail;
}

class AdminProductsQuery {
  const AdminProductsQuery({
    this.search = '',
    this.category,
    this.visibility = ProductVisibility.all,
    this.page = 1,
  });
  static const pageSize = 5;
  final String search;
  final ProductCategory? category;
  final ProductVisibility visibility;
  final int page;
}

class AdminProductsResult {
  AdminProductsResult({
    required List<AdminProduct> items,
    required this.total,
    required this.page,
  }) : items = List.unmodifiable(items);
  final List<AdminProduct> items;
  final int total, page;
  int get pages => (total / AdminProductsQuery.pageSize).ceil();
  int get start =>
      total == 0 ? 0 : (page - 1) * AdminProductsQuery.pageSize + 1;
  int get end => total == 0 ? 0 : start + items.length - 1;
}

abstract interface class AdminProductsSource {
  Future<AdminProductsResult> fetch(AdminProductsQuery query);
}

class MockAdminProductsSource implements AdminProductsSource {
  MockAdminProductsSource({
    this.latency = const Duration(milliseconds: 300),
    List<AdminProduct>? products,
  }) : products = List.unmodifiable(products ?? adminProductFixtures);
  final Duration latency;
  final List<AdminProduct> products;
  bool failNext = false;

  @override
  Future<AdminProductsResult> fetch(AdminProductsQuery query) async {
    await Future<void>.delayed(latency);
    if (failNext) {
      failNext = false;
      throw StateError('Mock products unavailable');
    }
    final search = query.search.trim().toLowerCase();
    final matching = products
        .where(
          (p) =>
              (search.isEmpty ||
                  p.name.toLowerCase().contains(search) ||
                  p.sku.toLowerCase().contains(search)) &&
              (query.category == null || p.category == query.category) &&
              (query.visibility == ProductVisibility.all ||
                  p.visible == (query.visibility == ProductVisibility.visible)),
        )
        .toList();
    final pages = (matching.length / AdminProductsQuery.pageSize).ceil();
    final page = pages == 0 ? 1 : query.page.clamp(1, pages);
    return AdminProductsResult(
      items: matching
          .skip((page - 1) * AdminProductsQuery.pageSize)
          .take(AdminProductsQuery.pageSize)
          .toList(),
      total: matching.length,
      page: page,
    );
  }
}

final adminProductFixtures = List<AdminProduct>.unmodifiable([
  const AdminProduct(
    sku: 'MK-MEO-001',
    name: 'Móc khóa mèo đội mũ cá',
    variant: 'Màu: Xám • Size: M',
    price: 40000,
    stock: 45,
    category: ProductCategory.toys,
    visible: true,
    stockTone: ProductStockTone.available,
    thumbnail: ProductThumbnail.image,
  ),
  const AdminProduct(
    sku: 'TB-THO-002',
    name: 'Thỏ đội mũ',
    variant: 'Màu: Trắng • Size: L',
    price: 90000,
    stock: 5,
    category: ProductCategory.toys,
    visible: true,
    stockTone: ProductStockTone.warning,
    thumbnail: ProductThumbnail.pending,
  ),
  const AdminProduct(
    sku: 'MK-GAU-003',
    name: 'Móc khóa gấu',
    variant: 'Màu: Nâu • Size: M',
    price: 40000,
    stock: 0,
    category: ProductCategory.toys,
    visible: false,
    stockTone: ProductStockTone.empty,
    thumbnail: ProductThumbnail.camera,
  ),
  const AdminProduct(
    sku: 'MK-TDN-004',
    name: 'Móc khóa thỏ đội nón',
    variant: 'Màu: Hồng • Size: L',
    price: 45000,
    stock: 120,
    category: ProductCategory.toys,
    visible: true,
    stockTone: ProductStockTone.available,
    thumbnail: ProductThumbnail.pending,
  ),
  const AdminProduct(
    sku: 'TT-HOA-005',
    name: 'Túi thắt nơ',
    variant: 'Size: M',
    price: 120000,
    stock: 15,
    category: ProductCategory.fashion,
    visible: true,
    stockTone: ProductStockTone.available,
    thumbnail: ProductThumbnail.camera,
  ),
  // Additional fixtures exist only to exercise pagination; no real catalog is implied.
  for (var i = 6; i <= 12; i++)
    AdminProduct(
      sku: 'DEMO-${i.toString().padLeft(3, '0')}',
      name: 'Sản phẩm minh họa ${i.toString().padLeft(2, '0')}',
      variant: 'Dữ liệu mock',
      price: 50000 + i * 1000,
      stock: i,
      category: i.isEven ? ProductCategory.toys : ProductCategory.fashion,
      visible: i.isEven,
      stockTone: ProductStockTone.available,
      thumbnail: ProductThumbnail.pending,
    ),
]);
