import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

class PaymentMethodFooter extends StatelessWidget {
  const PaymentMethodFooter({
    super.key,
    required this.total,
    required this.onContinue,
    this.busy = false,
  });
  final int? total;
  final VoidCallback? onContinue;
  final bool busy;

  @override
  Widget build(BuildContext context) => Material(
    color: P2.rose,
    child: SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(16, 17, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Tổng thanh toán',
                  style: P2
                      .serif(16, color: P2.ink, weight: FontWeight.w500)
                      .copyWith(height: 1.5),
                ),
              ),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(context).width * .6,
                ),
                child: Text(
                  total == null ? '—' : money(total!),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 20,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF7A2929),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: P2.checkoutButton,
              foregroundColor: const Color(0xFF523A30),
              minimumSize: const Size(double.infinity, 52),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              textStyle: const TextStyle(
                fontFamily: 'packages/lenlab_shared/BeVietnamPro',
                fontSize: 16,
                height: 1.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (busy) ...[
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF523A30),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    busy ? 'Đang đặt đơn…' : 'Đặt hàng COD',
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 8),
                P2Asset.node(
                  '2026:1627',
                  'imgContainer6',
                  width: 14,
                  height: 14,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
