import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

import '../../../../shared/widgets/admin_detail_card.dart';

import '../../data/admin_order_detail.dart';
import 'order_styles.dart';

Widget detailAsset(String alias, double width, double height) =>
    P2Asset.node('2026:7320', alias, width: width, height: height);

class OrderDetailCard extends AdminDetailCard {
  const OrderDetailCard({
    super.key,
    required super.title,
    required super.icon,
    required super.child,
    super.trailing,
  });
}

class OrderCustomerCard extends StatelessWidget {
  const OrderCustomerCard({super.key, required this.detail});
  final AdminOrderDetail detail;
  @override
  Widget build(BuildContext context) => OrderDetailCard(
    title: 'Thông tin khách hàng',
    icon: detailAsset('imgContainer12', 12.023, 12.023),
    trailing: const Tooltip(
      message: 'Sửa khách hàng chưa triển khai',
      child: TextButton(
        onPressed: null,
        style: ButtonStyle(
          minimumSize: WidgetStatePropertyAll(Size.zero),
          padding: WidgetStatePropertyAll(EdgeInsets.zero),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text('Sửa'),
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: detailAsset('imgContainer13', 19.969, 19.969),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  detail.summary.customerName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: adminListInk,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _info(detailAsset('imgMargin', 13.47, 15.47), detail.summary.phone),
          _info(
            detailAsset('imgMargin1', 14.977, 14.023),
            detail.email ?? 'Chưa có email',
          ),
          _info(
            detailAsset('imgMargin2', 12.023, 16.739),
            detail.address ?? 'Chưa có địa chỉ giao hàng',
          ),
          const Divider(height: 32, color: adminListBorder),
          const Text(
            'GHI CHÚ TỪ KHÁCH',
            style: TextStyle(fontSize: 12, color: adminListMuted),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEFCE8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              detail.summary.note ?? 'Không có ghi chú',
              style: const TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Color(0xFF4B5563),
              ),
            ),
          ),
        ],
      ),
    ),
  );
  Widget _info(Widget icon, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 16, child: icon),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              height: 20 / 14,
              color: Color(0xFF374151),
            ),
          ),
        ),
      ],
    ),
  );
}

class OrderPaymentCard extends StatelessWidget {
  const OrderPaymentCard({super.key, required this.detail});
  final AdminOrderDetail detail;
  @override
  Widget build(BuildContext context) => OrderDetailCard(
    title: 'Thông tin thanh toán',
    icon: detailAsset('imgContainer14', 16.523, 12.023),
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 12,
            runSpacing: 8,
            children: [
              const Text(
                'Phương thức:',
                style: TextStyle(color: adminListMuted),
              ),
              Text(
                detail.summary.payment.label,
                style: const TextStyle(
                  color: adminListInk,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Trạng thái: Chưa có dữ liệu xác nhận',
            style: TextStyle(fontSize: 14, color: adminListMuted),
          ),
        ],
      ),
    ),
  );
}

class OrderHistoryCard extends StatelessWidget {
  const OrderHistoryCard({super.key});
  @override
  Widget build(BuildContext context) => OrderDetailCard(
    title: 'Lịch sử đơn hàng',
    icon: detailAsset('imgContainer18', 15.201, 13.503),
    child: const Padding(
      padding: EdgeInsets.all(24),
      child: Text(
        'Chưa có dữ liệu lịch sử đơn hàng.',
        style: TextStyle(fontSize: 14, color: adminListMuted),
      ),
    ),
  );
}
