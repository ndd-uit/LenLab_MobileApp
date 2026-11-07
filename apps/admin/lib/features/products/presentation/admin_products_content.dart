import 'dart:async';

import 'package:flutter/material.dart';

import '../data/admin_products_source.dart';
import 'widgets/product_styles.dart';
import 'widgets/products_filters.dart';
import 'widgets/products_pagination.dart';
import 'widgets/products_table.dart';

class AdminProductsContent extends StatefulWidget {
  const AdminProductsContent({super.key, this.source});
  final AdminProductsSource? source;
  @override
  State<AdminProductsContent> createState() => _AdminProductsContentState();
}

class _AdminProductsContentState extends State<AdminProductsContent> {
  final _search = TextEditingController();
  late AdminProductsSource _source;
  ProductCategory? _category;
  ProductVisibility _visibility = ProductVisibility.all;
  AdminProductsResult? _result;
  bool _loading = true, _error = false;
  int _generation = 0;
  int _requestedPage = 1;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _source = widget.source ?? MockAdminProductsSource();
    _load();
  }

  @override
  void didUpdateWidget(covariant AdminProductsContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source != widget.source) {
      _source = widget.source ?? MockAdminProductsSource();
      _load();
    }
  }

  @override
  void dispose() {
    _generation++;
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _load({int page = 1, bool debounce = false}) {
    _requestedPage = page;
    _debounce?.cancel();
    final generation = ++_generation;
    final query = AdminProductsQuery(
      search: _search.text,
      category: _category,
      visibility: _visibility,
      page: page,
    );
    setState(() {
      _loading = true;
      _error = false;
      _result = null;
    });
    Future<void> fetch() async {
      try {
        final result = await _source.fetch(query);
        if (!mounted || generation != _generation) return;
        setState(() {
          _result = result;
          _loading = false;
        });
      } catch (_) {
        if (!mounted || generation != _generation) return;
        setState(() {
          _error = true;
          _loading = false;
        });
      }
    }

    if (debounce) {
      _debounce = Timer(const Duration(milliseconds: 250), fetch);
    } else {
      unawaited(fetch());
    }
  }

  void _clear() {
    _search.clear();
    _category = null;
    _visibility = ProductVisibility.all;
    _load();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      ProductsFilters(
        search: _search,
        category: _category,
        visibility: _visibility,
        onSearch: (_) => _load(debounce: true),
        onCategory: (value) {
          _category = value;
          _load();
        },
        onVisibility: (value) {
          _visibility = value;
          _load();
        },
        onClear: _clear,
      ),
      const SizedBox(height: 24),
      Container(
        decoration: productSurface(),
        clipBehavior: Clip.antiAlias,
        child: _loading
            ? const SizedBox(
                height: 480,
                child: Center(
                  child: CircularProgressIndicator(
                    semanticsLabel: 'Đang tải sản phẩm',
                  ),
                ),
              )
            : _error
            ? _message(
                'Không thể tải danh sách sản phẩm',
                'Vui lòng thử lại. Bộ lọc của bạn được giữ nguyên.',
                'Thử lại',
                () => _load(page: _requestedPage),
              )
            : _result!.total == 0
            ? _message(
                'Không có sản phẩm',
                _search.text.trim().isNotEmpty ||
                        _category != null ||
                        _visibility != ProductVisibility.all
                    ? 'Không có sản phẩm khớp tìm kiếm và bộ lọc.'
                    : 'Danh sách sản phẩm hiện đang trống.',
                'Xóa bộ lọc',
                _clear,
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ProductsTable(products: _result!.items),
                  ProductsPagination(
                    result: _result!,
                    onPage: (page) => _load(page: page),
                  ),
                ],
              ),
      ),
      const SizedBox(height: 16),
      const Text(
        'Dữ liệu mock • Chỉ đọc • Chưa kết nối backend',
        style: TextStyle(fontSize: 12, color: productMuted),
      ),
    ],
  );

  Widget _message(
    String title,
    String description,
    String button,
    VoidCallback action,
  ) => ConstrainedBox(
    constraints: const BoxConstraints(minHeight: 480),
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: productInk,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(color: productMuted),
          ),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: action, child: Text(button)),
        ],
      ),
    ),
  );
}
