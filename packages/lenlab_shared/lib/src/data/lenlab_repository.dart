import '../domain/models.dart';

class RepositoryException implements Exception {
  const RepositoryException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Replace this port with an HTTP implementation once the API is specified.
abstract interface class LenlabRepository {
  Future<List<Product>> products();
  Future<void> saveProduct(Product product);
}
