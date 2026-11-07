import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

class VoucherButton extends StatelessWidget {
  const VoucherButton(
    this.label, {
    super.key,
    this.onPressed,
    this.copy = false,
    this.apply = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool copy, apply;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: onPressed != null,
    child: InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(apply ? 16 : 99),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: onPressed == null
                ? const Color(0xFFD4C9BD)
                : apply
                ? const Color(0xFFE8DDD0)
                : P2.cream,
            borderRadius: BorderRadius.circular(apply ? 16 : 99),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(0, 4),
                blurRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  letterSpacing: 0,
                  fontSize: apply ? 14 : 12,
                  height: apply ? 20 / 14 : 16 / 12,
                  fontWeight: FontWeight.w700,
                  color: onPressed == null
                      ? const Color(0xFF52453B)
                      : apply
                      ? P2.brown
                      : const Color(0xFF9B4B3E),
                ),
              ),
              if (copy) ...[
                const SizedBox(width: 4),
                P2Asset.node(
                  '2026:4081',
                  'imgContainer6',
                  width: 9.917,
                  height: 11.667,
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}
