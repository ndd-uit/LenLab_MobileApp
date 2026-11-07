import 'package:flutter/material.dart';

const conversationInk = Color(0xFF523629);
const conversationSelected = Color(0xFFF7EBDE);

Widget conversationCard({required Widget child, double padding = 16}) =>
    Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );

Widget conversationText(
  String value, {
  double size = 14,
  double height = 1.5,
  bool bold = false,
}) => Text(
  value,
  style: TextStyle(
    fontSize: size,
    height: height,
    color: conversationInk,
    fontWeight: bold ? FontWeight.bold : FontWeight.normal,
  ),
);

Widget conversationDisabledAction(String label, {Key? key}) => Tooltip(
  message: 'Chưa triển khai thao tác này',
  child: FilledButton(
    key: key,
    onPressed: null,
    style: FilledButton.styleFrom(
      disabledBackgroundColor: const Color(0xFFD1A373),
      disabledForegroundColor: const Color(0xFF4D2B1A),
      minimumSize: const Size(0, 48),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    child: Text(label, style: const TextStyle(fontSize: 14, height: 22 / 14)),
  ),
);
