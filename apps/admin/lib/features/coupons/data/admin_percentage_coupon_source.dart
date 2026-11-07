import 'admin_coupon_fields.dart';

/// Display-only P2 example. No redemption rules or saved coupon identity.
class AdminPercentageCoupon extends AdminCouponFields {
  const AdminPercentageCoupon({
    super.code,
    this.percentage,
    this.maximumDiscount,
    super.minimumOrder,
    super.quantityLimit,
    super.startDateLabel,
    super.expiryDateLabel,
  });
  final int? percentage, maximumDiscount;
}

abstract interface class AdminPercentageCouponSource
    implements AdminCouponSource<AdminPercentageCoupon> {}

class MockAdminPercentageCouponSource implements AdminPercentageCouponSource {
  MockAdminPercentageCouponSource({
    this.latency = const Duration(milliseconds: 300),
    this.example = adminPercentageCouponFixture,
  });
  final Duration latency;
  final AdminPercentageCoupon? example;
  bool failNext = false;
  @override
  Future<AdminPercentageCoupon?> fetch() async {
    await Future<void>.delayed(latency);
    if (failNext) {
      failNext = false;
      throw StateError('Mock coupon example unavailable');
    }
    return example;
  }
}

const adminPercentageCouponFixture = AdminPercentageCoupon(
  percentage: 20,
  maximumDiscount: 50000,
  minimumOrder: 0,
  startDateLabel: '12/05/2024',
);
