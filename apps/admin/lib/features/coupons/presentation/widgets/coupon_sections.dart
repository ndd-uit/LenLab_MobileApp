import 'package:flutter/material.dart';

import '../../data/admin_percentage_coupon_source.dart';
import '../../data/admin_fixed_coupon_source.dart';
import '../../data/admin_coupon_fields.dart';
import 'coupon_styles.dart';
import 'coupon_readonly_field.dart';

class CouponSections extends StatelessWidget {
  const CouponSections({super.key, required this.example});
  final AdminCouponFields example;
  bool get fixed => example is AdminFixedCoupon;
  Widget limited(Widget child) => Align(
    alignment: Alignment.centerLeft,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 576),
      child: child,
    ),
  );
  Widget pair(Widget left, Widget right) => LayoutBuilder(
    builder: (context, c) =>
        c.maxWidth >= 650 && MediaQuery.textScalerOf(context).scale(14) <= 16
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: left),
              const SizedBox(width: 24),
              Expanded(child: right),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [left, const SizedBox(height: 24), right],
          ),
  );
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      couponCard(
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            limited(
              CouponReadonlyField(
                label: 'Mã giảm giá',
                valueSize: 16,
                value: example.code,
                placeholder: 'VÍ DỤ: LENLABSALE50',
                assetAlias: 'imgContainer12',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Chỉ sử dụng chữ cái (A-Z) và số (0-9).',
              style: TextStyle(
                fontSize: 14,
                height: 20 / 14,
                color: couponBlue,
              ),
            ),
            const SizedBox(height: 24),
            limited(
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Loại giảm giá',
                    style: TextStyle(
                      fontSize: 14,
                      height: 20 / 14,
                      color: couponLabelInk,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: LayoutBuilder(
                      builder: (context, c) {
                        final percent = _type(
                          context,
                          'Theo %',
                          'imgContainer13',
                          !fixed,
                          '/vouchers/percentage',
                        );
                        final fixedType = _type(
                          context,
                          'Số tiền cố định',
                          'imgContainer14',
                          fixed,
                          '/vouchers/fixed',
                        );
                        return c.maxWidth >= 360 &&
                                MediaQuery.textScalerOf(context).scale(14) <= 16
                            ? Row(
                                children: [
                                  Expanded(child: percent),
                                  const SizedBox(width: 4),
                                  Expanded(child: fixedType),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  percent,
                                  const SizedBox(height: 4),
                                  fixedType,
                                ],
                              );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (example case final AdminFixedCoupon value)
              CouponReadonlyField(
                label: 'Giá trị giảm *',
                value: couponNumber(value.amount),
                unit: 'đ',
                valueColor: const Color(0xFF523A30),
                horizontalPadding: 16,
              )
            else if (example case final AdminPercentageCoupon value)
              pair(
                CouponReadonlyField(
                  label: 'Giá trị giảm *',
                  value: couponNumber(value.percentage),
                  unit: '%',
                ),
                CouponReadonlyField(
                  label: 'Giảm tối đa (nếu theo %)',
                  value: couponNumber(value.maximumDiscount),
                  unit: 'đ',
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      _heading('Điều kiện áp dụng'),
      const SizedBox(height: 16),
      couponCard(
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            limited(
              CouponReadonlyField(
                label: 'Giá trị đơn hàng tối thiểu',
                valueSize: 16,
                value: couponNumber(example.minimumOrder),
                unit: 'VNĐ',
              ),
            ),
            const SizedBox(height: 24),
            limited(
              CouponReadonlyField(
                label: 'Giới hạn số lượng',
                valueSize: 16,
                value: couponNumber(example.quantityLimit),
                placeholder: 'Nhập số lượng mã (ví dụ: 100)',
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      _heading('Thời gian áp dụng'),
      const SizedBox(height: 16),
      couponCard(
        pair(
          CouponReadonlyField(
            label: 'NGÀY BẮT ĐẦU',
            value: example.startDateLabel,
            assetAlias: 'imgContainer15',
            uppercaseLabel: true,
          ),
          CouponReadonlyField(
            label: 'NGÀY HẾT HẠN',
            value: example.expiryDateLabel,
            placeholder: 'dd/mm/yyyy',
            assetAlias: 'imgContainer16',
            uppercaseLabel: true,
          ),
        ),
      ),
    ],
  );
  Widget _heading(String text) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        height: 1.5,
        fontWeight: FontWeight.w600,
        color: couponInk,
      ),
    ),
  );
  Widget _type(
    BuildContext context,
    String label,
    String asset,
    bool selected,
    String route,
  ) => Semantics(
    key: ValueKey(
      route.endsWith('fixed') ? 'coupon-type-fixed' : 'coupon-type-percentage',
    ),
    selected: selected,
    button: true,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () {
          if (!selected) Navigator.of(context).pushReplacementNamed(route);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              couponAsset(asset, 12, 14),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    height: 20 / 14,
                    color: fixed
                        ? const Color(0xFF523B30)
                        : selected
                        ? couponBrown
                        : couponBlue,
                    fontWeight: FontWeight.w500,
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
