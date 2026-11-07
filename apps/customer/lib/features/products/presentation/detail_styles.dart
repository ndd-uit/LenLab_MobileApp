import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

const detailNode = '2026:869';
const detailRed = Color(0xFF7A2929);
const detailText = Color(0xFF523A30);
const detailOrange = Color(0xFFF09942);
Widget detailAsset(String name, double width, double height) =>
    P2Asset.node(detailNode, name, width: width, height: height);
TextStyle detailSerif(
  double size, {
  FontWeight weight = FontWeight.w500,
  Color color = detailRed,
  double height = 1.4,
}) => P2
    .serif(size, color: color, weight: weight)
    .copyWith(height: height, letterSpacing: 0);
