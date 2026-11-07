import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

const authFont = 'packages/lenlab_shared/BeVietnamPro';
const authText = Color(0xFF523A30);
const authShadow = [
  BoxShadow(
    color: Color(0x1A000000),
    offset: Offset(0, 10),
    blurRadius: 15,
    spreadRadius: -3,
  ),
  BoxShadow(
    color: Color(0x1A000000),
    offset: Offset(0, 4),
    blurRadius: 6,
    spreadRadius: -4,
  ),
];

class AuthBanner extends StatelessWidget {
  const AuthBanner({super.key});
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      boxShadow: authShadow,
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 201,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const P2Asset('f51f2.png'),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    const Color(0xFF221910).withValues(alpha: .8),
                  ],
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white, width: 8),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class AuthField extends StatelessWidget {
  const AuthField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.validator,
    required this.suffix,
    required this.autofillHints,
    this.obscure = false,
    this.onSubmitted,
    this.letterSpacing = -1,
    this.p2Validation = false,
    this.autovalidateMode = AutovalidateMode.disabled,
  });
  final String label, hint;
  final TextEditingController controller;
  final String? Function(String?) validator;
  final Widget? suffix;
  final double letterSpacing;
  final bool p2Validation;
  final AutovalidateMode autovalidateMode;
  final Iterable<String> autofillHints;
  final bool obscure;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(99),
      borderSide: BorderSide.none,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: authFont,
            fontSize: 13,
            height: 20 / 13,
            color: Color(0xFF5E3D2E),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          autovalidateMode: autovalidateMode,
          obscureText: obscure,
          autofillHints: autofillHints,
          autocorrect: false,
          enableSuggestions: false,
          textInputAction: onSubmitted == null
              ? TextInputAction.next
              : TextInputAction.done,
          onFieldSubmitted: onSubmitted,
          scrollPadding: const EdgeInsets.all(24),
          style: TextStyle(
            fontFamily: authFont,
            fontSize: 16,
            height: 1.5,
            letterSpacing: letterSpacing,
            color: Color(0xE6493F39),
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontFamily: authFont,
              fontSize: 16,
              height: 1.5,
              letterSpacing: letterSpacing,
              color: Color(0xE6493F39),
              fontWeight: FontWeight.w500,
            ),
            fillColor: P2.rose,
            filled: true,
            isDense: true,
            // A prefix spacer keeps the input inset separate from error text.
            contentPadding: EdgeInsets.fromLTRB(
              p2Validation ? 0 : 24,
              16,
              0,
              16,
            ),
            prefixIcon: p2Validation ? const SizedBox(width: 24) : null,
            prefixIconConstraints: p2Validation
                ? const BoxConstraints.tightFor(width: 24, height: 0)
                : null,
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: suffix,
            ),
            suffixIconConstraints: const BoxConstraints.tightFor(
              width: 56,
              height: 56,
            ),
            border: border,
            enabledBorder: border,
            focusedBorder: border.copyWith(
              borderSide: const BorderSide(color: P2.brown, width: 1.5),
            ),
            errorBorder: border.copyWith(
              borderSide: BorderSide(
                color: p2Validation
                    ? const Color(0xFF94291C)
                    : const Color(0xFFB44735),
                width: p2Validation ? 1 : 1.5,
              ),
            ),
            focusedErrorBorder: border.copyWith(
              borderSide: BorderSide(
                color: p2Validation
                    ? const Color(0xFF94291C)
                    : const Color(0xFFB44735),
                width: p2Validation ? 1 : 1.5,
              ),
            ),
            errorMaxLines: 3,
            errorStyle: p2Validation
                ? const TextStyle(
                    fontFamily: authFont,
                    fontSize: 12,
                    height: 1.5,
                    color: Color(0xFF94291C),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

class AuthButton extends StatelessWidget {
  const AuthButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.color,
    required this.fontSize,
    required this.lineHeight,
    required this.shadows,
    this.leading,
    this.busy = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final double fontSize, lineHeight;
  final List<BoxShadow> shadows;
  final Widget? leading;
  final bool busy;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: busy ? 4 : 0),
    child: DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        boxShadow: busy ? null : shadows,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: authText,
          disabledBackgroundColor: color,
          disabledForegroundColor: const Color(0xFF4D2B1A),
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: Size(44, busy ? 48 : 56),
          padding: EdgeInsets.symmetric(
            horizontal: 24,
            vertical: ((busy ? 48 : 56) - fontSize * lineHeight) / 2,
          ),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: TextStyle(
            fontFamily: authFont,
            fontSize: fontSize,
            height: lineHeight,
            fontWeight: busy ? FontWeight.w500 : FontWeight.w700,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 12)],
            Flexible(child: Text(label, textAlign: TextAlign.center)),
          ],
        ),
      ),
    ),
  );
}
