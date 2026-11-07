import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

const couponCanvas = Color(0xFFF6F6F8);
const couponInk = Color(0xFF0F172A);
const couponLabelInk = Color(0xFF334155);
const couponBlue = Color(0xFF244968);
const couponBrown = Color(0xFF6B3510);
const couponAccent = Color(0xFFE89F70);
const couponBorder = Color(0xFFE2E8F0);

Widget couponAsset(String alias, double width, double height) =>
    P2Asset.node('2026:5399', alias, width: width, height: height);
String? couponNumber(int? value) => value?.toString().replaceAllMapped(
  RegExp(r'(\d)(?=(\d{3})+$)'),
  (m) => '${m[1]}.',
);
Widget couponCard(Widget child) => Container(
  padding: const EdgeInsets.all(24),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: const Color(0x0D0F172A)),
    boxShadow: const [
      BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1)),
    ],
  ),
  child: child,
);
ButtonStyle couponButtonStyle({bool create = false}) => FilledButton.styleFrom(
  backgroundColor: create ? couponAccent : const Color(0x1AE89F70),
  foregroundColor: couponBrown,
  disabledBackgroundColor: create ? couponAccent : const Color(0x1AE89F70),
  disabledForegroundColor: create ? const Color(0xFF523A30) : couponBrown,
  minimumSize: Size(0, create ? 48 : 36),
  padding: EdgeInsets.symmetric(
    horizontal: create ? 24 : 16,
    vertical: create ? 14 : 8,
  ),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
);
