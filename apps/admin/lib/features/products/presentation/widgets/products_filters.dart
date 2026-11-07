import 'package:flutter/material.dart';

import '../../data/admin_products_source.dart';
import 'product_styles.dart';

class ProductsFilters extends StatelessWidget {
  const ProductsFilters({
    super.key,
    required this.search,
    required this.category,
    required this.visibility,
    required this.onSearch,
    required this.onCategory,
    required this.onVisibility,
    required this.onClear,
  });
  final TextEditingController search;
  final ProductCategory? category;
  final ProductVisibility visibility;
  final ValueChanged<String> onSearch;
  final ValueChanged<ProductCategory?> onCategory;
  final ValueChanged<ProductVisibility> onVisibility;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: productSurface(),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final input = TextField(
          key: const ValueKey('products-search'),
          controller: search,
          onChanged: onSearch,
          style: const TextStyle(fontSize: 16, color: productInk),
          decoration: InputDecoration(
            isDense: true,
            prefixIconConstraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
            hintText: 'Tìm kiếm theo tên, SKU...',
            hintStyle: const TextStyle(fontSize: 16, color: productMuted),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 11,
            ),
            prefixIcon: Center(
              widthFactor: 1,
              heightFactor: 1,
              child: productAsset('imgContainer12', 17.054, 17.054),
            ),
            suffixIcon: search.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Xóa tìm kiếm',
                    onPressed: () {
                      search.clear();
                      onSearch('');
                    },
                    icon: const Icon(Icons.close, size: 18),
                  ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
          ),
        );
        final options = Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _select<int>(
              key: const ValueKey('products-category'),
              label: 'Danh mục',
              value: category == null ? -1 : category!.index,
              entries: {
                -1: 'Tất cả danh mục',
                for (final c in ProductCategory.values) c.index: c.label,
              },
              onChanged: (value) => onCategory(
                value == -1 ? null : ProductCategory.values[value],
              ),
            ),
            _select<ProductVisibility>(
              key: const ValueKey('products-visibility'),
              label: 'Trạng thái',
              value: visibility,
              entries: const {
                ProductVisibility.all: 'Trạng thái',
                ProductVisibility.visible: 'Đang hiển thị',
                ProductVisibility.hidden: 'Đang ẩn',
              },
              onChanged: onVisibility,
            ),
            IconButton.outlined(
              tooltip: 'Bộ lọc đang áp dụng',
              onPressed: () => showDialog<void>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Bộ lọc đang áp dụng'),
                  content: Text(
                    'Tìm kiếm: ${search.text.trim().isEmpty ? 'Tất cả' : search.text.trim()}\nDanh mục: ${category?.label ?? 'Tất cả'}\nTrạng thái: ${switch (visibility) {
                      ProductVisibility.all => 'Tất cả',
                      ProductVisibility.visible => 'Đang hiển thị',
                      ProductVisibility.hidden => 'Đang ẩn',
                    }}',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        onClear();
                      },
                      child: const Text('Xóa bộ lọc'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Đóng'),
                    ),
                  ],
                ),
              ),
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                side: const BorderSide(color: Color(0xFFD1D5DB)),
              ),
              icon: productAsset('imgContainer13', 18, 12),
            ),
          ],
        );
        return constraints.maxWidth >= 900
            ? Row(
                children: [
                  SizedBox(width: 384, child: input),
                  const Spacer(),
                  const SizedBox(width: 16),
                  options,
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 384),
                    child: input,
                  ),
                  const SizedBox(height: 16),
                  options,
                ],
              );
      },
    ),
  );

  Widget _select<T extends Object>({
    required Key key,
    required String label,
    required T value,
    required Map<T, String> entries,
    required ValueChanged<T> onChanged,
  }) => Semantics(
    label: label,
    child: Container(
      width: label == 'Danh mục' ? 166 : 120,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          key: key,
          isExpanded: true,
          isDense: true,
          value: value,
          icon: productAsset('imgImage', 21, 21),
          style: const TextStyle(
            fontFamily: 'packages/lenlab_shared/Inter',
            fontSize: 14,
            color: productInk,
          ),
          items: [
            for (final entry in entries.entries)
              DropdownMenuItem(
                value: entry.key,
                child: Text(
                  entry.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
        ),
      ),
    ),
  );
}

