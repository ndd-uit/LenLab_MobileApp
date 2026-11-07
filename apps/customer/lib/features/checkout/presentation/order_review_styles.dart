import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

const orderReviewNode = '2026:1520';
const orderReviewBorder = Color(0xFF3E3226);
const orderReviewText = Color(0xFF523A30);
const orderReviewRed = Color(0xFF7A2929);
TextStyle reviewSerif(
  double size, {
  FontWeight weight = FontWeight.w400,
  Color color = P2.brown,
  double height = 1.5,
}) => P2
    .serif(size, weight: weight, color: color)
    .copyWith(height: height, letterSpacing: 0);
String reviewMoney(int amount) => money(amount).replaceAll('đ', '₫');

String reviewVariant(String value) {
  final match = RegExp(r'^(.+) · Size (.+)$').firstMatch(value);
  return match == null
      ? value
      : 'Màu: ${match[1]!.replaceFirst(RegExp(r"^Màu:\s*"), "")} | Size: ${match[2]}';
}
