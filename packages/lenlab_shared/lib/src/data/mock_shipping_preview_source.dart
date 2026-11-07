import 'dart:convert';

import '../state/lenlab_store.dart';
import 'shipping_preview.dart';
import 'shipping_preview_source.dart';
import 'voucher_evaluation.dart';

typedef MockShippingLoader = Future<ShippingPreview> Function(
  VoucherEvaluationContext context,
);

/// Explicitly injected mock fee loader. No default fee, address or TTL.
/// Shares one immutable READY result / pending Future per current context.
class MockShippingPreviewSource implements ShippingPreviewSource {
  MockShippingPreviewSource(
    this.store, {
    required this.loader,
    DateTime Function()? clock,
  }) : clock = clock ?? DateTime.now;
  final LenlabStore store;
  final MockShippingLoader loader;
  final DateTime Function() clock;
  ShippingPreview? _cached;
  Future<ShippingPreview>? _pending;
  String? _pendingKey;
  int _sequence = 0;

  bool _current(VoucherEvaluationContext c) {
    if (!store.isCurrentSession(c.session) || c.key != store.voucherContextKey) {
      return false;
    }
    final actual = store.captureVoucherContext();
    String lines(VoucherEvaluationContext x) => jsonEncode(
      x.lines
          .map((l) => [l.productId, l.variant, l.quantity, l.unitPriceVnd])
          .toList(),
    );
    return c.hasAddress == actual.hasAddress &&
        c.legacyCoupon == actual.legacyCoupon &&
        lines(c) == lines(actual);
  }

  ShippingPreview? get currentPreview {
    final p = _cached;
    if (p == null ||
        !store.isCurrentSession(p.session) ||
        p.contextKey != store.voucherContextKey ||
        !p.validAt(clock())) {
      return null;
    }
    return p;
  }

  @override
  Future<ShippingPreview> load(
    VoucherEvaluationContext c, {
    bool force = false,
  }) {
    if (!_current(c)) {
      return Future.value(
        ShippingPreview.error(
          contextKey: c.key,
          session: c.session,
          reason: 'SHIPPING_CONTEXT_CHANGED',
        ),
      );
    }
    if (!c.hasAddress || c.lines.isEmpty) {
      return Future.value(
        ShippingPreview.needsContext(
          contextKey: c.key,
          session: c.session,
          reason: !c.hasAddress ? 'ADDRESS_REQUIRED' : 'EMPTY_SELECTION',
        ),
      );
    }
    if (!force && _pending != null && _pendingKey == c.key) return _pending!;
    if (!force && currentPreview != null) return Future.value(currentPreview!);
    final sequence = ++_sequence;
    _cached = null;
    _pendingKey = c.key;
    _pending = _load(c, sequence);
    return _pending!;
  }

  Future<ShippingPreview> _load(
    VoucherEvaluationContext c,
    int sequence,
  ) async {
    ShippingPreview error(String reason) => ShippingPreview.error(
      contextKey: c.key,
      session: c.session,
      reason: reason,
    );
    bool active() => sequence == _sequence && _current(c);
    try {
      final preview = await loader(c);
      if (!active()) return error('SHIPPING_CONTEXT_CHANGED');
      if (!preview.matches(c.key, c.session)) {
        return error('SHIPPING_CONTEXT_CHANGED');
      }
      if (!preview.validAt(clock())) return error('SHIPPING_PREVIEW_EXPIRED');
      if (preview.status == ShippingPreviewStatus.ready) _cached = preview;
      return preview;
    } on ArgumentError {
      return error(
        active() ? 'INVALID_SHIPPING_FEE' : 'SHIPPING_CONTEXT_CHANGED',
      );
    } catch (_) {
      return error(
        active() ? 'SHIPPING_UNAVAILABLE' : 'SHIPPING_CONTEXT_CHANGED',
      );
    } finally {
      if (sequence == _sequence) {
        _pending = null;
        _pendingKey = null;
      }
    }
  }
}
