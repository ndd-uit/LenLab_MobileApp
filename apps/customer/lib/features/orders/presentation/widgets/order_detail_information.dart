import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

import '../order_detail_styles.dart';

class OrderDetailInformation extends StatelessWidget {
  const OrderDetailInformation({super.key, required this.order});
  final Order order;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: orderDetailPanel(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _InfoBlock(
          title: 'ĐỊA CHỈ NHẬN HÀNG',
          icon: 'imgContainer3',
          width: 16,
          height: 20,
          top: true,
          child: Text(
            '${order.address.name}\n${order.address.phone}\n${order.address.street}, ${order.address.ward.replaceFirst('Phường ', 'P. ')},\n${order.address.district}, ${order.address.city}',
            style: orderDetailType(
              14,
              weight: FontWeight.w500,
              height: 22.75 / 14,
            ),
          ),
        ),
        const _Divider(),
        _InfoBlock(
          title: 'THANH TOÁN',
          icon: 'imgContainer4',
          width: 20,
          height: 16,
          child: Text(
            order.payment == PaymentState.cod
                ? paymentLabel(order.payment)
                : 'Chuyển khoản ngân hàng\n${paymentLabel(order.payment)}',
            style: orderDetailType(14, height: 20 / 14),
          ),
        ),
        const _Divider(),
        _MoneyRow('Tạm tính', money(order.subtotal)),
        const SizedBox(height: 10),
        _MoneyRow('Phí vận chuyển', money(order.shipping)),
        const SizedBox(height: 10),
        _MoneyRow(
          'Giảm giá',
          '${order.discount > 0 ? '-' : ''}${money(order.discount)}',
          discount: true,
        ),
        Container(
          margin: const EdgeInsets.only(top: 14),
          padding: const EdgeInsets.only(top: 12),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: .1)),
            ),
          ),
          child: _MoneyRow('Tổng cộng', money(order.total), total: true),
        ),
        if (order.note.isNotEmpty) ...[
          const _Divider(),
          Text(
            'GHI CHÚ ĐƠN HÀNG',
            style: orderDetailType(14, weight: FontWeight.w700, color: P2.ink),
          ),
          const SizedBox(height: 4),
          Text(order.note, style: orderDetailType(14)),
        ],
      ],
    ),
  );
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({
    required this.title,
    required this.icon,
    required this.width,
    required this.height,
    required this.child,
    this.top = false,
  });
  final String title, icon;
  final double width, height;
  final bool top;
  final Widget child;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: top
        ? CrossAxisAlignment.start
        : CrossAxisAlignment.center,
    children: [
      Padding(
        padding: EdgeInsets.only(top: top ? 2 : 0),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: P2.cream.withValues(alpha: .45),
            shape: BoxShape.circle,
          ),
          child: ColorFiltered(
            colorFilter: const ColorFilter.mode(P2.brown, BlendMode.srcIn),
            child: P2Asset.node(
              orderDetailNode,
              icon,
              width: width,
              height: height,
            ),
          ),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: orderDetailType(
                14,
                color: P2.ink,
                weight: FontWeight.w700,
                height: 20 / 14,
              ).copyWith(letterSpacing: .35),
            ),
            const SizedBox(height: 3),
            child,
          ],
        ),
      ),
    ],
  );
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 24),
    child: Divider(
      height: 1,
      thickness: 1,
      color: Colors.white.withValues(alpha: .05),
    ),
  );
}

class _MoneyRow extends StatelessWidget {
  const _MoneyRow(
    this.label,
    this.amount, {
    this.total = false,
    this.discount = false,
  });
  final String label, amount;
  final bool total, discount;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Row(
      crossAxisAlignment: total
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: orderDetailType(
              total ? 16 : 14,
              color: total || discount ? P2.ink : P2.green,
              weight: total ? FontWeight.w700 : FontWeight.w400,
              height: total ? 1.5 : 20 / 14,
            ),
          ),
        ),
        const SizedBox(width: 8),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: constraints.maxWidth * .65),
          child: Text(
            amount,
            textAlign: TextAlign.right,
            style: orderDetailType(
              total ? 24 : 14,
              weight: total ? FontWeight.w700 : FontWeight.w500,
              color: total || discount ? P2.ink : orderDetailText,
              height: total ? 32 / 24 : 20 / 14,
            ),
          ),
        ),
      ],
    ),
  );
}
