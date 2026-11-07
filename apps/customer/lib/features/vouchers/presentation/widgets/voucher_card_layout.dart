import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/voucher_source.dart';

/// Shared slots are measured for the whole wallet so each ticket aligns.
class VoucherCardLayout {
  const VoucherCardLayout(
    this.titleHeight,
    this.descriptionHeight,
    this.buttonWidth,
    this.stackFooter,
  );
  final double titleHeight, descriptionHeight, buttonWidth;
  final bool stackFooter;

  factory VoucherCardLayout.measure(
    List<WalletVoucher> vouchers,
    double width,
    TextScaler scaler,
    TextDirection direction,
  ) {
    double measure(
      String text,
      double size,
      double height,
      FontWeight weight, {
      double? maxWidth,
    }) {
      final painter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontFamily: 'packages/lenlab_shared/BeVietnamPro',
            fontSize: size,
            height: height,
            fontWeight: weight,
            letterSpacing: .25,
          ),
        ),
        textScaler: scaler,
        textDirection: direction,
      )..layout(maxWidth: maxWidth ?? double.infinity);
      final result = maxWidth == null ? painter.width : painter.height;
      painter.dispose();
      return result;
    }

    final contentWidth = width * .7 - 32;
    var title = scaler.scale(20), description = scaler.scale(32);
    var button = 0.0, expiry = 0.0;
    for (final voucher in vouchers) {
      final badgeWidth = voucher.isNew
          ? measure('Mới', 10, 1.5, FontWeight.w700) + 24
          : 0;
      title = math.max(
        title,
        measure(
          voucher.title,
          16,
          1.25,
          FontWeight.w700,
          maxWidth: contentWidth - badgeWidth,
        ),
      );
      description = math.max(
        description,
        measure(
          voucher.description,
          12,
          16 / 12,
          FontWeight.w400,
          maxWidth: contentWidth,
        ),
      );
      expiry = math.max(
        expiry,
        measure(voucher.expiry, 12, 16 / 12, FontWeight.w500),
      );
    }
    for (final label in ['Dùng ngay', 'Hết hạn', 'Đã dùng', 'Sao chép']) {
      button = math.max(
        button,
        measure(label, 12, 16 / 12, FontWeight.w700) +
            32 +
            (label == 'Sao chép' ? 13.917 : 0),
      );
    }
    return VoucherCardLayout(
      title,
      description,
      button.ceilToDouble(),
      expiry + button + 8 > contentWidth,
    );
  }
}
