import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

const adminCanvas = Color(0xFFF9F6F3);
const adminText = Color(0xFF523A30);
const adminHeading = Color(0xFF4A403A);
const adminActive = Color(0xFF7A2929);
const adminDivider = Color(0xFFF3F4F6);

Widget adminAsset(String name, double width, double height) =>
    P2Asset.node('2026:5862', name, width: width, height: height);

Future<void> adminPendingNotice(
  BuildContext context,
  String title,
  String message,
) => showDialog<void>(
  context: context,
  builder: (dialogContext) => AlertDialog(
    title: Text(title),
    content: Text(message),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(dialogContext),
        child: const Text('Đóng'),
      ),
    ],
  ),
);
