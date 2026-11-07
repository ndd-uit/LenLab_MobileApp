import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

import '../../app/customer_scope.dart';

/// Resolve references by exact ID only. Duplicate IDs are unavailable too.
Product? purchasableProduct(List<Product> products, String id) {
  final matches = products.where((product) => product.id == id).toList();
  if (matches.length != 1) return null;
  final product = matches.single;
  return product.published && product.stock > 0 ? product : null;
}

/// Read the active repository instead of constructing display-only products.
class CatalogProducts extends StatefulWidget {
  const CatalogProducts({
    super.key,
    required this.builder,
    this.fullPage = false,
  });
  final Widget Function(BuildContext, List<Product>) builder;
  final bool fullPage;
  @override
  State<CatalogProducts> createState() => _CatalogProductsState();
}

class _CatalogProductsState extends State<CatalogProducts> {
  LenlabRepository? repository;
  Future<List<Product>>? request;
  Widget placeholder(Widget content) =>
      widget.fullPage ? Scaffold(body: SafeArea(child: content)) : content;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initial named navigation can keep Home underneath another screen. Load
    // that page only when shown, rather than starting an offstage request.
    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) return;
    final next = CustomerScope.of(context).repository;
    if (!identical(repository, next)) {
      repository = next;
      request = next.products();
    }
  }

  @override
  Widget build(BuildContext context) => request == null
      ? const SizedBox.shrink()
      : FutureBuilder<List<Product>>(
          future: request,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return placeholder(
                const Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return placeholder(
                EmptyPanel(
                  'Không thể tải sản phẩm',
                  action: P2Button(
                    'Thử lại',
                    onPressed: () => setState(() {
                      request = repository!.products();
                    }),
                  ),
                ),
              );
            }
            return widget.builder(context, snapshot.data ?? const []);
          },
        );
}
