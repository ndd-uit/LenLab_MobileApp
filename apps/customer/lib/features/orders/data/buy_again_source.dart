import 'package:lenlab_shared/lenlab_shared.dart';

/// Current catalog choices only; does not recreate an order or copy old prices.
class BuyAgainChoice {
  const BuyAgainChoice({
    required this.name,
    this.product,
    this.unavailableReason,
  });
  final String name;
  final Product? product;
  final String? unavailableReason;
}

abstract interface class BuyAgainSource {
  Future<List<BuyAgainChoice>> load(Order order);
}

class CatalogBuyAgainSource implements BuyAgainSource {
  CatalogBuyAgainSource(this.repository, {required this.session});
  final LenlabRepository repository;
  final LenlabStore session;

  @override
  Future<List<BuyAgainChoice>> load(Order order) async {
    session.requireCustomer();
    final actor = session.captureSession();
    if (!session.ownsOrder(order) || order.state != OrderState.delivered) {
      throw const RepositoryException(
        'Không thể mua lại đơn của tài khoản khác.',
      );
    }
    // Different historical variants lead to the same current detail page.
    final oldProducts = {
      for (final line in order.lines) line.product.id: line.product.name,
    };
    if (oldProducts.isEmpty) return const [];
    final catalog = await repository.products();
    session.requireSession(actor);
    return List.unmodifiable(
      oldProducts.entries.map((old) {
        final matches = catalog
            .where((product) => product.id == old.key)
            .toList();
        final current = old.key.trim().isNotEmpty && matches.length == 1
            ? matches.single
            : null;
        final reason = current == null
            ? 'Không tìm thấy sản phẩm trong danh mục hiện tại.'
            : !current.published
            ? 'Sản phẩm hiện không khả dụng để mua lại tại đây.'
            : current.stock <= 0
            ? 'Sản phẩm hiện đã hết hàng.'
            : null;
        return BuyAgainChoice(
          name: current?.name ?? old.value,
          product: reason == null ? current : null,
          unavailableReason: reason,
        );
      }),
    );
  }
}
