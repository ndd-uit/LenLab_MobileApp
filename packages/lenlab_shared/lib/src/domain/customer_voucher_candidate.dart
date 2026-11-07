import 'customer_identity.dart';

/// Session-only selection intent. Never an applied coupon or pricing result.
class CustomerVoucherCandidate {
  const CustomerVoucherCandidate({
    required this.campaignId,
    required this.session,
  });

  final String campaignId;
  final CustomerSessionStamp session;
}

/// Explicit local intent to exit the promotion selection shown to the caller.
/// Null targets mean the caller observed no campaign/legacy coupon, not a
/// wildcard permitting a newer selection to be removed.
class VoucherExitIntent {
  const VoucherExitIntent({
    required this.session,
    required this.expectedSelectionRevision,
    this.expectedCampaignId,
    this.expectedLegacyCouponCode,
  });

  final CustomerSessionStamp session;
  final int expectedSelectionRevision;
  final String? expectedCampaignId, expectedLegacyCouponCode;
}
