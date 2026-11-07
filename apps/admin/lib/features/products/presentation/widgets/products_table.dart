import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/admin_products_source.dart';
import 'product_styles.dart';

class ProductsTable extends StatefulWidget {
  const ProductsTable({super.key, required this.products});
  final List<AdminProduct> products;
  @override
  State<ProductsTable> createState() => _ProductsTableState();
}

class _ProductsTableState extends State<ProductsTable> {
  final _horizontal = ScrollController();
  @override
  void dispose() {
    _horizontal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
      return Scrollbar(
        controller: _horizontal,
        thumbVisibility: true,
        notificationPredicate: (notification) =>
            notification.metrics.axis == Axis.horizontal,
        child: SingleChildScrollView(
          controller: _horizontal,
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: math.max(constraints.maxWidth, 960 * scale),
            child: Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: const {
                0: FixedColumnWidth(64),
                1: FlexColumnWidth(2.3),
                2: FlexColumnWidth(1.15),
                3: FlexColumnWidth(1.15),
                4: FlexColumnWidth(1),
                5: FlexColumnWidth(1.5),
                6: FlexColumnWidth(1.1),
                7: FixedColumnWidth(104),
              },
              border: const TableBorder(
                horizontalInside: BorderSide(color: productBorder),
              ),
              children: [
                TableRow(
                  decoration: const BoxDecoration(color: Color(0xFFF9FAFB)),
                  children: [
                    _check(),
                    for (final label in [
                      'SẢN PHẨM',
                      'MÃ SKU',
                      'GIÁ BÁN',
                      'TỒN KHO',
                      'DANH MỤC',
                      'TRẠNG THÁI',
                      'HÀNH ĐỘNG',
                    ])
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                        child: Text(
                          label,
                          style: const TextStyle(
                            fontSize: 12,
                            height: 16 / 12,
                            fontWeight: FontWeight.bold,
                            color: productMuted,
                          ),
                        ),
                      ),
                  ],
                ),
                for (final product in widget.products)
                  TableRow(
                    key: ValueKey('product-row-${product.sku}'),
                    children: [
                      _check(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                        child: Row(
                          children: [
                            _thumbnail(product.thumbnail),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      height: 20 / 14,
                                      fontWeight: FontWeight.w500,
                                      color: productInk,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    product.variant,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      height: 16 / 12,
                                      color: productMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      _cell(
                        product.sku.replaceFirst(RegExp(r'-(?=[^-]+$)'), '-\n'),
                        semanticsLabel: product.sku,
                        color: const Color(0xFF4B5563),
                        horizontalPadding: 12,
                      ),
                      _cell(
                        productMoney(product.price),
                        weight: FontWeight.w500,
                      ),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: switch (product.stockTone) {
                              ProductStockTone.available => const Color(
                                0xFFDCFCE7,
                              ),
                              ProductStockTone.warning => const Color(
                                0xFFFEF9C3,
                              ),
                              ProductStockTone.empty => const Color(0xFFFEE2E2),
                            },
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            '${product.stock}',
                            style: TextStyle(
                              fontSize: 12,
                              height: 16 / 12,
                              fontWeight: FontWeight.w500,
                              color: switch (product.stockTone) {
                                ProductStockTone.available => const Color(
                                  0xFF166534,
                                ),
                                ProductStockTone.warning => const Color(
                                  0xFF854D0E,
                                ),
                                ProductStockTone.empty => const Color(
                                  0xFF991B1B,
                                ),
                              },
                            ),
                          ),
                        ),
                      ),
                      _cell(
                        product.category.label,
                        color: const Color(0xFF4B5563),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Semantics(
                            label:
                                '${product.name}: ${product.visible ? 'Đang hiển thị' : 'Đang ẩn'}, chỉ đọc',
                            child: Tooltip(
                              message: 'Trạng thái chỉ đọc',
                              child: Container(
                                width: 36,
                                height: 20,
                                alignment: product.visible
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: product.visible
                                      ? productAccent
                                      : productBorder,
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Tooltip(
                        message: 'Thêm/sửa/xóa chưa triển khai',
                        child: Center(
                          child: Text(
                            '—',
                            style: TextStyle(color: productMuted),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );

  Widget _check() => const Tooltip(
    message: 'Chọn hàng loạt chưa triển khai',
    child: Center(
      child: SizedBox(
        width: 16,
        height: 16,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Color(0xFFF9FAFB),
            shape: BoxShape.circle,
            border: Border.fromBorderSide(BorderSide(color: Color(0xFFD1D5DB))),
          ),
        ),
      ),
    ),
  );

  Widget _cell(
    String text, {
    Color color = productInk,
    FontWeight weight = FontWeight.w400,
    double horizontalPadding = 20,
    String? semanticsLabel,
  }) => Padding(
    padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
    child: Text(
      text,
      semanticsLabel: semanticsLabel,
      style: TextStyle(
        fontSize: 14,
        height: 20 / 14,
        color: color,
        fontWeight: weight,
      ),
    ),
  );

  Widget _thumbnail(ProductThumbnail thumbnail) => Container(
    width: 48,
    height: 48,
    decoration: BoxDecoration(
      color: productBorder,
      border: Border.all(color: productBorder),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Center(
      child: switch (thumbnail) {
        ProductThumbnail.image => productAsset('imgContainer14', 18, 18),
        ProductThumbnail.camera => productAsset('imgContainer17', 23.016, 21),
        ProductThumbnail.pending => const Text(
          'CHỜ ẢNH',
          style: TextStyle(fontSize: 9, color: Color(0xFF523A30)),
        ),
      },
    ),
  );
}
