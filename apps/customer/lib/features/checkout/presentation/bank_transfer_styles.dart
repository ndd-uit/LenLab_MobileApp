import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

const bankTransferText = Color(0xFF523A30);
const bankTransferNode = '2026:1768';
BoxDecoration bankTransferPanel() => BoxDecoration(
  color: P2.rose,
  border: Border.all(color: P2.brown, width: 2),
  borderRadius: BorderRadius.circular(32),
);
TextStyle bankTransferLabel() => P2
    .serif(12, color: bankTransferText, weight: FontWeight.w500)
    .copyWith(height: 16 / 12, letterSpacing: .6);
