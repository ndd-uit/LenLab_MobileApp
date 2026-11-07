import 'package:flutter/material.dart';

import '../data/admin_fixed_coupon_source.dart';
import 'coupon_example_page.dart';
import 'widgets/coupon_sections.dart';

class AdminFixedCouponPage extends StatelessWidget {
  const AdminFixedCouponPage({super.key, this.source, this.onMenu});
  final AdminFixedCouponSource? source;
  final VoidCallback? onMenu;
  static final _defaultSource = MockAdminFixedCouponSource();

  @override
  Widget build(BuildContext context) => CouponExamplePage<AdminFixedCoupon>(
    source: source ?? _defaultSource,
    onMenu: onMenu,
    sections: (example) => CouponSections(example: example),
  );
}
