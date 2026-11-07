import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

import '../bank_transfer_styles.dart';

class BankTransferDetails extends StatelessWidget {
  const BankTransferDetails({super.key, required this.preview});
  final BankTransferPreview preview;
  @override
  Widget build(BuildContext context) => Container(
    clipBehavior: Clip.antiAlias,
    decoration: bankTransferPanel(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: P2.checkoutButton.withValues(alpha: .05),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Số tiền cần thanh toán',
                style: P2
                    .serif(14, color: bankTransferText, weight: FontWeight.w500)
                    .copyWith(height: 20 / 14),
              ),
              const SizedBox(height: 11),
              Text(
                money(preview.totals.total),
                style: const TextStyle(
                  fontSize: 30,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -.75,
                  color: Color(0xFF7A2929),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${preview.bank} · CHỦ TÀI KHOẢN',
                style: bankTransferLabel(),
              ),
              const SizedBox(height: 4),
              Text(
                preview.holder,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                  color: P2.ink,
                ),
              ),
            ],
          ),
        ),
        _CopyRow(
          label: 'SỐ TÀI KHOẢN',
          value: preview.account,
          tooltip: 'Sao chép số tài khoản',
        ),
        _CopyRow(
          label: 'NỘI DUNG CHUYỂN KHOẢN',
          value: preview.reference,
          tooltip: 'Sao chép nội dung',
        ),
      ],
    ),
  );
}

class _CopyRow extends StatelessWidget {
  const _CopyRow({
    required this.label,
    required this.value,
    required this.tooltip,
  });
  final String label, value, tooltip;
  Future<void> copy(BuildContext context) async {
    try {
      await Clipboard.setData(ClipboardData(text: value));
      if (context.mounted) toast(context, 'Đã sao chép dữ liệu minh họa.');
    } catch (_) {
      if (context.mounted) {
        toast(context, 'Không thể sao chép. Vui lòng thử lại.');
      }
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      border: Border(
        top: BorderSide(color: Colors.white.withValues(alpha: .05)),
      ),
    ),
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: bankTransferLabel()),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'packages/lenlab_shared/Cousine',
                  fontSize: 16,
                  height: 1.5,
                  letterSpacing: .4,
                  fontWeight: FontWeight.w700,
                  color: P2.ink,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: P2.cream.withValues(alpha: .9),
                  shape: BoxShape.circle,
                ),
              ),
              Positioned.fill(
                child: IconButton(
                  tooltip: tooltip,
                  padding: EdgeInsets.zero,
                  onPressed: () => copy(context),
                  icon: P2Asset.node(
                    bankTransferNode,
                    'imgContainer2',
                    width: 14.167,
                    height: 16.667,
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
