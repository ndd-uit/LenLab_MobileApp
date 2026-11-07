import 'package:flutter/material.dart';

const adminListInk = Color(0xFF111827);
const adminListMuted = Color(0xFF6B7280);
const adminListBorder = Color(0xFFE5E7EB);

String adminListMoney(int value) =>
    '${value.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.')}₫';

BoxDecoration adminListSurface() => BoxDecoration(
  color: Colors.white,
  border: Border.all(color: adminListBorder),
  borderRadius: BorderRadius.circular(16),
  boxShadow: const [
    BoxShadow(color: Color(0x0D000000), offset: Offset(0, 1), blurRadius: 2),
  ],
);
