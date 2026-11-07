import 'package:flutter/material.dart';

import '../../../../app/admin_destination.dart';
import 'coupon_styles.dart';

void backToCouponParent(BuildContext context) {
  final navigator = Navigator.of(context);
  final parent = AdminDestination.dashboard.path;
  var foundParent = false;
  // Reuse the existing overview without leaving voucher routes underneath it.
  navigator.popUntil((route) {
    foundParent = route.settings.name == parent;
    return foundParent || route.isFirst;
  });
  // A direct entry may have no parent in its navigation stack.
  if (!foundParent) navigator.pushReplacementNamed(parent);
}

class CouponHeader extends StatelessWidget {
  const CouponHeader({super.key, this.onMenu});
  final VoidCallback? onMenu;
  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 64),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(bottom: BorderSide(color: couponBorder)),
    ),
    child: Row(
      children: [
        if (onMenu != null)
          IconButton(
            tooltip: 'Mở menu quản trị',
            onPressed: onMenu,
            icon: const Icon(Icons.menu, color: couponInk),
          ),
        const Expanded(
          child: Text(
            'Tạo mã giảm giá mới',
            style: TextStyle(
              fontSize: 18,
              height: 28 / 18,
              fontWeight: FontWeight.w600,
              color: couponInk,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Tooltip(
          message: 'Lưu nháp chưa triển khai trong bản chỉ đọc',
          child: FilledButton(
            key: const ValueKey('coupon-draft'),
            onPressed: null,
            style: couponButtonStyle(),
            child: const Text(
              'Lưu nháp',
              style: TextStyle(fontSize: 14, height: 20 / 14),
            ),
          ),
        ),
      ],
    ),
  );
}

class CouponFooter extends StatelessWidget {
  const CouponFooter({super.key});
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(
      horizontal: MediaQuery.sizeOf(context).width >= 960 ? 64 : 16,
      vertical: 16,
    ),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: couponBorder)),
    ),
    child: Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 896),
        child: SizedBox(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.end,
            spacing: 12,
            runSpacing: 12,
            children: [
              OutlinedButton(
                key: const ValueKey('coupon-cancel'),
                onPressed: () => backToCouponParent(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: couponLabelInk,
                  minimumSize: const Size(0, 48),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Hủy bỏ',
                  style: TextStyle(fontSize: 14, height: 20 / 14),
                ),
              ),
              Tooltip(
                message: 'Tạo mã chưa triển khai trong bản chỉ đọc',
                child: FilledButton.icon(
                  key: const ValueKey('coupon-create'),
                  onPressed: null,
                  style: couponButtonStyle(create: true),
                  icon: couponAsset('imgContainer10', 13, 10),
                  label: const Text(
                    'Tạo mã',
                    style: TextStyle(fontSize: 14, height: 20 / 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
