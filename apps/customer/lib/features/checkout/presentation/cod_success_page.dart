import '../../../app/customer_session_gate.dart';

import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';
import 'package:lenlab_customer/app/customer_scope.dart';
import 'package:lenlab_customer/app/navigation.dart';

import 'widgets/cod_order_receipt.dart';
import 'widgets/cod_success_illustration.dart';

class CodSuccessPage extends StatelessWidget {
  const CodSuccessPage({super.key, this.order});
  final Order? order;
  @override
  Widget build(BuildContext context) => CustomerSessionGate(
    route: '/cod-confirmation',
    builder: (_) => _CodSuccessPageContent(order: order),
  );
}

class _CodSuccessPageContent extends StatelessWidget {
  const _CodSuccessPageContent({this.order});
  final Order? order;
  @override
  Widget build(BuildContext context) {
    final store = CustomerScope.of(context);
    final receipt = order;
    final valid =
        receipt != null &&
        receipt.payment == PaymentState.cod &&
        store.ownsOrder(receipt);
    return Scaffold(
      body: SafeArea(
        child: !valid
            ? Center(
                child: EmptyPanel(
                  'Chưa có đơn COD để hiển thị',
                  action: P2Button(
                    'Về trang chủ',
                    onPressed: () => home(context),
                  ),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 25, 16, 16),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          for (int i = 0; i < 3; i++) ...[
                            Expanded(
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: i == 2 ? P2.brown : Colors.white,
                                  borderRadius: BorderRadius.circular(99),
                                ),
                              ),
                            ),
                            if (i < 2) const SizedBox(width: 8),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    const CodSuccessIllustration(),
                    Text(
                      'Đặt hàng thành công!',
                      textAlign: TextAlign.center,
                      style: P2
                          .serif(30, weight: FontWeight.w700)
                          .copyWith(height: 1.2, letterSpacing: -.75),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Đơn hàng đã được gửi đến LENLAB.\nBạn sẽ thanh toán khi nhận hàng.\nShop sẽ sớm xác nhận đơn của bạn.',
                      textAlign: TextAlign.center,
                      style: P2
                          .serif(16, color: P2.ink)
                          .copyWith(height: 26 / 16),
                    ),
                    const SizedBox(height: 32),
                    CodOrderReceipt(order: receipt),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: P2.checkoutButton.withValues(
                                    alpha: .2,
                                  ),
                                  offset: const Offset(0, 10),
                                  blurRadius: 15,
                                  spreadRadius: -3,
                                ),
                                BoxShadow(
                                  color: P2.checkoutButton.withValues(
                                    alpha: .2,
                                  ),
                                  offset: const Offset(0, 4),
                                  blurRadius: 6,
                                  spreadRadius: -4,
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () => home(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: P2.checkoutButton,
                                foregroundColor: const Color(0xFF523A30),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                textStyle: const TextStyle(
                                  fontFamily:
                                      'packages/lenlab_shared/BeVietnamPro',
                                  fontSize: 16,
                                  height: 1.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Flexible(
                                    child: Text(
                                      'Tiếp tục mua sắm',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  P2Asset.node(
                                    '2026:1691',
                                    'imgContainer2',
                                    width: 12.023,
                                    height: 12.023,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: () =>
                                go(context, '/order-detail', receipt.id),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: P2.brown,
                              side: const BorderSide(color: Color(0xFF374151)),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              textStyle: const TextStyle(
                                fontFamily:
                                    'packages/lenlab_shared/BeVietnamPro',
                                fontSize: 16,
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            child: const Text(
                              'Xem chi tiết đơn hàng',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () => go(context, '/support', receipt.id),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF523A30),
                        textStyle: const TextStyle(
                          fontFamily: 'packages/lenlab_shared/BeVietnamPro',
                          fontSize: 12,
                          height: 16 / 12,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          P2Asset.node(
                            '2026:1691',
                            'imgContainer3',
                            width: 11.648,
                            height: 11.648,
                          ),
                          const SizedBox(width: 4),
                          const Flexible(
                            child: Text(
                              'Cần hỗ trợ về đơn hàng này?',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
