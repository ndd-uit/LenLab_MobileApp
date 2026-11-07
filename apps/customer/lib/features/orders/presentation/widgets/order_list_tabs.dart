import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

import '../order_list_styles.dart';

class OrderListTabs extends StatelessWidget {
  const OrderListTabs({
    super.key,
    required this.selected,
    required this.onSelect,
  });
  final OrderState? selected;
  final ValueChanged<OrderState?> onSelect;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
    child: Row(
      children: [
        for (final tab in <(String, OrderState?)>[
          ('Tất cả', null),
          ('Chờ xác nhận', OrderState.pending),
          ('Đang giao', OrderState.shipping),
          ('Đã giao', OrderState.delivered),
          ('Đã hủy', OrderState.cancelled),
        ])
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Semantics(
              selected: selected == tab.$2,
              button: true,
              child: InkWell(
                key: ValueKey('order-tab-${tab.$2?.name ?? 'all'}'),
                onTap: () => onSelect(tab.$2),
                borderRadius: BorderRadius.circular(99),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: selected == tab.$2
                          ? P2.rose
                          : tab.$2 == OrderState.cancelled
                          ? const Color(0xFF2C2219)
                          : P2.categoryButton,
                      borderRadius: BorderRadius.circular(99),
                      boxShadow: [
                        BoxShadow(
                          color: selected == tab.$2
                              ? P2.checkoutButton.withValues(alpha: .3)
                              : Colors.black26,
                          offset: const Offset(0, 4),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: Text(
                        tab.$1,
                        style: orderListType(
                          14,
                          color: selected == tab.$2
                              ? orderListText
                              : Colors.white,
                          weight: selected == tab.$2
                              ? FontWeight.w600
                              : FontWeight.w500,
                          height: 20 / 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
