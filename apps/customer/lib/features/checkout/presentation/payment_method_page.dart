import '../../../app/customer_session_gate.dart';

import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';
import 'package:lenlab_customer/app/customer_scope.dart';
import 'package:lenlab_customer/app/navigation.dart';

import 'widgets/checkout_header.dart';
import 'widgets/payment_method_footer.dart';
import 'widgets/payment_method_notice.dart';
import 'widgets/payment_method_option.dart';

class PaymentMethodPage extends StatelessWidget {
  const PaymentMethodPage({super.key, this.source, this.codSource});
  final OrderReviewSource? source;
  final CodOrderSource? codSource;
  @override
  Widget build(BuildContext context) => CustomerSessionGate(
    route: '/payment-method',
    builder: (_) =>
        _PaymentMethodPageContent(source: source, codSource: codSource),
  );
}

class _PaymentMethodPageContent extends StatefulWidget {
  const _PaymentMethodPageContent({this.source, this.codSource});
  final OrderReviewSource? source;
  final CodOrderSource? codSource;
  @override
  State<_PaymentMethodPageContent> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<_PaymentMethodPageContent> {
  OrderReviewSource? source;
  Future<OrderReviewTotals>? request;
  String? requestKey;
  bool submitting = false;
  String? submissionError;
  bool requiresReview = false;

  Future<void> submitCod(OrderReviewTotals totals) async {
    if (submitting || requiresReview) return;
    final store = CustomerScope.of(context);
    final actor = store.captureSession();
    setState(() {
      submitting = true;
      submissionError = null;
    });
    try {
      final order = await store.submitCodOrder(
        totals: totals,
        source: widget.codSource,
      );
      if (!mounted || !store.isCurrentSession(actor)) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/cod-confirmation',
        (route) => route.settings.name == '/',
        arguments: order,
      );
    } catch (error) {
      if (!mounted || !store.isCurrentSession(actor)) return;
      setState(() {
        submitting = false;
        submissionError = error is RepositoryException
            ? error.message
            : 'Không thể đặt đơn. Vui lòng thử lại.';
        requiresReview =
            error is CodValidationException && error.requiresReview;
      });
    }
  }

  Future<void> reviewUpdatedInformation() async {
    if (submitting) return;
    final store = CustomerScope.of(context);
    final actor = store.captureSession();
    setState(() => submitting = true);
    try {
      await store.refreshCodCheckout();
      if (!mounted || !store.isCurrentSession(actor)) return;
      final navigator = Navigator.of(context);
      var foundReview = false;
      navigator.popUntil((route) {
        foundReview = route.settings.name == '/order-review';
        return foundReview || route.isFirst;
      });
      if (!foundReview) navigator.pushNamed('/order-review');
    } catch (error) {
      if (!mounted || !store.isCurrentSession(actor)) return;
      setState(() {
        submitting = false;
        submissionError = error is RepositoryException
            ? error.message
            : 'Không thể cập nhật thông tin. Vui lòng thử lại.';
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final store = CustomerScope.of(context);
    source ??= widget.source ?? MockOrderReviewSource(store.repository);
    final address = store.deliveryAddress;
    if (address == null || store.checkoutLines.isEmpty) return;
    final key =
        '${store.checkoutLines.map((l) => '${l.key}:${l.quantity}:${l.product.price}').join(';')}|${store.checkoutDiscount}|${address.full}|${address.name}|${address.phone}';
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
    );
  }

  void chooseBank() {
    final store = CustomerScope.of(context);
    final actor = store.captureSession();
    // P2 makes the bank option a link into its separate transfer screen.
    store.checkoutPaymentMethod = CheckoutPaymentMethod.bankTransfer;
    Navigator.pushNamed<void>(context, '/bank-transfer').then((_) {
      if (!mounted || !store.isCurrentSession(actor)) return;
      setState(() {
        store.checkoutPaymentMethod = CheckoutPaymentMethod.cod;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = CustomerScope.of(context);
    final ready =
        store.checkoutLines.isNotEmpty && store.deliveryAddress != null;
    return PopScope(
      canPop: !submitting,
      child: IgnorePointer(
        ignoring: submitting,
        child: Scaffold(
          appBar: CheckoutHeader(
            title: 'Phương thức thanh toán',
            activeStep: 2,
            overlayProgress: true,
            overlayHeight: MediaQuery.textScalerOf(context).scale(18) > 18
                ? 87 + MediaQuery.textScalerOf(context).scale(28)
                : 87,
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
                : FutureBuilder<OrderReviewTotals>(
                    future: request,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return Center(
                          child: Semantics(
                            label: 'Đang tải phương thức thanh toán',
                            liveRegion: true,
                            child: const CircularProgressIndicator(),
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return Padding(
                          padding: const EdgeInsets.all(24),
                          child: EmptyPanel(
                            'Không thể tải thông tin thanh toán',
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
                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 15, 16, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'CHỌN PHƯƠNG THỨC',
                              style: P2
                                  .serif(14, weight: FontWeight.w500)
                                  .copyWith(height: 20 / 14, letterSpacing: .7),
                            ),
                            const SizedBox(height: 16),
                            PaymentMethodOption(
                              title: 'Thanh toán khi nhận hàng',
                              subtitle: 'Thanh toán tiền mặt (COD)',
                              asset: 'imgContainer1',
                              selected: true,
                              onSelected: () {
                                store.checkoutPaymentMethod =
                                    CheckoutPaymentMethod.cod;
                              },
                            ),
                            const SizedBox(height: 12),
                            PaymentMethodOption(
                              title: 'Chuyển khoản ngân hàng',
                              subtitle: 'Hỗ trợ quét mã QR VietQR',
                              asset: 'imgContainer3',
                              selected: false,
                              onSelected: chooseBank,
                            ),
                            const SizedBox(height: 24),
                            const PaymentMethodNotice(),
                            if (submissionError != null) ...[
                              const SizedBox(height: 16),
                              Semantics(
                                liveRegion: true,
                                child: Text(
                                  submissionError!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFF7A2929),
                                  ),
                                ),
                              ),
                              TextButton(
                                key: ValueKey(
                                  requiresReview
                                      ? 'cod-review-updated'
                                      : 'cod-retry',
                                ),
                                onPressed: requiresReview
                                    ? reviewUpdatedInformation
                                    : () => submitCod(snapshot.data!),
                                child: Text(
                                  requiresReview
                                      ? 'Cập nhật thông tin và xem lại tổng tiền'
                                      : 'Thử đặt lại',
                                ),
                              ),
                              TextButton(
                                key: const ValueKey('cod-edit-cart'),
                                onPressed: () => go(context, '/cart'),
                                child: const Text('Xem lại giỏ hàng'),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
          ),
          bottomNavigationBar: !ready
              ? null
              : FutureBuilder<OrderReviewTotals>(
                  future: request,
                  builder: (context, snapshot) => PaymentMethodFooter(
                    busy: submitting,
                    total:
                        snapshot.hasError ||
                            snapshot.connectionState != ConnectionState.done
                        ? null
                        : snapshot.data?.total,
                    onContinue:
                        !submitting &&
                            !requiresReview &&
                            snapshot.hasData &&
                            !snapshot.hasError &&
                            snapshot.connectionState == ConnectionState.done
                        ? () => submitCod(snapshot.data!)
                        : null,
                  ),
                ),
        ),
      ),
    );
  }
}
