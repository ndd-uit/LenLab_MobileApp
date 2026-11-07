import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

import '../order_list_styles.dart';
import '../../../reviews/presentation/review_navigation.dart';
import '../buy_again_dialog.dart';

class OrderListCard extends StatefulWidget {
  const OrderListCard({
    super.key,
    required this.order,
    required this.onDetails,
  });
  final Order order;
  final VoidCallback onDetails;

  @override
  State<OrderListCard> createState() => _OrderListCardState();
}

class _OrderListCardState extends State<OrderListCard> {
  bool buyingAgain = false;

  Future<void> buyAgain() async {
    if (buyingAgain) return;
    setState(() => buyingAgain = true);
    try {
      await openBuyAgain(context, widget.order);
    } finally {
      if (mounted) setState(() => buyingAgain = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final onDetails = widget.onDetails;
    final cancelled = order.state == OrderState.cancelled;
    final count = order.lines.fold<int>(0, (sum, line) => sum + line.quantity);
    final date = order.createdAt;
    final dateLabel = date == null
        ? 'Chưa có ngày đặt'
        : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    return Opacity(
      opacity: cancelled ? .75 : 1,
      child: Material(
        color: P2.rose,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: P2.brown, width: 2),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onDetails,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  runSpacing: 6,
                  spacing: 8,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mã đơn: #${order.id}',
                          style: orderListType(
                            12,
                            serif: true,
                            weight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        _Status(state: order.state),
                      ],
                    ),
                    Text(
                      dateLabel,
                      style: orderListType(12, weight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withValues(alpha: .1),
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.only(top: 16, bottom: 12),
                  child: order.lines.isEmpty
                      ? Text(
                          'Chưa có thông tin sản phẩm',
                          style: orderListType(12, serif: true),
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            P2Asset(
                              order.lines.first.product.image,
                              width: 80,
                              height: 80,
                              radius: 16,
                              label: order.lines.first.product.name,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  minHeight: 80,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      order.lines
                                          .map((line) => line.product.name)
                                          .join(' và '),
                                      style: orderListType(
                                        14,
                                        color: cancelled ? P2.brown : P2.ink,
                                        weight: FontWeight.w600,
                                        serif: true,
                                        height: 1.25,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    if (order.lines.first.variant.isNotEmpty)
                                      Text(
                                        'Phân loại: ${order.lines.first.variant}',
                                        style: orderListType(12, serif: true),
                                      ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'x$count',
                                      style: orderListType(12, serif: true),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: cancelled
                            ? P2.brown
                            : Colors.white.withValues(alpha: .05),
                        width: cancelled ? 2 : 1,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.only(top: 13),
                  child: _FooterLayout(
                    order: order,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Tổng tiền ($count sản phẩm)',
                            style: orderListType(12, serif: true),
                          ),
                          Text(
                            money(order.total),
                            style:
                                orderListType(
                                  18,
                                  color: cancelled
                                      ? orderListText
                                      : orderListRed,
                                  weight: FontWeight.w700,
                                  height: 28 / 18,
                                ).copyWith(
                                  decoration: cancelled
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                          ),
                        ],
                      ),
                      if (order.state == OrderState.delivered)
                        Wrap(
                          alignment: WrapAlignment.end,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _Action(
                              'Mua lại',
                              outline: true,
                              onPressed: buyingAgain ? null : buyAgain,
                            ),
                            _Action(
                              'Đánh giá',
                              onPressed: () =>
                                  openOrderReview(context, order.id),
                            ),
                          ],
                        )
                      else
                        _Action(
                          cancelled ? 'Xem lại' : 'Chi tiết',
                          plain: cancelled,
                          onPressed: onDetails,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Keep the amount at the left; move only the actions when text needs more room.
class _FooterLayout extends StatelessWidget {
  const _FooterLayout({required this.order, required this.children});
  final Order order;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      double textWidth(String text, TextStyle style) {
        final painter = TextPainter(
          text: TextSpan(text: text, style: style),
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout();
        final width = painter.width;
        painter.dispose();
        return width;
      }

      final amountWidth = textWidth(
        money(order.total),
        orderListType(18, weight: FontWeight.w700),
      );
      final actionStyle = orderListType(14, weight: FontWeight.w600);
      final actionsWidth = order.state == OrderState.delivered
          ? textWidth('Mua lại', actionStyle) +
                30 +
                8 +
                textWidth('Đánh giá', actionStyle) +
                32
          : textWidth(
                  order.state == OrderState.cancelled ? 'Xem lại' : 'Chi tiết',
                  actionStyle,
                ) +
                32;
      if (constraints.maxWidth >= amountWidth + 8 + actionsWidth) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: children.first),
            const SizedBox(width: 8),
            children.last,
          ],
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          children.first,
          const SizedBox(height: 8),
          Align(alignment: Alignment.centerRight, child: children.last),
        ],
      );
    },
  );
}

class _Status extends StatelessWidget {
  const _Status({required this.state});
  final OrderState state;
  @override
  Widget build(BuildContext context) {
    final (asset, width, height) = switch (state) {
      OrderState.shipping => ('imgContainer1', 12.833, 9.333),
      OrderState.delivered => ('imgContainer3', 11.667, 11.667),
      OrderState.cancelled => ('imgContainer6', 11.667, 11.667),
      OrderState.pending ||
      OrderState.processing => ('imgContainer4', 9.333, 11.667),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: state == OrderState.shipping
            ? const Color(0x3322C55E)
            : P2.cream.withValues(alpha: .4),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          P2Asset.node(orderListNode, asset, width: width, height: height),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              orderLabel(state),
              style: orderListType(
                12,
                color: orderListStatusColor(state),
                weight: FontWeight.w500,
                serif: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action(
    this.label, {
    required this.onPressed,
    this.outline = false,
    this.plain = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool outline, plain;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: onPressed != null,
    child: InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: outline || plain
                ? Colors.transparent
                : P2.cream.withValues(alpha: .45),
            borderRadius: BorderRadius.circular(16),
            border: outline ? Border.all(color: const Color(0xFF374151)) : null,
            boxShadow: outline || plain
                ? null
                : const [
                    BoxShadow(
                      color: Color(0x1F000000),
                      offset: Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: outline ? 15 : 16,
              vertical: 8,
            ),
            child: Text(
              label,
              style: orderListType(
                14,
                color: outline
                    ? P2.ink
                    : plain
                    ? orderListText
                    : P2.brown,
                weight: plain ? FontWeight.w700 : FontWeight.w600,
                height: 20 / 14,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
