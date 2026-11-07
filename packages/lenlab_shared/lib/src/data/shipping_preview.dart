import '../domain/customer_identity.dart';

enum ShippingPreviewStatus { ready, needsContext, error }

/// Immutable fee input, never a voucher discount or a reservation.
class ShippingPreview {
  factory ShippingPreview.ready({
    required String contextKey,
    required CustomerSessionStamp session,
    required int grossShippingFeeVnd,
    required int eligibleShippingFeeVnd,
    String reason = 'MOCK_SHIPPING_ONLY',
    int? sourceVersion,
    DateTime? validUntil,
  }) {
    if (contextKey.isEmpty ||
        grossShippingFeeVnd < 0 ||
        eligibleShippingFeeVnd < 0 ||
        eligibleShippingFeeVnd > grossShippingFeeVnd) {
      throw ArgumentError('Invalid shipping fee or context');
    }
    return ShippingPreview._(
      status: ShippingPreviewStatus.ready,
      contextKey: contextKey,
      session: session,
      reason: reason,
      grossShippingFeeVnd: grossShippingFeeVnd,
      eligibleShippingFeeVnd: eligibleShippingFeeVnd,
      sourceVersion: sourceVersion,
      validUntil: validUntil,
    );
  }
  const ShippingPreview.needsContext({
    required this.contextKey,
    required this.session,
    required this.reason,
    this.sourceVersion,
    this.validUntil,
  }) : status = ShippingPreviewStatus.needsContext,
       grossShippingFeeVnd = null,
       eligibleShippingFeeVnd = null;
  const ShippingPreview.error({
    required this.contextKey,
    required this.session,
    required this.reason,
    this.sourceVersion,
    this.validUntil,
  }) : status = ShippingPreviewStatus.error,
       grossShippingFeeVnd = null,
       eligibleShippingFeeVnd = null;
  const ShippingPreview._({
    required this.status,
    required this.contextKey,
    required this.session,
    required this.reason,
    this.grossShippingFeeVnd,
    this.eligibleShippingFeeVnd,
    this.sourceVersion,
    this.validUntil,
  });
  final ShippingPreviewStatus status;
  final String contextKey, reason;
  final CustomerSessionStamp session;
  final int? grossShippingFeeVnd, eligibleShippingFeeVnd, sourceVersion;
  final DateTime? validUntil;
  bool matches(String key, CustomerSessionStamp stamp) =>
      contextKey == key &&
      session.userId == stamp.userId &&
      session.generation == stamp.generation;
  bool validAt(DateTime now) => validUntil == null || now.isBefore(validUntil!);
}
