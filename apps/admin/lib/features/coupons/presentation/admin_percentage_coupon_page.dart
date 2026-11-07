import 'package:flutter/material.dart';

import '../data/admin_percentage_coupon_source.dart';
import 'coupon_example_page.dart';
import 'widgets/coupon_sections.dart';

class AdminPercentageCouponPage extends StatelessWidget {
  const AdminPercentageCouponPage({super.key, this.source, this.onMenu});
  final AdminPercentageCouponSource? source;
  final VoidCallback? onMenu;
  static final _defaultSource = MockAdminPercentageCouponSource();

  @override
  Widget build(BuildContext context) =>
      CouponExamplePage<AdminPercentageCoupon>(
        source: source ?? _defaultSource,
        onMenu: onMenu,
        sections: (example) => CouponSections(example: example),
      );
}
