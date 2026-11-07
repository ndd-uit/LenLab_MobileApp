import 'package:flutter/material.dart';

import '../../data/admin_customers_source.dart';
import 'customer_styles.dart';

class CustomersFilters extends StatelessWidget {
  const CustomersFilters({
    super.key,
    required this.search,
    required this.role,
    required this.status,
    required this.onSearch,
    required this.onRole,
    required this.onStatus,
    required this.onClear,
  });
  final TextEditingController search;
  final AdminCustomerRole? role;
  final AdminCustomerStatus? status;
  final ValueChanged<String> onSearch;
  final ValueChanged<AdminCustomerRole?> onRole;
  final ValueChanged<AdminCustomerStatus?> onStatus;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: adminListSurface(),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final input = TextField(
          key: const ValueKey('customers-search'),
          controller: search,
          onChanged: onSearch,
          style: const TextStyle(fontSize: 16, color: adminListInk),
          decoration: InputDecoration(
            isDense: true,
            prefixIconConstraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
            hintText: 'Tìm kiếm tên, email, SĐT...',
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
              child: customerAsset('imgContainer11', 17.054, 17.054),
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
              key: const ValueKey('customers-role'),
              label: 'Tất cả vai trò',
              width: 138,
              value: role?.index ?? -1,
              entries: {
                -1: 'Tất cả vai trò',
                for (final value in AdminCustomerRole.values)
                  value.index: value.label,
              },
              onChanged: (value) =>
                  onRole(value == -1 ? null : AdminCustomerRole.values[value]),
            ),
            _select(
              key: const ValueKey('customers-status'),
              label: 'Trạng thái',
              width: 120,
              value: status?.index ?? -1,
              entries: {
                -1: 'Trạng thái',
                for (final value in AdminCustomerStatus.values)
                  value.index: value.label,
              },
              onChanged: (value) => onStatus(
                value == -1 ? null : AdminCustomerStatus.values[value],
              ),
            ),
            IconButton.outlined(
              tooltip: 'Bộ lọc người dùng đang áp dụng',
              onPressed: () => showDialog<void>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Bộ lọc người dùng'),
                  content: Text(
                    'Tìm kiếm: ${search.text.trim().isEmpty ? 'Tất cả' : search.text.trim()}\nVai trò: ${role?.label ?? 'Tất cả'}\nTrạng thái: ${status?.label ?? 'Tất cả'}',
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
              icon: customerAsset('imgContainer12', 15, 10),
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
          icon: customerAsset('imgImage', 21, 21),
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

