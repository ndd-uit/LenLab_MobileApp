import 'admin_coupon_fields.dart';

/// P2 2026:6470 preview, not a saved or redeemable coupon.
class AdminFixedCoupon extends AdminCouponFields {
  const AdminFixedCoupon({
    this.amount,
    super.code,
    super.minimumOrder,
    super.quantityLimit,
    super.startDateLabel,
    super.expiryDateLabel,
  });
  final int? amount;
}

abstract interface class AdminFixedCouponSource
    implements AdminCouponSource<AdminFixedCoupon> {}

class MockAdminFixedCouponSource implements AdminFixedCouponSource {
  MockAdminFixedCouponSource({
    this.latency = const Duration(milliseconds: 300),
    this.example = adminFixedCouponFixture,
  });
  final Duration latency;
  final AdminFixedCoupon? example;
  bool failNext = false;
  @override
  Future<AdminFixedCoupon?> fetch() async {
    await Future<void>.delayed(latency);
    if (failNext) {
      failNext = false;
      throw StateError('Mock fixed coupon example unavailable');
    }
    return example;
  }
}

const adminFixedCouponFixture = AdminFixedCoupon(
  amount: 50000,
  minimumOrder: 0,
  startDateLabel: '12/05/2024',
);
