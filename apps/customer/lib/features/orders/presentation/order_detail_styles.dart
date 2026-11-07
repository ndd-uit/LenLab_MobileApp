import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

const orderDetailNode = '2026:2009';
const orderDetailText = Color(0xFF523A30);
const orderDetailRed = Color(0xFF7A2929);
TextStyle orderDetailType(
  double size, {
  FontWeight weight = FontWeight.w400,
  Color color = orderDetailText,
  double height = 1.5,
}) => TextStyle(
  fontFamily: 'packages/lenlab_shared/BeVietnamPro',
  fontSize: size,
  fontWeight: weight,
  color: color,
  letterSpacing: 0,
  height: height,
);
BoxDecoration orderDetailPanel({double radius = 32, double blur = 2}) =>
    BoxDecoration(
      color: P2.rose,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Colors.white.withValues(alpha: .05)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .25),
          offset: const Offset(0, 4),
          blurRadius: blur,
        ),
      ],
    );
String orderPlacedLabel(DateTime? date) {
  if (date == null) return 'Chưa có thời gian đặt đơn';
  String two(int value) => value.toString().padLeft(2, '0');
  return '${two(date.hour)}:${two(date.minute)}, ${two(date.day)}/${two(date.month)}/${date.year}';
}

String orderDetailVariant(String variant) {
  final match = RegExp(r'^(.+) · Size (.+)$').firstMatch(variant);
  return match == null
      ? variant
      : 'Màu: ${match[1]!.replaceFirst(RegExp(r"^Màu:\s*"), "")} • Size ${match[2]}';
}
