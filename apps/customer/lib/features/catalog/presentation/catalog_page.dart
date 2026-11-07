import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';
import 'package:lenlab_customer/app/customer_scope.dart';
import 'package:lenlab_customer/shared/navigation/customer_drawer.dart';

import 'catalog_styles.dart';
import 'widgets/catalog_header.dart';
import 'widgets/catalog_categories.dart';
import 'widgets/catalog_grid.dart';
import 'widgets/catalog_product_card.dart';
import 'widgets/catalog_pagination.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key, this.initialCategory = 'Tất cả'});
  final String initialCategory;
  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final search = TextEditingController();
  final scroll = ScrollController();
  Future<List<Product>>? request;
  late String category = widget.initialCategory;
  String sort = 'Mặc định';
  int page = 0;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    request ??= CustomerScope.of(context).repository.products();
  }

  @override
  void dispose() {
    search.dispose();
    scroll.dispose();
    super.dispose();
  }

  void selectCategory(String value) => setState(() {
    category = value;
    page = 0;
  });
  void reset() => setState(() {
    category = 'Tất cả';
    search.clear();
    sort = 'Mặc định';
    page = 0;
  });
  void changePage(int value) {
    setState(() => page = value);
    scroll.jumpTo(0);
  }

  void filter() => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheet) => SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lọc sản phẩm',
                style: P2.serif(22, weight: FontWeight.w700),
              ),
              gap,
              for (final value in catalogCategoryLabels)
                ListTile(
                  title: Text(value),
                  selected: category == value,
                  trailing: category == value ? const Icon(Icons.check) : null,
                  onTap: () {
                    selectCategory(value);
                    Navigator.pop(sheet);
                  },
                ),
            ],
          ),
        ),
      ),
    ),
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    drawer: const CustomerDrawer(),
    drawerScrimColor: const Color(0x996E6E6D),
    appBar: CatalogHeader(
      controller: search,
      onChanged: (_) => setState(() => page = 0),
    ),
    body: SafeArea(
      top: false,
      child: Column(
        children: [
          CatalogCategories(
            labels: catalogCategoryLabels,
            value: category,
            onChanged: selectCategory,
            onFilter: filter,
          ),
          Expanded(
            child: SingleChildScrollView(
              key: const ValueKey('catalog-scroll'),
              controller: scroll,
              padding: EdgeInsets.fromLTRB(16, 24, 16, 56),
              child: FutureBuilder<List<Product>>(
                future: request,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const CatalogLoading();
                  }
                  if (snapshot.hasError) {
                    return EmptyPanel(
                      'Không thể tải sản phẩm',
                      description: 'Không thể kết nối. Vui lòng thử lại.',
                      action: P2Button(
                        'Thử lại',
                        onPressed: () => setState(() {
                          request = CustomerScope.of(context).repository
                              .products();
                        }),
                      ),
                    );
                  }
                  final products = snapshot.data!
                      .where(
                        (p) =>
                            p.published &&
                            (category == 'Tất cả' || p.category == category) &&
                            p.name.toLowerCase().contains(
                              search.text.trim().toLowerCase(),
                            ),
                      )
                      .toList();
                  if (sort != 'Mặc định') {
                    products.sort(
                      (a, b) => sort == 'Giá tăng dần'
                          ? a.price.compareTo(b.price)
                          : b.price.compareTo(a.price),
                    );
                  }
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  const TextSpan(text: 'Hiển thị '),
                                  TextSpan(
                                    text: '${products.length}',
                                    style: const TextStyle(color: P2.green),
                                  ),
                                  const TextSpan(text: ' sản phẩm'),
                                ],
                              ),
                              style: const TextStyle(
                                fontSize: 14,
                                height: 20 / 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                          PopupMenuButton<String>(
                            tooltip: 'Sắp xếp',
                            initialValue: sort,
                            onSelected: (value) => setState(() {
                              sort = value;
                              page = 0;
                            }),
                            itemBuilder: (_) => [
                              for (final value in catalogSortOptions)
                                CheckedPopupMenuItem(
                                  value: value,
                                  checked: sort == value,
                                  child: Text(value),
                                ),
                            ],
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(minHeight: 44),
                              child: Row(
                                children: [
                                  const Text(
                                    'Sắp xếp',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  P2Asset.node(
                                    catalogNode,
                                    'imgContainer5',
                                    width: 9,
                                    height: 5.55,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (products.isEmpty)
                        EmptyPanel(
                          'Không có kết quả',
                          description: 'Thử từ khóa hoặc danh mục khác.',
                          action: P2Button('Xóa bộ lọc', onPressed: reset),
                        )
                      else
                        CatalogGrid(
                          children: [
                            for (final product
                                in products.skip(page * 6).take(6))
                              CatalogProductCard(product: product),
                          ],
                        ),
                      if (products.length > 6)
                        CatalogPagination(
                          page: page,
                          count: (products.length / 6).ceil(),
                          onChanged: changePage,
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
