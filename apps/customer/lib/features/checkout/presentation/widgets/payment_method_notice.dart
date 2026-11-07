import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

class PaymentMethodNotice extends StatelessWidget {
  const PaymentMethodNotice({super.key});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Opacity(
        opacity: .8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            P2Asset.node('2026:1627', 'imgContainer5', width: 11, height: 14),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Thông tin thanh toán được bảo mật tuyệt đối.',
                style: P2.serif(12).copyWith(height: 16 / 12),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      Opacity(
        opacity: .9,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Bằng cách hoàn tất thanh toán, bạn đã đồng ý với các điều khoản và chính sách mua hàng của chúng tôi',
            textAlign: TextAlign.center,
            style: P2.serif(12).copyWith(height: 1.25),
          ),
        ),
      ),
    ],
  );
}
