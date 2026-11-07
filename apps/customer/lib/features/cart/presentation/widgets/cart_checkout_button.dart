import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';
import 'package:lenlab_customer/app/navigation.dart';
import 'package:lenlab_customer/app/customer_scope.dart';
import 'package:lenlab_customer/app/auth_return_intent.dart';

import '../cart_styles.dart';

class CartCheckoutButton extends StatelessWidget {
  const CartCheckoutButton({super.key});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [P2.rose.withValues(alpha: 0), P2.rose, P2.rose],
        stops: const [0, .5, 1],
      ),
    ),
    child: SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      child: SizedBox(
        height: 56,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: -15,
              right: -15,
              top: -5,
              bottom: -25,
              child: IgnorePointer(
                child: P2Asset.node(
                  cartNode,
                  'imgButtonShadow',
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Positioned.fill(
              child: ElevatedButton(
                onPressed:
                    CustomerScope.of(context).checkoutLines.isEmpty ||
                        CustomerScope.of(context).isSubmittingCod
                    ? null
                    : () {
                        final store = CustomerScope.of(context);
                        // V04a permits collecting address/review context, but
                        // payment/Store COD with the new voucher stays blocked.
                        if (store.signedIn &&
                            !store.hasUnquotedVoucherSelection) {
                          try {
                            store.requireVoucherCheckoutReady();
                          } on RepositoryException catch (error) {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            toast(context, error.toString());
                            return;
                          }
                        }
                        go(
                          context,
                          store.signedIn ? '/checkout' : '/login',
                          store.signedIn
                              ? null
                              : AuthReturnIntent.forRoute(store, '/checkout'),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: P2.checkoutButton,
                  foregroundColor: const Color(0xFF523A30),
                  elevation: 0,
                  side: BorderSide.none,
                  shape: const StadiumBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Flexible(
                      child: Text(
                        'Thanh toán',
                        style: TextStyle(
                          fontSize: 18,
                          height: 28 / 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    cartAsset('imgContainer7', 16, 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
