import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/admin_order_detail.dart';
import 'order_detail_cards.dart';
import 'order_styles.dart';

class OrderDetailProducts extends StatefulWidget {
  const OrderDetailProducts({super.key, required this.detail});
  final AdminOrderDetail detail;
  @override
  State<OrderDetailProducts> createState() => _OrderDetailProductsState();
}

class _OrderDetailProductsState extends State<OrderDetailProducts> {
  final _horizontal = ScrollController();
  @override
  void dispose() {
    _horizontal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detail = widget.detail;
    final mismatch =
        detail.subtotal != null &&
        detail.shipping != null &&
        detail.discount != null &&
        detail.subtotal! + detail.shipping! - detail.discount! !=
            detail.summary.total;
    return OrderDetailCard(
      title: 'Danh sách sản phẩm',
      icon: detailAsset('imgContainer17', 15.005, 14.977),
      trailing: Text(
        '${detail.lines.length} sản phẩm',
        style: const TextStyle(fontSize: 14, color: adminListMuted),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (detail.lines.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Chưa có dữ liệu sản phẩm của đơn hàng này.',
                style: TextStyle(color: adminListMuted),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) => Scrollbar(
                controller: _horizontal,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _horizontal,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: math.max(
                      constraints.maxWidth,
                      600 * MediaQuery.textScalerOf(context).scale(14) / 14,
                    ),
                    child: Table(
                      defaultVerticalAlignment: TableCellVerticalAlignment.top,
                      columnWidths: const {
                        0: FixedColumnWidth(88),
                        1: FlexColumnWidth(2.4),
                        2: FlexColumnWidth(.7),
                        3: FlexColumnWidth(1.3),
                        4: FlexColumnWidth(1.5),
                      },
                      border: const TableBorder(
                        horizontalInside: BorderSide(color: adminListBorder),
                      ),
                      children: [
                        TableRow(
                          decoration: const BoxDecoration(
                            color: Color(0xFFF9FAFB),
                          ),
                          children: [
                            for (final label in [
                              'HÌNH ẢNH',
                              'SẢN PHẨM',
                              'SL',
                              'ĐƠN GIÁ',
                              'THÀNH TIỀN',
                            ])
                              _cell(
                                Text(
                                  label,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: adminListMuted,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        for (final line in detail.lines)
                          TableRow(
                            children: [
                              _cell(
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: line.imageAlias == null
                                      ? const SizedBox(
                                          width: 48,
                                          height: 48,
                                          child: Icon(Icons.image_outlined),
                                        )
                                      : detailAsset(line.imageAlias!, 48, 48),
                                ),
                              ),
                              _cell(
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      line.name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: adminListInk,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      line.variant,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: adminListMuted,
                                      ),
                                    ),
                                    Text(
                                      'SKU: ${line.sku}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: adminListMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _cell(
                                Text(
                                  '${line.quantity}',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              _cell(
                                Text(
                                  adminListMoney(line.unitPrice),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              _cell(
                                Text(
                                  adminListMoney(line.total),
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: adminListInk,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          _amount('Tạm tính:', detail.subtotal),
          _amount('Phí vận chuyển:', detail.shipping),
          _amount('Giảm giá:', detail.discount, discount: true),
          Container(
            color: const Color(0x0DD1A272),
            child: _amount('Tổng cộng:', detail.summary.total, total: true),
          ),
          if (mismatch)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Chi tiết số tiền chưa khớp tổng đơn. Cần kiểm tra dữ liệu.',
                style: TextStyle(color: Color(0xFF991B1B)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _cell(Widget child) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    child: child,
  );
  Widget _amount(
    String label,
    int? value, {
    bool total = false,
    bool discount = false,
  }) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: total ? 18 : 16,
              fontWeight: total ? FontWeight.bold : FontWeight.w400,
              color: total ? adminListInk : adminListMuted,
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Text(
            value == null
                ? 'Chưa có dữ liệu'
                : '${discount && value > 0 ? '-' : ''}${adminListMoney(value)}',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: total ? 20 : 16,
              fontWeight: total ? FontWeight.bold : FontWeight.w500,
              color: total ? const Color(0xFF6B3510) : adminListInk,
            ),
          ),
        ),
      ],
    ),
  );
}
