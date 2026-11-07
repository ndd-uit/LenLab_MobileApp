import '../domain/models.dart';
import 'lenlab_repository.dart';
import 'mock_product_catalog.dart';

class MockLenlabRepository implements LenlabRepository {
  MockLenlabRepository({this.latency = const Duration(milliseconds: 450)});
  final Duration latency;
  final Map<String, int> _failures = {};
  void failNext(String operation) => _failures[operation] = 1;
  Future<void> operation(String name) async {
    await Future<void>.delayed(latency);
    if ((_failures[name] ?? 0) > 0) {
      _failures[name] = 0;
      throw const RepositoryException('Không thể kết nối. Vui lòng thử lại.');
    }
  }

  final List<Product> catalog = createMockProductCatalog();
  @override
  Future<List<Product>> products() async {
    await operation('products');
    return List.of(catalog);
  }

  @override
  Future<void> saveProduct(Product product) async {
    await operation('saveProduct');
    if (product.name.trim().isEmpty || product.price <= 0) {
      throw const RepositoryException('Vui lòng nhập tên và giá bán hợp lệ.');
    }
    if (!catalog.any((p) => p.id == product.id)) catalog.add(product);
  }
}
