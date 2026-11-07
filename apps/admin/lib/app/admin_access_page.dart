import 'package:flutter/material.dart';

import '../features/auth/presentation/admin_login_page.dart';
import '../shared/layout/admin_shell.dart';
import 'admin_scope.dart';
import 'admin_destination.dart';
import '../features/orders/data/admin_orders_source.dart';
import '../features/customers/data/admin_customers_source.dart';
import '../features/conversations/data/admin_conversations_source.dart';
import '../features/conversations/data/admin_chatbot_source.dart';
import '../features/coupons/data/admin_percentage_coupon_source.dart';
import '../features/coupons/data/admin_fixed_coupon_source.dart';

class AdminAccessPage extends StatelessWidget {
  const AdminAccessPage({
    super.key,
    required this.path,
    this.ordersSource,
    this.customersSource,
    this.conversationsSource,
    this.chatbotSource,
    this.percentageCouponSource,
    this.fixedCouponSource,
  });
  final AdminCustomersSource? customersSource;
  final AdminConversationsSource? conversationsSource;
  final AdminChatbotSource? chatbotSource;
  final AdminPercentageCouponSource? percentageCouponSource;
  final AdminFixedCouponSource? fixedCouponSource;
  final AdminOrdersSource? ordersSource;
  final String path;
  @override
  Widget build(BuildContext context) {
    if (!AdminScope.of(context).signedIn) return const AdminLoginPage();
    final uri = Uri.tryParse(path);
    final detail = uri?.path == '/orders/detail';
    final customerDetail = uri?.path == '/customers/detail';
    return AdminShell(
      destination: detail
          ? AdminDestination.orders
          : customerDetail
          ? AdminDestination.customers
          : AdminDestination.fromPath(path == '/login' ? '/' : path),
      ordersSource: ordersSource,
      orderDetail: detail,
      orderId: uri?.queryParameters['id'],
      customersSource: customersSource,
      customerDetail: customerDetail,
      customerId: uri?.queryParameters['id'],
      conversationsSource: conversationsSource,
      chatbotSource: chatbotSource,
      percentageCouponSource: percentageCouponSource,
      fixedCouponSource: fixedCouponSource,
    );
  }
}
