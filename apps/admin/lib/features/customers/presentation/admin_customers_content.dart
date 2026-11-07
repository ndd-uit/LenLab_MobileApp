import 'dart:async';

import 'package:flutter/material.dart';

import '../../../shared/widgets/admin_list_pagination.dart';
import '../data/admin_customers_source.dart';
import 'widgets/customer_styles.dart';
import 'widgets/customers_filters.dart';
import 'widgets/customers_table.dart';

class AdminCustomersContent extends StatefulWidget {
  const AdminCustomersContent({super.key, this.source});
  final AdminCustomersSource? source;
  @override
  State<AdminCustomersContent> createState() => _AdminCustomersContentState();
}

class _AdminCustomersContentState extends State<AdminCustomersContent> {
  final _search = TextEditingController();
  late AdminCustomersSource _source;
  AdminCustomerRole? _role;
  AdminCustomerStatus? _status;
  AdminCustomersResult? _result;
  bool _loading = true, _error = false;
  int _generation = 0, _requestedPage = 1;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _source = widget.source ?? MockAdminCustomersSource();
    _load();
  }

  @override
  void didUpdateWidget(covariant AdminCustomersContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source != widget.source) {
      _source = widget.source ?? MockAdminCustomersSource();
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
    final query = AdminCustomersQuery(
      search: _search.text,
      role: _role,
      status: _status,
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
    _role = null;
    _status = null;
    _load();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      CustomersFilters(
        search: _search,
        role: _role,
        status: _status,
        onSearch: (_) => _load(debounce: true),
        onRole: (value) {
          _role = value;
          _load();
        },
        onStatus: (value) {
          _status = value;
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
                    semanticsLabel: 'Đang tải người dùng',
                  ),
                ),
              )
            : _error
            ? _message(
                'Không thể tải danh sách người dùng',
                'Vui lòng thử lại. Bộ lọc của bạn được giữ nguyên.',
                'Thử lại',
                () => _load(page: _requestedPage),
              )
            : _result!.total == 0
            ? _message(
                'Không có người dùng',
                _search.text.trim().isNotEmpty ||
                        _role != null ||
                        _status != null
                    ? 'Không có người dùng khớp tìm kiếm và bộ lọc.'
                    : 'Danh sách người dùng hiện đang trống.',
                'Xóa bộ lọc',
                _clear,
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomersTable(customers: _result!.items),
                  AdminListPagination(
                    summary:
                        'Hiển thị ${_result!.start}-${_result!.end} trong số ${_result!.total} người dùng',
                    page: _result!.page,
                    pages: _result!.pages,
                    onPage: (page) => _load(page: page),
                    accent: customerAccent,
                    previousIcon: customerAsset('imgContainer19', 3.849, 6.508),
                    nextIcon: customerAsset('imgContainer20', 3.849, 6.508),
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
