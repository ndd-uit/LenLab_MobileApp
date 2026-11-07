import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

import '../order_detail_styles.dart';

class OrderDetailStatus extends StatelessWidget {
  const OrderDetailStatus({super.key, required this.order});
  final Order order;
  @override
  Widget build(BuildContext context) => Container(
    decoration: orderDetailPanel(blur: 4),
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                P2.checkoutButton.withValues(alpha: 0),
                P2.checkoutButton.withValues(alpha: .05),
              ],
            ),
            border: Border(
              bottom: BorderSide(color: Colors.white.withValues(alpha: .05)),
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) => Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 12,
              runSpacing: 12,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MÃ ĐƠN HÀNG',
                      style: orderDetailType(
                        12,
                        weight: FontWeight.w500,
                        color: P2.green,
                        height: 16 / 12,
                      ).copyWith(letterSpacing: .6),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '#${order.id}',
                      style: orderDetailType(
                        18,
                        weight: FontWeight.w700,
                        color: orderDetailRed,
                        height: 28 / 18,
                      ),
                    ),
                  ],
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: P2.cream.withValues(alpha: .4),
                      border: Border.all(
                        color: P2.cream.withValues(alpha: .45),
                      ),
                      borderRadius: BorderRadius.circular(99),
                      boxShadow: [
                        BoxShadow(
                          color: P2.checkoutButton.withValues(alpha: .15),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: P2.brown,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            orderLabel(order.state),
                            style: orderDetailType(
                              12,
                              weight: FontWeight.w700,
                              color: P2.brown,
                              height: 16 / 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: Column(
            children: [
              _Step(
                title: 'Đơn hàng đã đặt',
                detail: orderPlacedLabel(order.createdAt),
                kind: 0,
              ),
              _Step(
                title: orderLabel(order.state),
                detail: switch (order.state) {
                  OrderState.pending => 'Chờ shop xác nhận',
                  OrderState.processing => 'Shop đang chuẩn bị đơn hàng',
                  OrderState.shipping => 'Đơn hàng đang được vận chuyển',
                  OrderState.delivered => 'Đơn hàng đã được giao',
                  OrderState.cancelled => 'Đơn hàng đã hủy',
                },
                kind: 1,
              ),
              _Step(
                title: 'Giao hàng',
                detail: switch (order.state) {
                  OrderState.cancelled => 'Đã hủy',
                  OrderState.delivered => 'Đã giao',
                  _ =>
                    order.deliveryEstimate == null
                        ? 'Chưa có lịch giao hàng'
                        : 'Dự kiến: ${order.deliveryEstimate}',
                },
                kind: 2,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Step extends StatelessWidget {
  const _Step({required this.title, required this.detail, required this.kind});
  final String title, detail;
  final int kind;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final titleStyle = orderDetailType(
        kind == 1 ? 16 : 14,
        weight: kind == 1 ? FontWeight.w700 : FontWeight.w600,
        color: kind == 0 ? P2.ink : orderDetailText,
        height: 1,
      );
      final detailStyle = orderDetailType(
        12,
        color: kind == 0 ? P2.ink : orderDetailText,
        height: 16 / 12,
      );
      double textHeight(String text, TextStyle style) => (TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout(maxWidth: math.max(1, constraints.maxWidth - 44))).height;
      final rowHeight = math.max(
        kind == 0
            ? 60.0
            : kind == 1
            ? 66.0
            : 40.0,
        textHeight(title, titleStyle) +
            6 +
            textHeight(detail, detailStyle) +
            (kind < 2 ? 24 : 0) +
            (kind > 0 ? 4 : 0),
      );
      const iconSize = 32.0;
      return SizedBox(
        height: rowHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 32,
              child: Column(
                children: [
                  Container(
                    width: iconSize,
                    height: iconSize,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: kind == 0
                          ? P2.checkoutButton
                          : Colors.white.withValues(alpha: kind == 1 ? 1 : .85),
                      shape: BoxShape.circle,
                    ),
                    child: P2Asset.node(
                      orderDetailNode,
                      'imgContainer${kind == 0 ? '' : kind}',
                      width: kind == 0
                          ? 10.867
                          : kind == 1
                          ? 16.667
                          : 14.667,
                      height: kind == 0
                          ? 8.017
                          : kind == 1
                          ? 16.667
                          : 10.667,
                    ),
                  ),
                  if (kind < 2)
                    Container(
                      width: 2,
                      height: math.max(0, rowHeight - iconSize),
                      color: Colors.white.withValues(
                        alpha: kind == 0 ? 1 : .85,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: kind == 0 ? 0 : 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: titleStyle),
                    const SizedBox(height: 6),
                    Text(detail, style: detailStyle),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
