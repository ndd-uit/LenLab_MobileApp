import '../../../app/customer_session_gate.dart';

import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';
import 'package:lenlab_customer/app/customer_scope.dart';

import 'order_list_styles.dart';
import 'widgets/order_list_header.dart';
import 'widgets/order_list_tabs.dart';
import 'widgets/order_list_card.dart';

class OrderListPage extends StatelessWidget {
  const OrderListPage({super.key, this.source});
  final OrderListSource? source;
  @override
  Widget build(BuildContext context) => CustomerSessionGate(
    route: '/orders',
    builder: (_) => _OrderListPageContent(source: source),
  );
}

class _OrderListPageContent extends StatefulWidget {
  const _OrderListPageContent({this.source});
  final OrderListSource? source;
  @override
  State<_OrderListPageContent> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<_OrderListPageContent> {
  OrderListSource? source;
  Future<List<Order>>? request;
  OrderState? selected;
  final scroll = ScrollController();
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final store = CustomerScope.of(context);
    source ??=
        widget.source ??
        MockOrderListSource(store.repository, store.orders, session: store);
    request ??= source!.load();
  }

  @override
  void dispose() {
    scroll.dispose();
    super.dispose();
  }

  Future<void> reload() async {
    final next = source!.load(state: selected);
    setState(() {
      request = next;
    });
    // FutureBuilder presents any error; RefreshIndicator should finish as well.
    try {
      await next;
    } catch (_) {
      /* Rendered by the builder. */
    }
  }

  void select(OrderState? state) {
    if (state == selected) return;
    setState(() {
      selected = state;
      request = source!.load(state: state);
    });
    if (scroll.hasClients) scroll.jumpTo(0);
  }

  Future<void> details(Order order) async {
    await Navigator.pushNamed(context, '/order-detail', arguments: order.id);
    if (mounted) await reload();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: OrderListHeader(
      height: MediaQuery.textScalerOf(context).scale(18) > 18 ? 80 : 65,
    ),
    body: SafeArea(
      top: false,
      child: Column(
        children: [
          OrderListTabs(selected: selected, onSelect: select),
          Expanded(
            child: FutureBuilder<List<Order>>(
              future: request,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return Center(
                    child: Semantics(
                      label: 'Đang tải danh sách đơn hàng',
                      liveRegion: true,
                      child: const CircularProgressIndicator(),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return _message(
                    'Không thể tải danh sách đơn hàng',
                    'Vui lòng thử lại.',
                  );
                }
                final orders = snapshot.data ?? [];
                if (orders.isEmpty) {
                  return _message(
                    selected == null
                        ? 'Bạn chưa có đơn hàng nào'
                        : 'Không có đơn hàng ở trạng thái này',
                    'Các đơn hàng phù hợp sẽ xuất hiện tại đây.',
                  );
                }
                return RefreshIndicator(
                  onRefresh: reload,
                  child: ListView.separated(
                    key: const ValueKey('order-list'),
                    controller: scroll,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    itemCount: orders.length + 1,
                    separatorBuilder: (_, _) => const SizedBox(height: 16),
                    itemBuilder: (context, index) => index == orders.length
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Text(
                              'Đã hiển thị hết đơn hàng',
                              textAlign: TextAlign.center,
                              style: orderListType(
                                12,
                                color: P2.brown,
                                serif: true,
                                weight: FontWeight.w500,
                              ),
                            ),
                          )
                        : OrderListCard(
                            key: ValueKey('order-${orders[index].id}'),
                            order: orders[index],
                            onDetails: () => details(orders[index]),
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );

  Widget _message(String title, String description) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: EmptyPanel(
        title,
        description: description,
        action: P2Button('Thử lại', onPressed: reload),
      ),
    ),
  );
}
