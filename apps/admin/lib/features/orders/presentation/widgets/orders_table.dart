import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/admin_order_navigation.dart';
import '../../data/admin_orders_source.dart';
import 'order_styles.dart';
import 'order_status_badge.dart';

class OrdersTable extends StatefulWidget {
  const OrdersTable({super.key, required this.orders});
  final List<AdminOrderSummary> orders;
  @override
  State<OrdersTable> createState() => _OrdersTableState();
}

class _OrdersTableState extends State<OrdersTable> {
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
            width: math.max(constraints.maxWidth, 904 * scale),
            child: Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: const {
                0: FixedColumnWidth(40),
                1: FlexColumnWidth(108),
                2: FlexColumnWidth(128),
                3: FlexColumnWidth(108),
                4: FlexColumnWidth(110),
                5: FlexColumnWidth(70),
                6: FlexColumnWidth(92),
                7: FlexColumnWidth(142),
                8: FixedColumnWidth(106),
              },
              border: const TableBorder(
                horizontalInside: BorderSide(color: adminListBorder),
              ),
              children: [
                TableRow(
                  decoration: const BoxDecoration(color: Color(0xFFF9FAFB)),
                  children: [
                    _check(header: true),
                    for (final label in [
                      'MÃ ĐƠN',
                      'KHÁCH HÀNG',
                      'NGÀY ĐẶT',
                      'TỔNG TIỀN',
                      'THANH TOÁN',
                      'TRẠNG THÁI',
                      'GHI CHÚ',
                      'CHI TIẾT',
                    ])
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 16,
                        ),
                        child: Text(
                          label,
                          style: const TextStyle(
                            fontSize: 12,
                            height: 16 / 12,
                            fontWeight: FontWeight.bold,
                            color: adminListMuted,
                          ),
                        ),
                      ),
                  ],
                ),
                for (final order in widget.orders)
                  TableRow(
                    key: ValueKey('order-row-${order.id}'),
                    children: [
                      _check(),
                      _idCell(order.id),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 20,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.customerName,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 20 / 14,
                                fontWeight: FontWeight.w500,
                                color: adminListInk,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              order.phone,
                              style: const TextStyle(
                                fontSize: 12,
                                height: 16 / 12,
                                color: adminListMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _cell(
                        orderDate(order.placedAt),
                        color: const Color(0xFF4B5563),
                      ),
                      _cell(
                        adminListMoney(order.total),
                        weight: FontWeight.bold,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 20,
                        ),
                        child: Tooltip(
                          message: order.payment == AdminOrderPayment.cod
                              ? 'Thanh toán khi nhận hàng (dữ liệu mẫu)'
                              : 'Chuyển khoản (dữ liệu mẫu; chưa tích hợp cổng thanh toán)',
                          child: Text(
                            order.payment.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color:
                                  order.payment ==
                                      AdminOrderPayment.bankTransfer
                                  ? const Color(0xFF2563EB)
                                  : const Color(0xFF4B5563),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: _status(order.status),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 20,
                        ),
                        child: Tooltip(
                          message: order.note?.trim().isNotEmpty == true
                              ? order.note!
                              : 'Không có ghi chú',
                          child: Text(
                            order.note?.trim().isNotEmpty == true
                                ? order.note!
                                : 'Không có ghi chú',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: order.note?.trim().isNotEmpty == true
                                  ? 14
                                  : 12,
                              height: 20 / 14,
                              fontStyle: order.note?.trim().isNotEmpty == true
                                  ? FontStyle.normal
                                  : FontStyle.italic,
                              color: adminListMuted,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 16,
                        ),
                        child: OutlinedButton(
                          key: ValueKey('order-detail-${order.id}'),
                          onPressed: () =>
                              openAdminOrderDetail(context, order.id),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF6B3510),
                            side: const BorderSide(color: Color(0x4DE09F56)),
                            padding: const EdgeInsets.symmetric(horizontal: 7),
                            minimumSize: const Size(86, 36),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text(
                            'Chi tiết',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
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

  Widget _check({bool header = false}) => SizedBox(
    height: header ? 64 : 94,
    child: const Tooltip(
      message: 'Chọn hàng loạt chưa triển khai',
      child: Center(
        child: SizedBox(
          width: 16,
          height: 16,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0xFFF9FAFB),
              shape: BoxShape.circle,
              border: Border.fromBorderSide(
                BorderSide(color: Color(0xFFD1D5DB)),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _idCell(String id) {
    final separator = id.lastIndexOf('-');
    final displayed = separator < 0
        ? '#$id'
        : '#${id.substring(0, separator + 1)}\n${id.substring(separator + 1)}';
    return Semantics(
      key: ValueKey('order-id-$id'),
      label: '#$id',
      child: ExcludeSemantics(
        child: Tooltip(
          message: '#$id',
          child: _cell(displayed, color: const Color(0xFF6B3510)),
        ),
      ),
    );
  }

  Widget _cell(
    String text, {
    Color color = adminListInk,
    FontWeight weight = FontWeight.w400,
  }) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 14,
        height: 20 / 14,
        color: color,
        fontWeight: weight,
      ),
    ),
  );

  Widget _status(AdminOrderStatus status) => Align(
    alignment: Alignment.centerLeft,
    child: OrderStatusBadge(status: status),
  );
}
