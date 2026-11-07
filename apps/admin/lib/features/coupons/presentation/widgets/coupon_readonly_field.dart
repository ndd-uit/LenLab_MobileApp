import 'package:flutter/material.dart';

import 'coupon_styles.dart';

class CouponReadonlyField extends StatelessWidget {
  const CouponReadonlyField({
    super.key,
    required this.label,
    this.value,
    this.placeholder,
    this.unit,
    this.assetAlias,
    this.uppercaseLabel = false,
    this.valueSize = 14,
    this.valueColor = couponBlue,
    this.horizontalPadding = 12,
  });
  final String label;
  final String? value, placeholder, unit, assetAlias;
  final bool uppercaseLabel;
  final double valueSize;
  final Color valueColor;
  final double horizontalPadding;
  @override
  Widget build(BuildContext context) {
    final known = value?.trim().isNotEmpty == true;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: uppercaseLabel ? 12 : 14,
            height: uppercaseLabel ? 16 / 12 : 20 / 14,
            fontWeight: FontWeight.w500,
            color: uppercaseLabel ? couponBlue : couponLabelInk,
            letterSpacing: uppercaseLabel ? .3 : null,
          ),
        ),
        const SizedBox(height: 8),
        Semantics(
          label: '$label: ${known ? value : 'Chưa có dữ liệu'}',
          readOnly: true,
          child: ExcludeSemantics(
            child: Container(
              constraints: const BoxConstraints(minHeight: 48),
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                border: Border.all(color: couponBorder),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  if (assetAlias != null) ...[
                    couponAsset(assetAlias!, 17, 17),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      known ? value! : placeholder ?? 'Chưa có dữ liệu',
                      style: TextStyle(
                        fontSize: valueSize,
                        height: 20 / valueSize,
                        color: valueColor,
                      ),
                    ),
                  ),
                  if (unit != null) ...[
                    const SizedBox(width: 12),
                    Text(
                      unit!,
                      style: TextStyle(fontSize: 14, color: valueColor),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
