import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

import 'app/admin_access_page.dart';
import 'app/admin_scope.dart';
import 'app/admin_session.dart';
import 'features/auth/data/admin_auth_source.dart';
import 'features/orders/data/admin_orders_source.dart';
import 'features/customers/data/admin_customers_source.dart';
import 'shared/layout/admin_styles.dart';
import 'features/conversations/data/admin_conversations_source.dart';
import 'features/conversations/data/admin_chatbot_source.dart';
import 'features/coupons/data/admin_percentage_coupon_source.dart';
import 'features/coupons/data/admin_fixed_coupon_source.dart';

class AdminApp extends StatefulWidget {
  const AdminApp({
    super.key,
    this.initialRoute,
    this.session,
    this.ordersSource,
    this.customersSource,
    this.conversationsSource,
    this.chatbotSource,
    this.percentageCouponSource,
    this.fixedCouponSource,
  });
  final AdminOrdersSource? ordersSource;
  final AdminCustomersSource? customersSource;
  final AdminConversationsSource? conversationsSource;
  final AdminChatbotSource? chatbotSource;
  final AdminPercentageCouponSource? percentageCouponSource;
  final AdminFixedCouponSource? fixedCouponSource;
  final String? initialRoute;
  final AdminSession? session;
  @override
  State<AdminApp> createState() => _AdminAppState();
}

class _AdminAppState extends State<AdminApp> {
  late final ordersSource = widget.ordersSource ?? MockAdminOrdersSource();
  late final customersSource =
      widget.customersSource ?? MockAdminCustomersSource();
  late final session =
      widget.session ?? AdminSession(source: MockAdminAuthSource());
  late final conversationsSource =
      widget.conversationsSource ?? MockAdminConversationsSource();
  late final chatbotSource = widget.chatbotSource ?? MockAdminChatbotSource();
  late final percentageCouponSource =
      widget.percentageCouponSource ?? MockAdminPercentageCouponSource();
  late final fixedCouponSource =
      widget.fixedCouponSource ?? MockAdminFixedCouponSource();
  @override
  void dispose() {
    if (widget.session == null) session.dispose();
    super.dispose();
  }

  Route<void> route(RouteSettings settings) => PageRouteBuilder<void>(
    settings: settings,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
    pageBuilder: (_, animation, secondaryAnimation) => AdminAccessPage(
      path: settings.name ?? '/',
      ordersSource: ordersSource,
      customersSource: customersSource,
      conversationsSource: conversationsSource,
      chatbotSource: chatbotSource,
      percentageCouponSource: percentageCouponSource,
      fixedCouponSource: fixedCouponSource,
    ),
  );

  bool get startsAtCoupon =>
      const ['/vouchers/percentage', '/vouchers/fixed'].contains(
        widget.initialRoute ??
            WidgetsBinding.instance.platformDispatcher.defaultRouteName,
      );

  @override
  Widget build(BuildContext context) => AdminScope(
    session: session,
    child: MaterialApp(
      title: 'LENLAB Admin',
      debugShowCheckedModeBanner: false,
      theme: P2
          .theme(admin: true)
          .copyWith(scaffoldBackgroundColor: adminCanvas),
      initialRoute: widget.initialRoute,
      // Do not synthesize the nonexistent '/vouchers' intermediate page when
      // opening a voucher URL directly. Other initial routes keep the default.
      onGenerateInitialRoutes: startsAtCoupon
          ? (name) => [
              route(const RouteSettings(name: '/')),
              route(RouteSettings(name: name)),
            ]
          : null,
      // Admin sections switch in place; do not animate the entire web shell.
      onGenerateRoute: route,
    ),
  );
}
