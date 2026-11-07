import 'package:flutter/material.dart';

import 'package:lenlab_shared/lenlab_shared.dart';
import 'package:lenlab_customer/app/customer_scope.dart';
import 'package:lenlab_customer/app/navigation.dart';

import 'widgets/cart_header.dart';
import 'widgets/cart_item_card.dart';
import 'widgets/cart_voucher.dart';
import 'widgets/cart_summary.dart';
import 'widgets/cart_checkout_button.dart';
import 'widgets/guest_cart_prompt.dart';
import '../../checkout/presentation/widgets/checkout_quote_builder.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    final store = CustomerScope.of(context);
    final showPrompt = !store.signedIn && !store.guestCartPromptDismissed;
    final cart = Scaffold(
      appBar: const CartHeader(),
      bottomNavigationBar: store.cart.isEmpty
          ? null
          : const CartCheckoutButton(),
      body: SafeArea(
        top: false,
        child: store.cart.isEmpty
            ? Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: EmptyPanel(
                    'Giỏ hàng đang trống',
                    description: 'Khám phá các sản phẩm len của LENLAB.',
                    action: P2Button(
                      'Tiếp tục mua sắm',
                      onPressed: () => go(context, '/products'),
                    ),
                  ),
                ),
              )
            : SingleChildScrollView(
                key: const ValueKey('cart-scroll'),
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  children: [
                    for (final line in store.cart)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: CartItemCard(
                          key: ValueKey(line.key),
                          line: line,
                        ),
                      ),
                    const SizedBox(height: 8),
                    const CartVoucher(),
                    const SizedBox(height: 24),
                    if (store.checkoutLines.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Text('Chọn ít nhất một sản phẩm để thanh toán.'),
                      ),
                    if (store.hasUnquotedVoucherSelection)
                      CheckoutQuoteBuilder(
                        builder: (context, quote) => CartSummary(
                          subtotal:
                              quote?.itemsSubtotalVnd ?? store.checkoutSubtotal,
                          discount: quote?.itemsDiscountVnd ?? 0,
                          quote: quote,
                          useQuote: true,
                        ),
                      )
                    else
                      CartSummary(
                        subtotal: store.checkoutSubtotal,
                        discount: store.checkoutDiscount,
                      ),
                  ],
                ),
              ),
      ),
    );
    return PopScope(
      canPop: !showPrompt,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && showPrompt) store.dismissGuestCartPrompt();
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(
            color: Colors.white,
            child: ExcludeSemantics(
              excluding: showPrompt,
              child: IgnorePointer(
                ignoring: showPrompt,
                child: Offstage(
                  offstage: showPrompt,
                  child: ExcludeFocus(excluding: showPrompt, child: cart),
                ),
              ),
            ),
          ),
          if (showPrompt)
            Material(
              type: MaterialType.transparency,
              child: GuestCartPrompt(onDismiss: store.dismissGuestCartPrompt),
            ),
        ],
      ),
    );
  }
}
