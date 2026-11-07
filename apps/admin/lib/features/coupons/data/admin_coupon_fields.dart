/// Display values only; unknown values do not imply unlimited or no expiry.
abstract class AdminCouponFields {
  const AdminCouponFields({
    this.code,
    this.minimumOrder,
    this.quantityLimit,
    this.startDateLabel,
    this.expiryDateLabel,
  });
  final String? code, startDateLabel, expiryDateLabel;
  final int? minimumOrder, quantityLimit;
}

abstract interface class AdminCouponSource<T extends AdminCouponFields> {
  Future<T?> fetch();
}
