import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

import '../../../../shared/widgets/admin_detail_card.dart';
import '../../data/admin_customer_detail.dart';
import '../../data/admin_customer.dart';
import 'customer_styles.dart';

Widget customerDetailAsset(String alias, double width, double height) =>
    P2Asset.node('2026:9129', alias, width: width, height: height);

InputDecoration customerLockedInput({String? hint, Widget? prefix}) =>
    InputDecoration(
      enabled: false,
      hintText: hint,
      prefixIcon: prefix,
      isDense: true,
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      hintStyle: const TextStyle(
        fontSize: 14,
        height: 20 / 14,
        color: adminListMuted,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
    );

class CustomerPersonalCard extends StatelessWidget {
  const CustomerPersonalCard({super.key, required this.detail});
  final AdminCustomerDetail detail;
  @override
  Widget build(BuildContext context) => AdminDetailCard(
    title: 'Thông tin cá nhân',
    icon: customerDetailAsset('imgContainer12', 16.031, 16.031),
    trailing: Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: detail.customer.status == AdminCustomerStatus.active
            ? const Color(0xFFDCFCE7)
            : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        detail.customer.status.label,
        style: TextStyle(
          fontSize: 12,
          color: detail.customer.status == AdminCustomerStatus.active
              ? const Color(0xFF166534)
              : const Color(0xFF4B5563),
        ),
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final identity = Column(
            children: [
              Container(
                width: 96,
                height: 96,
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  color: Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: detail.customer.avatarAlias == null
                      ? customerDetailAsset('imgContainer13', 32.063, 32.063)
                      : customerAsset(detail.customer.avatarAlias!, 96, 96),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                detail.customer.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: adminListInk,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                detail.customer.email,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: adminListMuted),
              ),
              const SizedBox(height: 4),
              Text(
                detail.customer.phone,
                style: const TextStyle(fontSize: 14, color: adminListMuted),
              ),
            ],
          );
          final metrics = LayoutBuilder(
            builder: (context, box) {
              final columns = box.maxWidth >= 340 ? 2 : 1;
              final width = (box.maxWidth - (columns - 1) * 16) / columns;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  for (final entry in [
                    (
                      'NGÀY THAM GIA',
                      detail.joinedAt == null
                          ? 'Chưa có dữ liệu'
                          : '${detail.joinedAt!.day.toString().padLeft(2, '0')}/${detail.joinedAt!.month.toString().padLeft(2, '0')}/${detail.joinedAt!.year}',
                    ),
                    (
                      'TỔNG CHI TIÊU',
                      detail.totalSpent == null
                          ? 'Chưa có dữ liệu'
                          : adminListMoney(detail.totalSpent!),
                    ),
                    ('HẠNG THÀNH VIÊN', detail.membership ?? 'Chưa có dữ liệu'),
                    (
                      'ĐỊA CHỈ MẶC ĐỊNH',
                      detail.defaultAddress ?? 'Chưa có dữ liệu',
                    ),
                  ])
                    SizedBox(
                      width: width,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          border: Border.all(color: const Color(0xFFF3F4F6)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.$1,
                              style: const TextStyle(
                                fontSize: 12,
                                height: 16 / 12,
                                fontWeight: FontWeight.w500,
                                color: adminListMuted,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              entry.$2,
                              style: TextStyle(
                                fontSize: 14,
                                height: 20 / 14,
                                fontWeight: entry.$1 == 'TỔNG CHI TIÊU'
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: entry.$1 == 'TỔNG CHI TIÊU'
                                    ? const Color(0xFF6B3510)
                                    : adminListInk,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          );
          return ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxWidth >= 580 ? 272 : 0,
            ),
            child: constraints.maxWidth >= 580
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width:
                            200 *
                            MediaQuery.textScalerOf(context).scale(14) /
                            14,
                        child: identity,
                      ),
                      const SizedBox(width: 24),
                      Expanded(child: metrics),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [identity, const SizedBox(height: 24), metrics],
                  ),
          );
        },
      ),
    ),
  );
}

class CustomerAccountCard extends StatelessWidget {
  const CustomerAccountCard({super.key, required this.customer});
  final AdminCustomer customer;
  @override
  Widget build(BuildContext context) => AdminDetailCard(
    title: 'Quản lý tài khoản',
    icon: customerDetailAsset('imgContainer15', 19.031, 22.031),
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Trạng thái khóa',
            style: TextStyle(fontSize: 14, color: adminListInk),
          ),
          Row(
            children: [
              SizedBox(
                width: 44,
                height: 24,
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: Switch(
                    value: customer.status == AdminCustomerStatus.blocked,
                    onChanged: null,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    thumbColor: const WidgetStatePropertyAll(Colors.white),
                    trackOutlineColor: const WidgetStatePropertyAll(
                      Colors.transparent,
                    ),
                    trackColor: WidgetStatePropertyAll(
                      customer.status == AdminCustomerStatus.blocked
                          ? customerAccent
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Khóa tài khoản',
                  style: TextStyle(fontSize: 14, color: adminListInk),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Lý do khóa / Mở khóa',
            style: TextStyle(fontSize: 14, color: adminListInk),
          ),
          const SizedBox(height: 8),
          InputDecorator(
            decoration: customerLockedInput(),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Chưa có dữ liệu lý do',
                    style: TextStyle(fontSize: 14, color: adminListMuted),
                  ),
                ),
                customerDetailAsset('imgImage', 21, 21),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Ghi chú thêm',
            style: TextStyle(fontSize: 14, color: adminListInk),
          ),
          const SizedBox(height: 8),
          TextField(
            enabled: false,
            maxLines: 2,
            style: const TextStyle(
              fontSize: 14,
              height: 20 / 14,
              color: adminListMuted,
            ),
            decoration: customerLockedInput(
              hint: 'Chưa có dữ liệu ghi chú quản trị',
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Chỉ đọc • Chưa hỗ trợ thay đổi tài khoản',
            style: TextStyle(fontSize: 12, color: adminListMuted),
          ),
          const SizedBox(height: 4),
          Text(
            'Vai trò: ${customer.role.label}',
            style: const TextStyle(fontSize: 12, color: adminListMuted),
          ),
        ],
      ),
    ),
  );
}

class CustomerHistoryCard extends StatelessWidget {
  const CustomerHistoryCard({super.key});
  Widget _controls() => Row(
    children: [
      Expanded(
        child: TextField(
          enabled: false,
          style: const TextStyle(fontSize: 14, height: 20 / 14),
          decoration: customerLockedInput(
            hint: 'Tìm đơn hàng...',
            prefix: Center(
              widthFactor: 1,
              heightFactor: 1,
              child: customerDetailAsset('imgContainer17', 13, 13),
            ),
          ),
        ),
      ),
      const SizedBox(width: 8),
      Tooltip(
        message: 'Chưa có dữ liệu lịch sử để lọc',
        child: IconButton.outlined(
          onPressed: null,
          style: IconButton.styleFrom(
            side: const BorderSide(color: Color(0xFFD1D5DB)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          icon: customerDetailAsset('imgContainer18', 15, 10),
        ),
      ),
    ],
  );
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final wide =
          c.maxWidth >= 700 && MediaQuery.textScalerOf(context).scale(14) <= 16;
      return AdminDetailCard(
        title: 'Lịch sử mua hàng',
        icon: customerDetailAsset('imgContainer16', 20.267, 18.004),
        trailing: wide ? SizedBox(width: 296, child: _controls()) : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!wide)
              Padding(padding: const EdgeInsets.all(24), child: _controls()),
            Padding(
              padding: EdgeInsets.fromLTRB(24, wide ? 24 : 0, 24, 24),
              child: const Text(
                'Chưa có dữ liệu lịch sử mua hàng liên kết với người dùng này.',
                style: TextStyle(fontSize: 14, color: adminListMuted),
              ),
            ),
          ],
        ),
      );
    },
  );
}
