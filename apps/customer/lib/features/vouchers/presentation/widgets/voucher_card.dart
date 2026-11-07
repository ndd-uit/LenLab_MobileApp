import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

import '../../data/voucher_source.dart';
import 'voucher_button.dart';
import 'voucher_card_layout.dart';

class VoucherCard extends StatelessWidget {
  const VoucherCard({
    super.key,
    required this.voucher,
    required this.onUse,
    required this.onCopy,
    required this.layout,
  });
  final WalletVoucher voucher;
  final VoidCallback onUse, onCopy;
  final VoucherCardLayout layout;
  @override
  Widget build(BuildContext context) {
    final inactive = voucher.status != WalletVoucherStatus.available;
    final (asset, width, height) = switch (voucher.kind) {
      WalletVoucherKind.discount => ('imgContainer2', 20.0, 16.0),
      WalletVoucherKind.shipping => ('imgContainer3', 22.0, 16.0),
      WalletVoucherKind.firstOrder => ('imgContainer4', 16.0, 16.0),
      WalletVoucherKind.cash => ('imgContainer5', 22.0, 16.0),
      WalletVoucherKind.gift => ('imgContainer7', 20.0, 19.0),
    };
    final copy = voucher.kind == WalletVoucherKind.cash;
    final action = switch (voucher.status) {
      WalletVoucherStatus.expired => 'Hết hạn',
      WalletVoucherStatus.used => 'Đã dùng',
      WalletVoucherStatus.available => copy ? 'Sao chép' : 'Dùng ngay',
    };
    return Opacity(
      opacity: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final stub = constraints.maxWidth * .3;
            return Stack(
              children: [
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: stub,
                        padding: const EdgeInsets.all(8),
                        color: Color.alphaBlend(
                          const Color(0x5E7C2D12),
                          P2.rose,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: P2.rose,
                              ),
                              child: P2Asset.node(
                                '2026:4081',
                                asset,
                                width: width,
                                height: height,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              voucher.label,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                height: 16 / 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF332620),
                                letterSpacing: .3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          color: P2.rose,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(
                                height: layout.titleHeight,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        voucher.title,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          height: 1.25,
                                          fontWeight: FontWeight.w700,
                                          color: P2.ink,
                                        ),
                                      ),
                                    ),
                                    if (voucher.isNew)
                                      Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: P2.checkoutButton.withValues(
                                            alpha: .1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Text(
                                          'Mới',
                                          style: TextStyle(
                                            fontSize: 10,
                                            height: 1.5,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF523A30),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              SizedBox(
                                height: layout.descriptionHeight,
                                child: Text(
                                  voucher.description,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    height: 16 / 12,
                                    color: P2.ink,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                crossAxisAlignment: WrapCrossAlignment.end,
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'HSD',
                                        style: TextStyle(
                                          fontSize: 10,
                                          height: 1.5,
                                          fontWeight: FontWeight.w700,
                                          color: P2.ink,
                                        ),
                                      ),
                                      Text(
                                        voucher.expiry,
                                        style: TextStyle(
                                          fontSize: 12,
                                          height: 16 / 12,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF523A30),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (layout.stackFooter)
                                    const SizedBox(width: double.infinity),
                                  SizedBox(
                                    width: layout.buttonWidth,
                                    child: VoucherButton(
                                      action,
                                      copy: copy,
                                      onPressed: inactive
                                          ? null
                                          : copy
                                          ? onCopy
                                          : onUse,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: stub - 1,
                  top: 0,
                  bottom: 0,
                  width: 2,
                  child: const CustomPaint(painter: _TicketSeam()),
                ),
                for (final top in [true, false])
                  Positioned(
                    left: stub - 10,
                    top: top ? -10 : null,
                    bottom: top ? null : -10,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TicketSeam extends CustomPainter {
  const _TicketSeam();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = P2.cream.withValues(alpha: .5)
      ..strokeWidth = 2;
    for (double y = 0; y < size.height; y += 8) {
      canvas.drawLine(
        Offset(1, y),
        Offset(1, (y + 4).clamp(0, size.height)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_TicketSeam oldDelegate) => false;
}
