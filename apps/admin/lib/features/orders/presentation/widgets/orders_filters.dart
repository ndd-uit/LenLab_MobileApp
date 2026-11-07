import 'package:flutter/material.dart';

import '../../data/admin_orders_source.dart';
import 'order_styles.dart';

class OrdersFilters extends StatelessWidget {
  const OrdersFilters({
    super.key,
    required this.search,
    required this.status,
    required this.payment,
    required this.onSearch,
    required this.onStatus,
    required this.onPayment,
    required this.onClear,
  });
  final TextEditingController search;
  final AdminOrderStatus? status;
  final AdminOrderPayment? payment;
  final ValueChanged<String> onSearch;
  final ValueChanged<AdminOrderStatus?> onStatus;
  final ValueChanged<AdminOrderPayment?> onPayment;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: adminListSurface(),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final input = TextField(
          key: const ValueKey('orders-search'),
          controller: search,
          onChanged: onSearch,
          style: const TextStyle(fontSize: 16, color: adminListInk),
          decoration: InputDecoration(
            isDense: true,
            prefixIconConstraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
            hintText: 'Tìm theo mã đơn, tên khách hàng...',
            hintStyle: const TextStyle(fontSize: 16, color: adminListMuted),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 11,
            ),
            prefixIcon: Center(
              widthFactor: 1,
              heightFactor: 1,
              child: orderAsset('imgContainer11', 17.054, 17.054),
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
            _select(
              key: const ValueKey('orders-status'),
              label: 'Trạng thái đơn hàng',
              width: 160,
              value: status?.index ?? -1,
              entries: {
                -1: 'Trạng thái đơn hàng',
                for (final value in AdminOrderStatus.values)
                  value.index: value.label,
              },
              onChanged: (value) =>
                  onStatus(value == -1 ? null : AdminOrderStatus.values[value]),
            ),
            _select(
              key: const ValueKey('orders-payment'),
              label: 'Phương thức thanh toán',
              width: 160,
              value: payment?.index ?? -1,
              entries: {
                -1: 'Thanh toán',
                for (final value in AdminOrderPayment.values)
                  value.index: value.label,
              },
              onChanged: (value) => onPayment(
                value == -1 ? null : AdminOrderPayment.values[value],
              ),
            ),
            IconButton.outlined(
              tooltip: 'Bộ lọc đơn hàng đang áp dụng',
              onPressed: () => showDialog<void>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Bộ lọc đơn hàng'),
                  content: Text(
                    'Tìm kiếm: ${search.text.trim().isEmpty ? 'Tất cả' : search.text.trim()}\nTrạng thái: ${status?.label ?? 'Tất cả'}\nPhương thức: ${payment?.label ?? 'Tất cả'}',
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
              icon: orderAsset('imgContainer12', 15, 10),
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
                children: [input, const SizedBox(height: 16), options],
              );
      },
    ),
  );

  Widget _select({
    required Key key,
    required String label,
    required double width,
    required int value,
    required Map<int, String> entries,
    required ValueChanged<int> onChanged,
  }) => Semantics(
    label: label,
    child: Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          key: key,
          value: value,
          isExpanded: true,
          isDense: true,
          icon: orderAsset('imgImage', 21, 21),
          style: const TextStyle(
            fontFamily: 'packages/lenlab_shared/Inter',
            fontSize: 14,
            color: adminListInk,
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
