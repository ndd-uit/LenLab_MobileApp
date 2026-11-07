import 'package:flutter/material.dart';

import '../../../../shared/widgets/admin_list_pagination.dart';
import '../../data/admin_products_source.dart';
import 'product_styles.dart';

class ProductsPagination extends StatelessWidget {
  const ProductsPagination({
    super.key,
    required this.result,
    required this.onPage,
  });
  final AdminProductsResult result;
  final ValueChanged<int> onPage;
  @override
  Widget build(BuildContext context) => AdminListPagination(
    summary:
        'Hiển thị ${result.start}-${result.end} trong số ${result.total} sản phẩm',
    page: result.page,
    pages: result.pages,
    onPage: onPage,
    accent: productAccent,
    previousIcon: productAsset('imgContainer18', 6.598, 11.156),
    nextIcon: productAsset('imgContainer19', 6.598, 11.156),
  );
}
