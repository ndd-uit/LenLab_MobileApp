import 'package:flutter/material.dart';

import '../../../shared/widgets/catalog_products.dart';
import 'product_detail_page.dart';
import 'product_unavailable_page.dart';

/// Route payloads carry identity, never authoritative pricing/availability.
class ProductDetailRoute extends StatelessWidget {
  const ProductDetailRoute({super.key, required this.productId});
  final String productId;
  @override
  Widget build(BuildContext context) => CatalogProducts(
    fullPage: true,
    builder: (context, products) {
      final product = purchasableProduct(products, productId);
      return product == null
          ? const ProductUnavailablePage()
          : ProductDetailPage(product: product);
    },
  );
}
