import '../../../app/customer_session_gate.dart';

import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';
import 'package:lenlab_customer/app/customer_scope.dart';
import 'package:lenlab_customer/app/navigation.dart';

import 'widgets/checkout_header.dart';
import 'widgets/order_review_address.dart';
import 'widgets/order_review_products.dart';
import 'widgets/order_review_notes.dart';
import 'widgets/order_review_totals.dart';
import 'widgets/order_review_section.dart';
import 'widgets/checkout_quote_builder.dart';

class OrderReviewPage extends StatelessWidget {
  const OrderReviewPage({super.key, this.address, this.source});
  final Address? address;
  final OrderReviewSource? source;
  @override
  Widget build(BuildContext context) => CustomerSessionGate(
    route: '/order-review',
    builder: (_) => _OrderReviewPageContent(address: address, source: source),
  );
}

class _OrderReviewPageContent extends StatefulWidget {
  const _OrderReviewPageContent({this.address, this.source});
  final Address? address;
  final OrderReviewSource? source;
  @override
  State<_OrderReviewPageContent> createState() => _OrderReviewPageState();
}

class _OrderReviewPageState extends State<_OrderReviewPageContent> {
  final note = TextEditingController();
  OrderReviewSource? source;
  Future<OrderReviewTotals>? request;
  String? requestKey;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final store = CustomerScope.of(context);
    if (source == null) {
      source = widget.source ?? MockOrderReviewSource(store.repository);
      note.text = store.checkoutNote;
    }
    if (store.hasUnquotedVoucherSelection) return;
    final address =
        store.deliveryAddress ??
        (widget.address?.ownerId == store.userId ? widget.address : null);
    if (store.checkoutLines.isEmpty || address == null) return;
    final key =
        '${store.checkoutLines.map((l) => '${l.key}:${l.quantity}:${l.product.price}').join(';')}|${store.checkoutDiscount}|${address.full}|${address.name}|${address.phone}';
    if (key != requestKey) {
      requestKey = key;
      request = source!.preview(
        subtotal: store.checkoutSubtotal,
        discount: store.checkoutDiscount,
        address: address,
      );
    }
  }

  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  void retry() {
    final store = CustomerScope.of(context);
    if (store.hasUnquotedVoucherSelection) {
      store.requestCheckoutQuote(force: true);
      return;
    }
    final address =
        store.deliveryAddress ??
        (widget.address?.ownerId == store.userId ? widget.address : null);
    if (address == null || store.checkoutLines.isEmpty) return;
    setState(() {
      request = source!.preview(
        subtotal: store.checkoutSubtotal,
        discount: store.checkoutDiscount,
        address: address,
      );
    });
  }

  void editAddress() => go(context, '/checkout', 'edit-address');
  @override
  Widget build(BuildContext context) {
    final store = CustomerScope.of(context);
    final address =
        store.deliveryAddress ??
        (widget.address?.ownerId == store.userId ? widget.address : null);
    final ready = store.checkoutLines.isNotEmpty && address != null;
    return Scaffold(
      appBar: const CheckoutHeader(title: 'Tổng quan đơn hàng', activeStep: 1),
      body: SafeArea(
        top: false,
        child: !ready
            ? Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: store.checkoutLines.isEmpty
                      ? EmptyPanel(
                          store.cart.isEmpty
                              ? 'Giỏ hàng đang trống'
                              : 'Chưa chọn sản phẩm thanh toán',
                          action: P2Button(
                            store.cart.isEmpty
                                ? 'Tiếp tục mua sắm'
                                : 'Chọn sản phẩm',
                            onPressed: () => go(
                              context,
                              store.cart.isEmpty ? '/products' : '/cart',
                            ),
                          ),
                        )
                      : EmptyPanel(
                          'Chưa có địa chỉ nhận hàng',
                          action: P2Button(
                            'Chọn địa chỉ',
                            onPressed: editAddress,
                          ),
                        ),
                ),
              )
            : store.hasUnquotedVoucherSelection
            ? CheckoutQuoteBuilder(
                builder: (context, quote) =>
                    quote?.status == CheckoutQuoteStatus.ready &&
                        quote!.grandTotalVnd != null
                    ? reviewContent(
                        store,
                        address,
                        quote.reviewTotals,
                        quote: quote,
                      )
                    : Padding(
                        padding: const EdgeInsets.all(24),
                        child: CheckoutQuoteStatusPanel(quote: quote),
                      ),
              )
            : FutureBuilder<OrderReviewTotals>(
                future: request,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const _OrderReviewLoading();
                  }
                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: EmptyPanel(
                        'Không thể tải tổng quan đơn hàng',
                        description: 'Vui lòng thử lại.',
                        action: P2Button('Thử lại', onPressed: retry),
                      ),
                    );
                  }
                  return reviewContent(store, address, snapshot.data!);
                },
              ),
      ),
      bottomNavigationBar: !ready
          ? null
          : FutureBuilder<OrderReviewTotals>(
              future: request,
              builder: (context, snapshot) => Material(
                color: P2.rose,
                child: SafeArea(
                  top: false,
                  minimum: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed:
                        snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData &&
                            !store.hasUnquotedVoucherSelection &&
                            !snapshot.hasError
                        ? () {
                            FocusScope.of(context).unfocus();
                            go(context, '/payment-method');
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: P2.checkoutButton,
                      foregroundColor: const Color(0xFF523A30),
                      minimumSize: const Size(double.infinity, 56),
                      textStyle: const TextStyle(
                        fontFamily: 'packages/lenlab_shared/BeVietnamPro',
                        fontSize: 16,
                        height: 1.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: const Text('Chọn thanh toán'),
                  ),
                ),
              ),
            ),
    );
  }

  Widget reviewContent(
    LenlabStore store,
    Address address,
    OrderReviewTotals totals, {
    CheckoutQuote? quote,
  }) => SingleChildScrollView(
    key: const ValueKey('order-review-scroll'),
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        OrderReviewAddress(address: address, onEdit: editAddress),
        const SizedBox(height: 16),
        OrderReviewProducts(lines: store.checkoutLines),
        const SizedBox(height: 16),
        OrderReviewNotes(
          controller: note,
          onChanged: (value) => store.checkoutNote = value,
        ),
        const SizedBox(height: 16),
        OrderReviewPaymentDetails(totals: totals, quote: quote),
      ],
    ),
  );
}

class _OrderReviewLoading extends StatelessWidget {
  const _OrderReviewLoading();
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Đang tải tổng quan đơn hàng',
    liveRegion: true,
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const LinearProgressIndicator(),
          const SizedBox(height: 16),
          for (final height in [144.0, 260.0, 174.0, 200.0])
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: OrderReviewSection(
                child: SizedBox(height: height - 36, width: double.infinity),
              ),
            ),
        ],
      ),
    ),
  );
}
