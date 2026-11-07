import '../../../../app/customer_scope.dart';
import '../../../../app/session_bound_overlay.dart';

import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

class FaqSupportCard extends StatelessWidget {
  const FaqSupportCard({super.key, this.orderId});
  final String? orderId;
  @override
  Widget build(BuildContext context) {
    final session = CustomerScope.of(context).captureSession();
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: .1)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [P2.rose.withValues(alpha: .5), P2.rose],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Bạn vẫn cần giúp đỡ?',
            style: TextStyle(
              fontSize: 18,
              height: 28 / 18,
              fontWeight: FontWeight.w700,
              color: P2.ink,
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 240),
              child: Text(
                'Đội ngũ hỗ trợ của chúng tôi luôn sẵn sàng giải đáp thắc mắc của bạn 24/7.',
                style: TextStyle(fontSize: 14, height: 20 / 14, color: P2.ink),
              ),
            ),
          ),
          if (orderId != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'Đơn hàng: #$orderId',
                style: const TextStyle(fontSize: 14, color: P2.ink),
              ),
            ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (dialog) => SessionBoundOverlay(
                session: session,
                builder: (dialog) => AlertDialog(
                  title: const Text('Liên hệ hỗ trợ'),
                  content: Text(
                    '${orderId == null ? '' : 'Đơn hàng: #$orderId\n\n'}Bản dùng thử chưa kết nối hỗ trợ trực tiếp. Nội dung FAQ và thông tin 24/7 là minh họa theo thiết kế; chưa có yêu cầu nào được gửi.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialog),
                      child: const Text('Đóng'),
                    ),
                  ],
                ),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: P2.authButton,
              foregroundColor: const Color(0xFF523A30),
              minimumSize: const Size.fromHeight(48),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 4,
              shadowColor: Colors.black26,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                P2Asset.node(
                  '2026:2669',
                  'imgContainer4',
                  width: 16.667,
                  height: 15,
                ),
                const SizedBox(width: 8),
                const Flexible(
                  child: Text(
                    'Liên hệ hỗ trợ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
