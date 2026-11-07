import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

export '../../../../shared/layout/admin_styles.dart';

Widget settingsAsset(String alias, double width, double height) =>
    P2Asset.node('2026:6148', alias, width: width, height: height);
const settingsMuted = Color(0xFF6B7280);
const settingsBorder = Color(0xFFF3F4F6);

BoxDecoration settingsSurface() => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(16),
  border: Border.all(color: settingsBorder),
  boxShadow: const [
    BoxShadow(color: Color(0x08000000), offset: Offset(0, 2), blurRadius: 5),
  ],
);
