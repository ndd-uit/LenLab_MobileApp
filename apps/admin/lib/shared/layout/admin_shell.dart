import 'package:flutter/material.dart';

import '../../app/admin_destination.dart';
import '../../features/dashboard/presentation/dashboard_content.dart';
import '../../features/products/presentation/admin_products_content.dart';
import '../../features/products/presentation/widgets/products_header.dart';
import '../../features/orders/presentation/admin_orders_content.dart';
import '../../features/orders/presentation/widgets/orders_header.dart';
import '../../features/orders/data/admin_orders_source.dart';
import '../../features/orders/presentation/admin_order_detail_page.dart';
import '../../features/customers/presentation/admin_customers_content.dart';
import '../../features/customers/presentation/widgets/customers_header.dart';
import '../../app/admin_order_navigation.dart';
import '../../app/admin_customer_navigation.dart';
import '../../features/customers/data/admin_customers_source.dart';
import '../../features/customers/presentation/admin_customer_detail_page.dart';
import 'admin_header.dart';
import 'admin_sidebar.dart';
import 'admin_styles.dart';
import '../../features/reviews/presentation/admin_reviews_page.dart';
import '../../features/settings/presentation/admin_settings_page.dart';
import '../../features/conversations/data/admin_conversations_source.dart';
import '../../features/conversations/presentation/admin_conversations_page.dart';
import '../../features/conversations/presentation/admin_chatbot_page.dart';
import '../../features/conversations/data/admin_chatbot_source.dart';
import '../../features/coupons/presentation/admin_percentage_coupon_page.dart';
import '../../features/coupons/presentation/admin_fixed_coupon_page.dart';
import '../../features/coupons/data/admin_percentage_coupon_source.dart';
import '../../features/coupons/data/admin_fixed_coupon_source.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({
    super.key,
    required this.destination,
    this.ordersSource,
    this.orderDetail = false,
    this.orderId,
    this.customersSource,
    this.customerDetail = false,
    this.customerId,
    this.conversationsSource,
    this.chatbotSource,
    this.percentageCouponSource,
    this.fixedCouponSource,
  });
  final AdminOrdersSource? ordersSource;
  final bool orderDetail;
  final String? orderId;
  final AdminCustomersSource? customersSource;
  final bool customerDetail;
  final String? customerId;
  final AdminDestination destination;
  final AdminConversationsSource? conversationsSource;
  final AdminChatbotSource? chatbotSource;
  final AdminPercentageCouponSource? percentageCouponSource;
  final AdminFixedCouponSource? fixedCouponSource;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < 960;
      final listPage =
          destination == AdminDestination.products ||
          destination == AdminDestination.conversations ||
          destination == AdminDestination.chatbot ||
          destination == AdminDestination.orders ||
          destination == AdminDestination.customers;
      void select(BuildContext shellContext, AdminDestination target) {
        if (compact) Navigator.pop(shellContext);
        if (customerDetail && target == AdminDestination.customers) {
          backToAdminCustomers(context);
          return;
        }
        if (orderDetail && target == AdminDestination.orders) {
          backToAdminOrders(context);
          return;
        }
        if (target != destination) Navigator.of(context).pushNamed(target.path);
      }

      return Scaffold(
        backgroundColor: destination == AdminDestination.reviews
            ? const Color(0xFFF9FAFB)
            : listPage
            ? const Color(0xFFF3F4F6)
            : adminCanvas,
        drawer: compact
            ? Drawer(
                width: 256,
                shape: const RoundedRectangleBorder(),
                child: Builder(
                  builder: (drawerContext) => AdminSidebar(
                    selected: destination,
                    onSelect: (target) => select(drawerContext, target),
                  ),
                ),
              )
            : null,
        body: SafeArea(
          child: Row(
            children: [
              if (!compact)
                AdminSidebar(
                  selected: destination,
                  onSelect: (target) => select(context, target),
                ),
              Expanded(
                child: destination == AdminDestination.fixedCoupon
                    ? Builder(
                        builder: (scaffoldContext) => AdminFixedCouponPage(
                          source: fixedCouponSource,
                          onMenu: compact
                              ? () => Scaffold.of(scaffoldContext).openDrawer()
                              : null,
                        ),
                      )
                    : destination == AdminDestination.percentageCoupon
                    ? Builder(
                        builder: (scaffoldContext) => AdminPercentageCouponPage(
                          source: percentageCouponSource,
                          onMenu: compact
                              ? () => Scaffold.of(scaffoldContext).openDrawer()
                              : null,
                        ),
                      )
                    : destination == AdminDestination.chatbot
                    ? Builder(
                        builder: (scaffoldContext) => AdminChatbotPage(
                          source: chatbotSource,
                          onMenu: compact
                              ? () => Scaffold.of(scaffoldContext).openDrawer()
                              : null,
                        ),
                      )
                    : destination == AdminDestination.conversations
                    ? Builder(
                        builder: (scaffoldContext) => AdminConversationsPage(
                          source: conversationsSource,
                          onMenu: compact
                              ? () => Scaffold.of(scaffoldContext).openDrawer()
                              : null,
                        ),
                      )
                    : destination == AdminDestination.settings
                    ? Builder(
                        builder: (scaffoldContext) => AdminSettingsPage(
                          onMenu: compact
                              ? () => Scaffold.of(scaffoldContext).openDrawer()
                              : null,
                        ),
                      )
                    : destination == AdminDestination.reviews
                    ? Builder(
                        builder: (scaffoldContext) => AdminReviewsPage(
                          onMenu: compact
                              ? () => Scaffold.of(scaffoldContext).openDrawer()
                              : null,
                        ),
                      )
                    : orderDetail
                    ? Builder(
                        builder: (scaffoldContext) => AdminOrderDetailPage(
                          id: orderId,
                          source: ordersSource,
                          onMenu: compact
                              ? () => Scaffold.of(scaffoldContext).openDrawer()
                              : null,
                        ),
                      )
                    : customerDetail
                    ? Builder(
                        builder: (scaffoldContext) => AdminCustomerDetailPage(
                          id: customerId,
                          source: customersSource,
                          onMenu: compact
                              ? () => Scaffold.of(scaffoldContext).openDrawer()
                              : null,
                        ),
                      )
                    : Column(
                        children: [
                          Builder(
                            builder: (scaffoldContext) =>
                                destination == AdminDestination.products
                                ? ProductsHeader(
                                    onMenu: compact
                                        ? () =>
                                              Scaffold.of(scaffoldContext)
                                                  .openDrawer()
                                        : null,
                                  )
                                : destination == AdminDestination.orders
                                ? OrdersHeader(
                                    onMenu: compact
                                        ? () =>
                                              Scaffold.of(scaffoldContext)
                                                  .openDrawer()
                                        : null,
                                  )
                                : destination == AdminDestination.customers
                                ? CustomersHeader(
                                    onMenu: compact
                                        ? () =>
                                              Scaffold.of(scaffoldContext)
                                                  .openDrawer()
                                        : null,
                                  )
                                : AdminHeader(
                                    onMenu: compact
                                        ? () =>
                                              Scaffold.of(scaffoldContext)
                                                  .openDrawer()
                                        : null,
                                  ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              padding: EdgeInsets.fromLTRB(
                                listPage
                                    ? 24
                                    : compact
                                    ? 24
                                    : 32,
                                listPage
                                    ? 24
                                    : compact
                                    ? 32
                                    : 64,
                                listPage
                                    ? 24
                                    : compact
                                    ? 24
                                    : 32,
                                32,
                              ),
                              child: destination == AdminDestination.dashboard
                                  ? const DashboardContent()
                                  : destination == AdminDestination.products
                                  ? const AdminProductsContent()
                                  : destination == AdminDestination.orders
                                  ? AdminOrdersContent(source: ordersSource)
                                  : destination == AdminDestination.customers
                                  ? AdminCustomersContent(
                                      source: customersSource,
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Text(
                                          destination.title,
                                          style: const TextStyle(
                                            fontSize: 24,
                                            height: 32 / 24,
                                            fontWeight: FontWeight.bold,
                                            color: adminHeading,
                                          ),
                                        ),
                                        const SizedBox(height: 32),
                                        Container(
                                          padding: const EdgeInsets.all(24),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                destination ==
                                                        AdminDestination
                                                            .notFound
                                                    ? 'Trang không tồn tại'
                                                    : '${destination.title} chưa được triển khai',
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  height: 1.5,
                                                  fontWeight: FontWeight.w600,
                                                  color: adminHeading,
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              Text(
                                                destination ==
                                                        AdminDestination
                                                            .dashboard
                                                    ? 'Khung quản trị đã sẵn sàng. Số liệu, biểu đồ và danh sách sản phẩm sẽ được bổ sung trong phần Bảng điều khiển.'
                                                    : destination ==
                                                          AdminDestination
                                                              .notFound
                                                    ? 'Vui lòng chọn một mục trong menu quản trị.'
                                                    : 'Bạn đang xem màn tạm của mục ${destination.title}. Tính năng này sẽ được triển khai ở phần riêng.',
                                                style: const TextStyle(
                                                  color: adminText,
                                                  height: 1.6,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
