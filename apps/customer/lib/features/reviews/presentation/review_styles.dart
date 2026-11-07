import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

const reviewRed = Color(0xFF9B4B3E);
const reviewText = Color(0xFF523A30);
Widget reviewAsset(String name, double width, double height) =>
    P2Asset.node('2026:1037', name, width: width, height: height);

void reviewNotice(BuildContext context, String message) => showDialog<void>(
  context: context,
  builder: (dialog) => AlertDialog(
    title: const Text('Bản dùng thử'),
    content: Text(message),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(dialog),
        child: const Text('Đóng'),
      ),
    ],
  ),
);
