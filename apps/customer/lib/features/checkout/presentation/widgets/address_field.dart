import 'package:flutter/material.dart';

import '../address_styles.dart';

class AddressField extends StatelessWidget {
  const AddressField({super.key, required this.label, required this.child});
  final String label;
  final Widget child;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: addressSerif(14, weight: FontWeight.w500)),
      const SizedBox(height: 8),
      child,
    ],
  );
}
