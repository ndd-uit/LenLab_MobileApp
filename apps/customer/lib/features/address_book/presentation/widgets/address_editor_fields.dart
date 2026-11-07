import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

const addressEditorNode = '2026:3872';
const addressEditorText = Color(0xFF523A30);
InputDecoration editorDecoration(
  String hint, {
  String? asset,
  double iconSize = 15,
}) => InputDecoration(
  hintText: hint,
  hintStyle: const TextStyle(color: addressEditorText, fontSize: 16),
  fillColor: P2.rose,
  filled: true,
  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(24),
    borderSide: BorderSide.none,
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(24),
    borderSide: BorderSide.none,
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(24),
    borderSide: const BorderSide(color: P2.brown),
  ),
  prefixIcon: asset == null
      ? null
      : Center(
          widthFactor: 1,
          heightFactor: 1,
          child: P2Asset.node(
            addressEditorNode,
            asset,
            width: iconSize,
            height: iconSize,
          ),
        ),
  prefixIconConstraints: const BoxConstraints(
    minWidth: 44,
    maxWidth: 44,
    minHeight: 48,
  ),
);

class EditorField extends StatelessWidget {
  const EditorField({
    super.key,
    required this.label,
    required this.child,
    this.bold = false,
  });
  final String label;
  final Widget child;
  final bool bold;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: bold ? 14 : 13,
          height: 20 / (bold ? 14 : 13),
          color: addressEditorText,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
      SizedBox(height: bold ? 8 : 6),
      child,
    ],
  );
}

class EditorRegionSelect extends StatelessWidget {
  const EditorRegionSelect({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.options,
    required this.onChanged,
    this.small = false,
  });
  final String label, hint;
  final String? value;
  final List<String> options;
  final ValueChanged<String?>? onChanged;
  final bool small;
  @override
  Widget build(BuildContext context) => EditorField(
    label: label,
    bold: true,
    child: DropdownButtonFormField<String>(
      key: ValueKey('$label-$value-${options.join()}'),
      initialValue: options.contains(value) ? value : null,
      isExpanded: true,
      hint: Text(
        hint,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 13, color: addressEditorText),
      ),
      decoration: editorDecoration('').copyWith(
        hintStyle: const TextStyle(fontSize: 13, color: addressEditorText),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      style: const TextStyle(
        fontFamily: 'packages/lenlab_shared/BeVietnamPro',
        color: addressEditorText,
        fontSize: 13,
      ),
      icon: small
          ? SizedBox(
              width: 24,
              height: 24,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  P2Asset.node(
                    addressEditorNode,
                    'imgImage',
                    width: 24,
                    height: 24,
                  ),
                  P2Asset.node(
                    addressEditorNode,
                    'imgContainer1',
                    width: 12,
                    height: 7.4,
                  ),
                ],
              ),
            )
          : Center(
              widthFactor: 1,
              heightFactor: 1,
              child: P2Asset.node(
                addressEditorNode,
                'imgContainer1',
                width: 12,
                height: 7.4,
              ),
            ),
      items: [
        for (final option in options)
          DropdownMenuItem(value: option, child: Text(option)),
      ],
      onChanged: onChanged,
      validator: (value) =>
          value == null ? 'Vui lòng chọn ${label.toLowerCase()}.' : null,
    ),
  );
}
