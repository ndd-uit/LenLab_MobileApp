import 'package:flutter/material.dart';

import '../../../app/admin_customer_navigation.dart';
import '../../../shared/layout/admin_styles.dart';
import '../data/admin_customers_source.dart';
import '../data/admin_customer_detail.dart';
import 'widgets/customer_styles.dart';
import 'widgets/customer_detail_cards.dart';

class AdminCustomerDetailPage extends StatefulWidget {
  const AdminCustomerDetailPage({
    super.key,
    required this.id,
    this.source,
    this.onMenu,
  });
  final String? id;
  final AdminCustomersSource? source;
  final VoidCallback? onMenu;
  @override
  State<AdminCustomerDetailPage> createState() =>
      _AdminCustomerDetailPageState();
}

class _AdminCustomerDetailPageState extends State<AdminCustomerDetailPage> {
  late AdminCustomersSource _source;
  late Future<AdminCustomerDetail?> _request;
  String get _id => widget.id?.trim() ?? '';
  @override
  void initState() {
    super.initState();
    _reset();
  }

  @override
  void didUpdateWidget(covariant AdminCustomerDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id || oldWidget.source != widget.source) {
      _reset();
    }
  }

  void _reset() {
    _source = widget.source ?? MockAdminCustomersSource();
    _request = _id.isEmpty ? Future.value(null) : _source.detail(_id);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<AdminCustomerDetail?>(
    future: _request,
    builder: (context, result) {
      final waiting = result.connectionState != ConnectionState.done;
      final record = waiting || result.hasError ? null : result.data;
      final mismatch = record != null && record.customer.id != _id;
      final detail = mismatch ? null : record;
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
                          semanticsLabel: 'Đang tải chi tiết người dùng',
                        ),
                      ),
                    )
                  : result.hasError
                  ? _message(
                      'Không thể tải chi tiết người dùng',
                      'Vui lòng thử lại.',
                      retry: true,
                    )
                  : _id.isEmpty
                  ? _message(
                      'Thiếu mã người dùng',
                      'Chọn một người dùng từ danh sách để xem chi tiết.',
                    )
                  : mismatch
                  ? _message(
                      'Dữ liệu người dùng không khớp mã',
                      'Không thể hiển thị thông tin của người khác.',
                    )
                  : detail == null
                  ? _message(
                      'Không tìm thấy người dùng',
                      'Mã người dùng không tồn tại trong dữ liệu hiện tại.',
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) => Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (constraints.maxWidth >= 920 &&
                              MediaQuery.textScalerOf(context).scale(14) <= 16)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: CustomerPersonalCard(detail: detail),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: CustomerAccountCard(
                                    customer: detail.customer,
                                  ),
                                ),
                              ],
                            )
                          else ...[
                            CustomerPersonalCard(detail: detail),
                            const SizedBox(height: 24),
                            CustomerAccountCard(customer: detail.customer),
                          ],
                          const SizedBox(height: 32),
                          const CustomerHistoryCard(),
                          const SizedBox(height: 24),
                          Wrap(
                            alignment: WrapAlignment.end,
                            spacing: 16,
                            runSpacing: 12,
                            children: [
                              OutlinedButton(
                                onPressed: () => backToAdminCustomers(context),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF374151),
                                  side: const BorderSide(
                                    color: Color(0xFFD1D5DB),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Đóng'),
                              ),
                              Tooltip(
                                message: 'Chưa hỗ trợ chỉnh sửa/lưu tài khoản',
                                child: FilledButton.icon(
                                  onPressed: null,
                                  style: FilledButton.styleFrom(
                                    disabledBackgroundColor: customerAccent,
                                    disabledForegroundColor: const Color(
                                      0xFF523A30,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  icon: customerDetailAsset(
                                    'imgContainer22',
                                    10.5,
                                    10.5,
                                  ),
                                  label: const Text('Lưu thay đổi'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Dữ liệu mock • Chỉ đọc • Chưa kết nối backend',
                            style: TextStyle(
                              fontSize: 12,
                              color: adminListMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      );
    },
  );

  Widget _header(AdminCustomerDetail? detail) => Container(
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text(
                        'Khách hàng',
                        style: TextStyle(fontSize: 14, color: adminListMuted),
                      ),
                      customerDetailAsset('imgContainer9', 3.299, 5.578),
                      if (detail != null)
                        Text(
                          detail.customer.name,
                          style: const TextStyle(
                            fontSize: 14,
                            color: adminListInk,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Chi tiết & Lịch sử mua hàng',
                    style: TextStyle(
                      fontSize: 24,
                      height: 32 / 24,
                      fontWeight: FontWeight.bold,
                      color: adminListInk,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
        final actions = Wrap(
          spacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            IconButton(
              tooltip: 'Đổi giao diện',
              onPressed: () => adminPendingNotice(
                context,
                'Đổi giao diện',
                'Chưa triển khai đổi giao diện.',
              ),
              icon: customerDetailAsset('imgContainer10', 17.96, 17.955),
            ),
            TextButton.icon(
              onPressed: () => backToAdminCustomers(context),
              style: TextButton.styleFrom(
                backgroundColor: adminListBorder,
                foregroundColor: const Color(0xFF374151),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: customerDetailAsset('imgContainer11', 9.105, 8.859),
              label: const Text('Quay lại'),
            ),
          ],
        );
        return constraints.maxWidth >= 760
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
              onPressed: () => backToAdminCustomers(context),
              child: const Text('Danh sách người dùng'),
            ),
          ],
        ),
      );
}
