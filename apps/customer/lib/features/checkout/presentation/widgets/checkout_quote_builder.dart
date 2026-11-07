import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

import '../../../../app/customer_scope.dart';
import '../../data/mock_checkout_quote_source.dart';

/// Both screens read the same Store-owned quote/Future, not local calculations.
class CheckoutQuoteBuilder extends StatefulWidget {
  const CheckoutQuoteBuilder({super.key, required this.builder});
  final Widget Function(BuildContext, CheckoutQuote?) builder;
  @override
  State<CheckoutQuoteBuilder> createState() => _CheckoutQuoteBuilderState();
}

class _CheckoutQuoteBuilderState extends State<CheckoutQuoteBuilder> {
  String? lastKey;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final store = CustomerScope.of(context);
    final key = store.checkoutQuoteKey;
    if (lastKey != key) {
      lastKey = key;
      Future.microtask(() {
        if (mounted && store.checkoutQuoteKey == key) {
          store.requestCheckoutQuote(source: MockCheckoutQuoteSource(store));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, CustomerScope.of(context).checkoutQuote);
}

class CheckoutQuoteStatusPanel extends StatelessWidget {
  const CheckoutQuoteStatusPanel({super.key, required this.quote});
  final CheckoutQuote? quote;
  @override
  Widget build(BuildContext context) {
    if (quote == null || quote!.status == CheckoutQuoteStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(semanticsLabel: 'Đang tính tổng tiền'),
      );
    }
    return EmptyPanel(
      quote!.status == CheckoutQuoteStatus.needsContext
          ? 'Chưa đủ thông tin tính tổng tiền'
          : 'Cần kiểm tra lại tổng tiền',
      description: switch (quote!.reason) {
        'SHIPPING_CONTEXT_REQUIRED' =>
          'Cần phí vận chuyển cho địa chỉ nhận hàng.',
        'EMPTY_SELECTION' => 'Vui lòng chọn sản phẩm trong giỏ.',
        'CONFIG_INCOMPLETE' => 'Ưu đãi chưa có đủ cấu hình tính tiền.',
        'MINIMUM_NOT_MET' => 'Sản phẩm đã chọn chưa đạt giá trị tối thiểu.',
        'LEGACY_COUPON_CONFLICT' => 'Không thể cộng dồn hai mã giảm giá.',
        'QUOTE_EXPIRED' => 'Thông tin tính tiền đã hết hạn. Vui lòng tải lại.',
        'CONTEXT_CHANGED' ||
        'PRICE_CHANGED' => 'Giỏ hàng đã thay đổi. Vui lòng kiểm tra lại.',
        _ => 'Chưa thể tính tổng tiền. Vui lòng kiểm tra lựa chọn và thử lại.',
      },
      action: P2Button(
        'Thử lại',
        onPressed: () =>
            CustomerScope.of(context).requestCheckoutQuote(force: true),
      ),
    );
  }
}
