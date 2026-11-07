import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

import '../bank_transfer_styles.dart';

class BankTransferQr extends StatelessWidget {
  const BankTransferQr({super.key});
  @override
  Widget build(BuildContext context) => Container(
    decoration: bankTransferPanel(),
    padding: const EdgeInsets.fromLTRB(16, 21, 16, 17),
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: P2.brown,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: P2.checkoutButton.withValues(alpha: .2),
              width: 2,
            ),
          ),
          child: Semantics(
            label: 'QR minh họa, không dùng giao dịch',
            image: true,
            child: ExcludeSemantics(
              child: P2Asset.node(
                bankTransferNode,
                'imgQrMinhHaKhongDungGiaoDch',
                width: 192,
                height: 192,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Quét mã để thanh toán',
          textAlign: TextAlign.center,
          style: P2
              .serif(18, color: P2.ink, weight: FontWeight.w700)
              .copyWith(height: 28 / 18),
        ),
        const SizedBox(height: 4),
        Text(
          'Sử dụng ứng dụng ngân hàng của bạn',
          textAlign: TextAlign.center,
          style: P2
              .serif(14, color: bankTransferText)
              .copyWith(height: 20 / 14),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 44,
          child: Center(
            child: TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('QR minh họa'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      P2Asset.node(
                        bankTransferNode,
                        'imgQrMinhHaKhongDungGiaoDch',
                        width: 192,
                        height: 192,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Không dùng giao dịch. Lưu ảnh vào thiết bị sẽ được bổ sung ở phần tiếp theo.',
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Đóng'),
                    ),
                  ],
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: P2.cream.withValues(alpha: .9),
                foregroundColor: P2.brown,
                minimumSize: const Size(128, 36),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                tapTargetSize: MaterialTapTargetSize.padded,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontFamily: 'packages/lenlab_shared/BeVietnamPro',
                  fontSize: 14,
                  height: 20 / 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  P2Asset.node(
                    bankTransferNode,
                    'imgContainer1',
                    width: 12,
                    height: 12,
                  ),
                  const SizedBox(width: 8),
                  const Text('Lưu mã QR'),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
