import '../../../app/customer_session_gate.dart';

import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';
import 'package:lenlab_customer/app/customer_scope.dart';
import 'package:lenlab_customer/app/navigation.dart';

import 'widgets/order_detail_header.dart';
import 'widgets/order_detail_status.dart';
import 'widgets/order_detail_products.dart';
import 'widgets/order_detail_information.dart';
import 'widgets/order_detail_actions.dart';

class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({super.key, this.orderId, this.source});
  final String? orderId;
  final OrderDetailSource? source;
  @override
  Widget build(BuildContext context) => CustomerSessionGate(
    route: '/order-detail',
    arguments: orderId,
    builder: (_) => _OrderDetailPageContent(orderId: orderId, source: source),
  );
}

class _OrderDetailPageContent extends StatefulWidget {
  const _OrderDetailPageContent({this.orderId, this.source});
  final String? orderId;
  final OrderDetailSource? source;
  @override
  State<_OrderDetailPageContent> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<_OrderDetailPageContent> {
  OrderDetailSource? source;
  Future<Order?>? request;
  String? loadedId;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final store = CustomerScope.of(context);
    source ??=
        widget.source ??
        MockOrderDetailSource(store.repository, store.orders, session: store);
    if (widget.orderId != null && widget.orderId != loadedId) {
      loadedId = widget.orderId;
      request = source!.load(widget.orderId!);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: OrderDetailHeader(
      height: MediaQuery.textScalerOf(context).scale(18) > 18 ? 88 : 64,
    ),
    body: SafeArea(
      top: false,
      child: widget.orderId == null || widget.orderId!.trim().isEmpty
          ? _missing(context)
          : FutureBuilder<Order?>(
              future: request,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return Center(
                    child: Semantics(
                      label: 'Đang tải chi tiết đơn hàng',
                      liveRegion: true,
                      child: const CircularProgressIndicator(),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: EmptyPanel(
                      'Không thể tải chi tiết đơn hàng',
                      description: 'Vui lòng thử lại.',
                      action: P2Button(
                        'Thử lại',
                        onPressed: () {
                          setState(() {
                            request = source!.load(widget.orderId!);
                          });
                        },
                      ),
                    ),
                  );
                }
                final order = snapshot.data;
                if (order == null) return _missing(context);
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      OrderDetailStatus(order: order),
                      const SizedBox(height: 20),
                      OrderDetailProducts(lines: order.lines),
                      const SizedBox(height: 20),
                      OrderDetailInformation(order: order),
                    ],
                  ),
                );
              },
            ),
    ),
    bottomNavigationBar: request == null
        ? null
        : FutureBuilder<Order?>(
            future: request,
            builder: (context, snapshot) =>
                snapshot.connectionState == ConnectionState.done &&
                    !snapshot.hasError &&
                    snapshot.data != null
                ? OrderDetailActions(order: snapshot.data!)
                : const SizedBox.shrink(),
          ),
  );
  Widget _missing(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: EmptyPanel(
        'Không tìm thấy đơn hàng',
        description: 'Vui lòng kiểm tra lại mã đơn.',
        action: P2Button('Về trang chủ', onPressed: () => home(context)),
      ),
    ),
  );
}
