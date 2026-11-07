import 'dart:async';

import 'package:flutter/material.dart';

import '../../../shared/widgets/admin_list_pagination.dart';
import '../data/admin_orders_source.dart';
import 'widgets/order_styles.dart';
import 'widgets/orders_filters.dart';
import 'widgets/orders_table.dart';

class AdminOrdersContent extends StatefulWidget {
  const AdminOrdersContent({super.key, this.source});
  final AdminOrdersSource? source;
  @override
  State<AdminOrdersContent> createState() => _AdminOrdersContentState();
}

class _AdminOrdersContentState extends State<AdminOrdersContent> {
  final _search = TextEditingController();
  late AdminOrdersSource _source;
  AdminOrderStatus? _status;
  AdminOrderPayment? _payment;
  AdminOrdersResult? _result;
  bool _loading = true, _error = false;
  int _generation = 0, _requestedPage = 1;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _source = widget.source ?? MockAdminOrdersSource();
    _load();
  }

  @override
  void didUpdateWidget(covariant AdminOrdersContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source != widget.source) {
      _source = widget.source ?? MockAdminOrdersSource();
      _load();
    }
  }

  @override
  void dispose() {
    _generation++;
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _load({int page = 1, bool debounce = false}) {
    _requestedPage = page;
    _debounce?.cancel();
    final generation = ++_generation;
    final source = _source;
    final query = AdminOrdersQuery(
      search: _search.text,
      status: _status,
      payment: _payment,
      page: page,
    );
    setState(() {
      _loading = true;
      _error = false;
      _result = null;
    });
    Future<void> fetch() async {
      try {
        final result = await source.fetch(query);
        if (!mounted || generation != _generation) return;
        setState(() {
          _result = result;
          _loading = false;
        });
      } catch (_) {
        if (!mounted || generation != _generation) return;
        setState(() {
          _error = true;
          _loading = false;
        });
      }
    }

    if (debounce) {
      _debounce = Timer(const Duration(milliseconds: 250), fetch);
    } else {
      unawaited(fetch());
    }
  }

  void _clear() {
    _search.clear();
    _status = null;
    _payment = null;
    _load();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      OrdersFilters(
        search: _search,
        status: _status,
        payment: _payment,
        onSearch: (_) => _load(debounce: true),
        onStatus: (value) {
          _status = value;
          _load();
        },
        onPayment: (value) {
          _payment = value;
          _load();
        },
        onClear: _clear,
      ),
      const SizedBox(height: 24),
      Container(
        decoration: adminListSurface(),
        clipBehavior: Clip.antiAlias,
        child: _loading
            ? const SizedBox(
                height: 480,
                child: Center(
                  child: CircularProgressIndicator(
                    semanticsLabel: 'Đang tải đơn hàng',
                  ),
                ),
              )
            : _error
            ? _message(
                'Không thể tải danh sách đơn hàng',
                'Vui lòng thử lại. Bộ lọc của bạn được giữ nguyên.',
                'Thử lại',
                () => _load(page: _requestedPage),
              )
            : _result!.total == 0
            ? _message(
                'Không có đơn hàng',
                _search.text.trim().isNotEmpty ||
                        _status != null ||
                        _payment != null
                    ? 'Không có đơn hàng khớp tìm kiếm và bộ lọc.'
                    : 'Danh sách đơn hàng hiện đang trống.',
                'Xóa bộ lọc',
                _clear,
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OrdersTable(orders: _result!.items),
                  AdminListPagination(
                    summary:
                        'Hiển thị ${_result!.start}-${_result!.end} trong số ${_result!.total} đơn hàng',
                    page: _result!.page,
                    pages: _result!.pages,
                    onPage: (page) => _load(page: page),
                    accent: orderAccent,
                    previousIcon: orderAsset('imgContainer14', 3.849, 6.508),
                    nextIcon: orderAsset('imgContainer15', 3.849, 6.508),
                  ),
                ],
              ),
      ),
      const SizedBox(height: 16),
      const Text(
        'Dữ liệu mock • Chỉ đọc • Chưa kết nối backend',
        style: TextStyle(fontSize: 12, color: adminListMuted),
      ),
    ],
  );

  Widget _message(
    String title,
    String description,
    String button,
    VoidCallback action,
  ) => ConstrainedBox(
    constraints: const BoxConstraints(minHeight: 480),
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: adminListInk,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(color: adminListMuted),
          ),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: action, child: Text(button)),
        ],
      ),
    ),
  );
}
