import 'package:flutter/material.dart';

import '../../../app/admin_order_navigation.dart';
import '../../../shared/layout/admin_styles.dart';
import '../data/admin_orders_source.dart';
import '../data/admin_order_detail.dart';
import 'widgets/order_styles.dart';
import 'widgets/order_detail_cards.dart';
import 'widgets/order_detail_products.dart';
import 'widgets/order_status_badge.dart';

class AdminOrderDetailPage extends StatefulWidget {
  const AdminOrderDetailPage({
    super.key,
    required this.id,
    this.source,
    this.onMenu,
  });
  final String? id;
  final AdminOrdersSource? source;
  final VoidCallback? onMenu;
  @override
  State<AdminOrderDetailPage> createState() => _AdminOrderDetailPageState();
}

class _AdminOrderDetailPageState extends State<AdminOrderDetailPage> {
  late AdminOrdersSource _source;
  late Future<AdminOrderDetail?> _request;
  String get _id => widget.id?.trim() ?? '';
  @override
  void initState() {
    super.initState();
    _reset();
  }

  @override
  void didUpdateWidget(covariant AdminOrderDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id || oldWidget.source != widget.source) {
      _reset();
    }
  }

  void _reset() {
    _source = widget.source ?? MockAdminOrdersSource();
    _request = _id.isEmpty ? Future.value(null) : _source.detail(_id);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<AdminOrderDetail?>(
    future: _request,
    builder: (context, result) {
      final waiting = result.connectionState != ConnectionState.done;
      final record = waiting || result.hasError ? null : result.data;
      final mismatched = record != null && record.summary.id != _id;
      final detail = mismatched ? null : record;
      return Column(
        children: [
          _header(detail),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: waiting
                  ? const SizedBox(
                      height: 480,
                      child: Center(
                        child: CircularProgressIndicator(
                          semanticsLabel: 'Đang tải chi tiết đơn hàng',
                        ),
                      ),
                    )
                  : result.hasError
                  ? _message(
                      'Không thể tải chi tiết đơn hàng',
                      'Vui lòng thử lại.',
                      retry: true,
                    )
                  : _id.isEmpty
                  ? _message(
                      'Thiếu mã đơn hàng',
                      'Chọn một đơn từ danh sách để xem chi tiết.',
                    )
                  : mismatched
                  ? _message(
                      'Dữ liệu đơn hàng không khớp mã',
                      'Không thể hiển thị thông tin của đơn khác.',
                    )
                  : detail == null
                  ? _message(
                      'Không tìm thấy đơn hàng',
                      'Mã đơn không tồn tại trong dữ liệu hiện tại.',
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final left = Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            OrderCustomerCard(detail: detail),
                            const SizedBox(height: 24),
                            OrderPaymentCard(detail: detail),
                          ],
                        );
                        final right = Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            OrderDetailProducts(detail: detail),
                            const SizedBox(height: 24),
                            const OrderHistoryCard(),
                          ],
                        );
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (constraints.maxWidth >= 900 &&
                                MediaQuery.textScalerOf(context).scale(14) <=
                                    16)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: (constraints.maxWidth - 24) / 3,
                                    child: left,
                                  ),
                                  const SizedBox(width: 24),
                                  Expanded(child: right),
                                ],
                              )
                            else ...[
                              left,
                              const SizedBox(height: 24),
                              right,
                            ],
                            const SizedBox(height: 16),
                            const Text(
                              'Dữ liệu mock • Chỉ đọc • Chưa kết nối backend',
                              style: TextStyle(
                                fontSize: 12,
                                color: adminListMuted,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ),
        ],
      );
    },
  );

  Widget _header(AdminOrderDetail? detail) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(bottom: BorderSide(color: adminListBorder)),
    ),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final title = Row(
          children: [
            if (widget.onMenu != null)
              IconButton(
                tooltip: 'Mở menu quản trị',
                onPressed: widget.onMenu,
                icon: const Icon(Icons.menu),
              ),
            IconButton(
              tooltip: 'Về danh sách đơn hàng',
              onPressed: () => backToAdminOrders(context),
              icon: detailAsset('imgLink', 31.609, 37.188),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        detail == null
                            ? 'Chi tiết đơn hàng'
                            : '#${detail.summary.id}',
                        style: const TextStyle(
                          fontSize: 24,
                          height: 32 / 24,
                          fontWeight: FontWeight.bold,
                          color: adminListInk,
                        ),
                      ),
                      if (detail != null)
                        OrderStatusBadge(status: detail.summary.status),
                    ],
                  ),
                  if (detail != null)
                    Text(
                      'Ngày đặt: ${orderDate(detail.summary.placedAt)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: adminListMuted,
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
        final actions = Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            IconButton(
              tooltip: 'Đổi giao diện',
              onPressed: () => adminPendingNotice(
                context,
                'Đổi giao diện',
                'Chưa triển khai đổi giao diện.',
              ),
              icon: detailAsset('imgContainer9', 17.96, 17.955),
            ),
            _action(
              'Hủy đơn',
              'imgContainer10',
              const Color(0xFFFEF2F2),
              const Color(0xFF991B1B),
            ),
            _action(
              'Duyệt đơn',
              'imgContainer11',
              const Color(0xFFD1A272),
              const Color(0xFF523A30),
            ),
          ],
        );
        return constraints.maxWidth >= 850
            ? Row(
                children: [
                  Expanded(child: title),
                  const SizedBox(width: 16),
                  actions,
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [title, const SizedBox(height: 12), actions],
              );
      },
    ),
  );
  Widget _action(
    String label,
    String asset,
    Color background,
    Color foreground,
  ) => Tooltip(
    message: '$label chưa triển khai trong bản chỉ đọc',
    child: FilledButton.icon(
      onPressed: null,
      style: FilledButton.styleFrom(
        disabledBackgroundColor: background,
        disabledForegroundColor: foreground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: detailAsset(asset, 11.648, 11.648),
      label: Text(label),
    ),
  );

  Widget _message(String title, String description, {bool retry = false}) =>
      Container(
        decoration: adminListSurface(),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: adminListInk,
              ),
            ),
            const SizedBox(height: 12),
            Text(description, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            if (retry)
              OutlinedButton(
                onPressed: () => setState(() {
                  _request = _source.detail(_id);
                }),
                child: const Text('Thử lại'),
              ),
            TextButton(
              onPressed: () => backToAdminOrders(context),
              child: const Text('Danh sách đơn hàng'),
            ),
          ],
        ),
      );
}
