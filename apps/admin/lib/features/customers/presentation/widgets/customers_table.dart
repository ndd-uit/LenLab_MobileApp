import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

import '../../data/admin_customers_source.dart';
import 'customer_styles.dart';
import '../../../../app/admin_customer_navigation.dart';

class CustomersTable extends StatefulWidget {
  const CustomersTable({super.key, required this.customers});
  final List<AdminCustomer> customers;
  @override
  State<CustomersTable> createState() => _CustomersTableState();
}

class _CustomersTableState extends State<CustomersTable> {
  final _horizontal = ScrollController();
  @override
  void dispose() {
    _horizontal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Scrollbar(
      controller: _horizontal,
      thumbVisibility: true,
      notificationPredicate: (notification) =>
          notification.metrics.axis == Axis.horizontal,
      child: SingleChildScrollView(
        controller: _horizontal,
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: math.max(
            constraints.maxWidth,
            960 * MediaQuery.textScalerOf(context).scale(14) / 14,
          ),
          child: Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            columnWidths: const {
              0: FixedColumnWidth(64),
              1: FlexColumnWidth(270),
              2: FlexColumnWidth(150),
              3: FlexColumnWidth(127),
              4: FlexColumnWidth(107),
              5: FlexColumnWidth(133),
              6: FixedColumnWidth(104),
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
                    'NGƯỜI DÙNG',
                    'SỐ ĐIỆN THOẠI',
                    'VAI TRÒ',
                    'MUA HÀNG',
                    'TRẠNG THÁI',
                    'HÀNH ĐỘNG',
                  ])
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
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
              for (final customer in widget.customers)
                TableRow(
                  key: ValueKey('customer-row-${customer.id}'),
                  decoration: BoxDecoration(
                    color: customer.status == AdminCustomerStatus.blocked
                        ? const Color(0xFFF9FAFB)
                        : Colors.white,
                  ),
                  children: [
                    _check(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          _avatar(customer),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  customer.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 20 / 14,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        customer.status ==
                                            AdminCustomerStatus.blocked
                                        ? adminListMuted
                                        : adminListInk,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  customer.email,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    height: 16 / 12,
                                    color: adminListMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Text(
                        customer.phone,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 20 / 14,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: customer.role == AdminCustomerRole.staff
                                ? const Color(0xFFF3E8FF)
                                : const Color(0xFFDBEAFE),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            customer.role.label,
                            style: TextStyle(
                              fontSize: 12,
                              height: 16 / 12,
                              fontWeight: FontWeight.w500,
                              color: customer.role == AdminCustomerRole.staff
                                  ? const Color(0xFF6B21A8)
                                  : const Color(0xFF1E40AF),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        customer.orderCount == null
                            ? '—'
                            : '${customer.orderCount} đơn',
                        style: const TextStyle(
                          fontSize: 14,
                          color: adminListInk,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _status(customer.status),
                      ),
                    ),
                    Center(
                      child: IconButton(
                        key: ValueKey('customer-detail-${customer.id}'),
                        tooltip: 'Xem chi tiết ${customer.name}',
                        onPressed: () =>
                            openAdminCustomerDetail(context, customer.id),
                        icon: P2Asset.node(
                          '2026:9129',
                          'imgContainer19',
                          width: 20,
                          height: 20,
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
  );

  Widget _avatar(AdminCustomer customer) => Container(
    width: 40,
    height: 40,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: customer.status == AdminCustomerStatus.blocked
          ? adminListBorder
          : const Color(0xFFDBEAFE),
      border: Border.all(
        color: customer.status == AdminCustomerStatus.blocked
            ? const Color(0xFFD1D5DB)
            : const Color(0xFFBFDBFE),
      ),
    ),
    child: customer.avatarAlias == null
        ? Center(
            child: Text(
              customer.initials,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: customer.status == AdminCustomerStatus.blocked
                    ? const Color(0xFF523A30)
                    : const Color(0xFF1E40AF),
              ),
            ),
          )
        : customerAsset(customer.avatarAlias!, 40, 40),
  );
  Widget _status(AdminCustomerStatus status) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
    decoration: BoxDecoration(
      color: status == AdminCustomerStatus.active
          ? const Color(0xFFDCFCE7)
          : const Color(0xFFF3F4F6),
      borderRadius: BorderRadius.circular(99),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (status == AdminCustomerStatus.active)
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF16A34A),
            ),
          )
        else
          customerAsset('imgContainer17', 9.352, 12.25),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            status.label,
            style: TextStyle(
              fontSize: 12,
              height: 16 / 12,
              fontWeight: FontWeight.w500,
              color: status == AdminCustomerStatus.active
                  ? const Color(0xFF166534)
                  : const Color(0xFF4B5563),
            ),
          ),
        ),
      ],
    ),
  );
  Widget _check({bool header = false}) => SizedBox(
    height: header ? 64 : 72,
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
}
