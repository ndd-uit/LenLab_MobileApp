import '../../../app/customer_session_gate.dart';

import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';
import 'package:lenlab_customer/app/customer_scope.dart';
import 'package:lenlab_customer/app/navigation.dart';

import 'bank_transfer_styles.dart';
import 'widgets/bank_transfer_header.dart';
import 'widgets/bank_transfer_qr.dart';
import 'widgets/bank_transfer_details.dart';

/// Retained P2 demonstration only. Gateway checkout will use a separate adapter
/// after the provider and backend contract are agreed; manual proof UI is removed.
class BankTransferPage extends StatelessWidget {
  const BankTransferPage({super.key, this.source});
  final BankTransferSource? source;
  @override
  Widget build(BuildContext context) => CustomerSessionGate(
    route: '/bank-transfer',
    builder: (_) => _BankTransferPageContent(source: source),
  );
}

class _BankTransferPageContent extends StatefulWidget {
  const _BankTransferPageContent({this.source});
  final BankTransferSource? source;
  @override
  State<_BankTransferPageContent> createState() => _BankTransferPageState();
}

class _BankTransferPageState extends State<_BankTransferPageContent> {
  BankTransferSource? source;
  Future<BankTransferPreview>? request;
  String? requestKey;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final store = CustomerScope.of(context);
    source ??= widget.source ?? MockBankTransferSource(store.repository);
    if (store.deliveryAddress == null || store.checkoutLines.isEmpty) return;
    store.checkoutPaymentMethod = CheckoutPaymentMethod.bankTransfer;
    store.bankTransferReference ??= 'WOOL${9000 + store.orders.length}';
    final address = store.deliveryAddress!;
    final key =
        '${store.checkoutLines.map((l) => '${l.key}:${l.quantity}:${l.product.price}').join(';')}|${store.checkoutDiscount}|${address.full}|${address.name}|${address.phone}|${store.bankTransferReference}';
    if (key != requestKey) {
      requestKey = key;
      load();
    }
  }

  void load() {
    final store = CustomerScope.of(context);
    request = source!.preview(
      subtotal: store.checkoutSubtotal,
      discount: store.checkoutDiscount,
      address: store.deliveryAddress!,
      reference: store.bankTransferReference!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = CustomerScope.of(context);
    final ready =
        store.checkoutLines.isNotEmpty && store.deliveryAddress != null;
    return Scaffold(
      appBar: BankTransferHeader(
        height: MediaQuery.textScalerOf(context).scale(18) > 18 ? 88 : 64,
      ),
      body: SafeArea(
        top: false,
        child: !ready
            ? Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: EmptyPanel(
                    store.checkoutLines.isEmpty
                        ? store.cart.isEmpty
                              ? 'Giỏ hàng đang trống'
                              : 'Chưa chọn sản phẩm thanh toán'
                        : 'Chưa có địa chỉ nhận hàng',
                    action: P2Button(
                      store.checkoutLines.isEmpty
                          ? store.cart.isEmpty
                                ? 'Tiếp tục mua sắm'
                                : 'Chọn sản phẩm'
                          : 'Chọn địa chỉ',
                      onPressed: () => go(
                        context,
                        store.checkoutLines.isEmpty
                            ? (store.cart.isEmpty ? '/products' : '/cart')
                            : '/checkout',
                      ),
                    ),
                  ),
                ),
              )
            : FutureBuilder<BankTransferPreview>(
                future: request,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return Center(
                      child: Semantics(
                        label: 'Đang tải thông tin chuyển khoản',
                        liveRegion: true,
                        child: const CircularProgressIndicator(),
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: EmptyPanel(
                        'Không thể tải thông tin chuyển khoản',
                        description: 'Vui lòng thử lại.',
                        action: P2Button(
                          'Thử lại',
                          onPressed: () {
                            setState(load);
                          },
                        ),
                      ),
                    );
                  }
                  final preview = snapshot.data!;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    child: Column(
                      key: const ValueKey('bank-transfer-content'),
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const BankTransferQr(),
                        const SizedBox(height: 24),
                        BankTransferDetails(preview: preview),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              P2Asset.node(
                                bankTransferNode,
                                'imgContainer3',
                                width: 16.667,
                                height: 17,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Nội dung chuyển khoản: ${preview.reference}.\nQR minh họa — không dùng giao dịch.',
                                  style: P2
                                      .serif(12)
                                      .copyWith(height: 19.5 / 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
