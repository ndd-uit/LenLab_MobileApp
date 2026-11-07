import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

import '../address_styles.dart';
import 'address_field.dart';

class AddressSelect extends StatelessWidget {
  const AddressSelect({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.options,
    required this.enabled,
    required this.onChanged,
  });
  final String label, hint;
  final String? value;
  final List<String> options;
  final bool enabled;
  final ValueChanged<String?> onChanged;
  @override
  Widget build(BuildContext context) => AddressField(
    label: label,
    child: DropdownButtonFormField<String>(
      key: ValueKey('$label-$value-${options.join()}'),
      initialValue: options.contains(value) ? value : null,
      isExpanded: true,
      decoration: addressDecoration(hint),
      hint: Text(
        hint,
        style: const TextStyle(
          fontFamily: 'packages/lenlab_shared/BeVietnamPro',
          fontSize: 16,
          color: P2.ink,
        ),
      ),
      style: const TextStyle(
        fontFamily: 'packages/lenlab_shared/BeVietnamPro',
        fontSize: 16,
        color: P2.ink,
      ),
      icon: P2Asset.node(addressNode, 'imgImage', width: 24, height: 24),
      items: [
        for (final option in options)
          DropdownMenuItem(value: option, child: Text(option)),
      ],
      onChanged: enabled ? onChanged : null,
      validator: (v) => v == null ? 'Vui lòng chọn $label.' : null,
    ),
  );
}
