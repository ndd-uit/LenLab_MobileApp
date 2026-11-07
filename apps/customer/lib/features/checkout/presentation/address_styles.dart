import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

const addressNode = '2026:1432';
TextStyle addressSerif(
  double size, {
  FontWeight weight = FontWeight.w400,
  Color color = P2.brown,
}) => P2
    .serif(size, color: color, weight: weight)
    .copyWith(height: 1.5, letterSpacing: 0);
InputDecoration addressDecoration(String hint) => InputDecoration(
  hintText: hint,
  hintStyle: addressSerif(16, color: const Color(0xFF523A30)),
  isDense: true,
  fillColor: P2.rose,
  filled: true,
  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: P2.brown, width: 2),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: P2.brown, width: 2),
  ),
  errorMaxLines: 3,
);
