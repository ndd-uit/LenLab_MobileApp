import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

import 'customer_scope.dart';
import 'auth_return_intent.dart';
import 'customer_session_gate.dart';
import '../features/auth/presentation/auth_page.dart';
import '../features/home/presentation/home_page.dart';
import '../features/catalog/presentation/catalog_page.dart';
import '../features/products/presentation/product_detail_route.dart';
import '../features/products/presentation/product_unavailable_page.dart';
import '../features/cart/presentation/cart_page.dart';
import '../features/checkout/presentation/address_page.dart';
import '../features/checkout/presentation/order_review_page.dart';
import '../features/checkout/presentation/payment_method_page.dart';
import '../features/checkout/presentation/cod_success_page.dart';
import '../features/checkout/presentation/bank_transfer_page.dart';
import '../features/orders/presentation/order_detail_page.dart';
import '../features/orders/presentation/order_list_page.dart';
import '../shared/layout/pending_page.dart';
import '../features/profile/presentation/profile_page.dart';
import '../features/address_book/presentation/address_book_page.dart';
import '../features/vouchers/presentation/voucher_page.dart';
import '../features/help/presentation/faq_page.dart';
import '../features/about/presentation/about_page.dart';
import '../features/reviews/presentation/reviews_page.dart';
import '../features/comments/presentation/comments_page.dart';
import '../features/reviews/presentation/post_purchase_review_page.dart';

class CustomerApp extends StatelessWidget {
  CustomerApp({super.key, LenlabStore? store, this.initialRoute = '/'})
    : store = store ?? LenlabStore();
  final LenlabStore store;
  final String initialRoute;
  @override
  Widget build(BuildContext context) => CustomerScope(
    store: store,
    child: MaterialApp(
      title: 'LENLAB',
      debugShowCheckedModeBanner: false,
      theme: P2.theme(),
      initialRoute: initialRoute,
      onGenerateRoute: (settings) {
        final page = switch (settings.name) {
          '/' => const HomePage(),
          '/login' => AuthPage(
            returnIntent: settings.arguments is AuthReturnIntent
                ? settings.arguments as AuthReturnIntent
                : null,
          ),
          '/register' => AuthPage(
            register: true,
            returnIntent: settings.arguments is AuthReturnIntent
                ? settings.arguments as AuthReturnIntent
                : null,
          ),
          '/products' => CatalogPage(
            initialCategory: settings.arguments is String
                ? settings.arguments as String
                : 'Tất cả',
          ),
          '/product' =>
            settings.arguments is String
                ? ProductDetailRoute(productId: settings.arguments as String)
                : settings.arguments is Product
                ? ProductDetailRoute(
                    productId: (settings.arguments as Product).id,
                  )
                : const ProductUnavailablePage(),
          '/cart' => const CartPage(),
          '/checkout' => AddressPage(
            returnToReview: settings.arguments == 'edit-address',
          ),
          '/order-review' => OrderReviewPage(
            address: settings.arguments is Address
                ? settings.arguments as Address
                : null,
          ),
          '/payment-method' => const PaymentMethodPage(),
          '/bank-transfer' => const BankTransferPage(),
          '/orders' => const OrderListPage(),
          '/profile' => const ProfilePage(),
          '/addresses' => const AddressBookPage(),
          '/vouchers' => const VoucherPage(),
          '/faq' => const FaqPage(),
          '/about' => const AboutPage(),
          '/reviews' =>
            settings.arguments is String &&
                    (settings.arguments as String).trim().isNotEmpty
                ? ReviewsPage(productId: settings.arguments as String)
                : const ProductUnavailablePage(),
          '/comments' =>
            settings.arguments is String &&
                    (settings.arguments as String).trim().isNotEmpty
                ? CommentsPage(productId: settings.arguments as String)
                : const ProductUnavailablePage(),
          '/write-review' =>
            settings.arguments is String &&
                    (settings.arguments as String).trim().isNotEmpty
                ? PostPurchaseReviewPage(orderId: settings.arguments as String)
                : const ProductUnavailablePage(),
          '/support' => FaqPage(
            orderId: settings.arguments is String
                ? settings.arguments as String
                : null,
          ),
          '/order-detail' => OrderDetailPage(
            orderId: settings.arguments is String
                ? settings.arguments as String
                : null,
          ),
          '/cod-confirmation' => CodSuccessPage(
            order: settings.arguments is Order
                ? settings.arguments as Order
                : null,
          ),
          _ => PendingPage(route: settings.name ?? ''),
        };
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) =>
              AuthReturnIntent.privateRoutes.contains(settings.name) &&
                  (settings.name != '/support' || settings.arguments is String)
              ? CustomerSessionGate(
                  route: settings.name!,
                  arguments: settings.arguments is String
                      ? settings.arguments as String
                      : null,
                  builder: (_) => page,
                )
              : page,
        );
      },
    ),
  );
}
