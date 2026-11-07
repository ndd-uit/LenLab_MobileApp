import 'dart:async';

import 'package:flutter/material.dart';

import '../../../shared/widgets/admin_list_styles.dart';
import '../../../shared/widgets/admin_list_pagination.dart';
import '../data/admin_reviews_source.dart';
import 'widgets/review_card.dart';
import 'widgets/reviews_header.dart';

class AdminReviewsPage extends StatefulWidget {
  const AdminReviewsPage({super.key, this.source, this.onMenu});
  final AdminReviewsSource? source;
  final VoidCallback? onMenu;
  @override
  State<AdminReviewsPage> createState() => _AdminReviewsPageState();
}

class _AdminReviewsPageState extends State<AdminReviewsPage> {
  final _search = TextEditingController();
  final _scroll = ScrollController();
  late AdminReviewsSource _source;
  AdminReviewFilter _filter = AdminReviewFilter.all;
  int? _stars;
  AdminReviewsResult? _result;
  bool _loading = true, _error = false;
  int _generation = 0, _requestedPage = 1;
  Timer? _debounce;
  @override
  void initState() {
    super.initState();
    _source = widget.source ?? MockAdminReviewsSource();
    _load();
  }

  @override
  void didUpdateWidget(covariant AdminReviewsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source != widget.source) {
      _source = widget.source ?? MockAdminReviewsSource();
      _load();
    }
  }

  @override
  void dispose() {
    _generation++;
    _debounce?.cancel();
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _load({int page = 1, bool debounce = false}) {
    _requestedPage = page;
    _debounce?.cancel();
    final generation = ++_generation;
    final source = _source;
    final query = AdminReviewsQuery(
      search: _search.text,
      filter: _filter,
      stars: _stars,
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

  bool get _filtered =>
      _search.text.trim().isNotEmpty ||
      _filter != AdminReviewFilter.all ||
      _stars != null;
  void _clear() {
    _search.clear();
    _filter = AdminReviewFilter.all;
    _stars = null;
    _load();
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      ReviewsHeader(
        search: _search,
        onSearch: (_) => _load(debounce: true),
        stars: _stars,
        onStars: (value) {
          _stars = value;
          _load();
        },
        onMenu: widget.onMenu,
      ),
      Expanded(
        child: SingleChildScrollView(
          controller: _scroll,
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final value in AdminReviewFilter.values)
                    Semantics(
                      selected: _filter == value,
                      child: OutlinedButton(
                        key: ValueKey('reviews-filter-${value.name}'),
                        onPressed: () {
                          _filter = value;
                          _load();
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 34),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          backgroundColor: _filter == value
                              ? reviewAccent
                              : Colors.white,
                          foregroundColor: _filter == value
                              ? const Color(0xFF523A30)
                              : const Color(0xFF4B5563),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6.5,
                          ),
                          side: BorderSide(
                            color: _filter == value
                                ? reviewAccent
                                : adminListBorder,
                          ),
                          shape: const StadiumBorder(),
                        ),
                        child: Text(switch (value) {
                          AdminReviewFilter.all => 'Tất cả',
                          AdminReviewFilter.pending =>
                            'Chờ duyệt (${_result?.pendingCount ?? '—'})',
                          AdminReviewFilter.fiveStars => '5 Sao',
                          AdminReviewFilter.withImages => 'Có hình ảnh',
                        }, style: const TextStyle(fontSize: 14)),
                      ),
                    ),
                  if (_filtered)
                    TextButton(
                      onPressed: _clear,
                      child: const Text('Xóa bộ lọc'),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              if (_loading)
                const SizedBox(
                  height: 400,
                  child: Center(
                    child: CircularProgressIndicator(
                      semanticsLabel: 'Đang tải đánh giá',
                    ),
                  ),
                )
              else if (_error)
                _message(
                  'Không thể tải đánh giá',
                  'Bộ lọc được giữ nguyên. Vui lòng thử lại.',
                  'Thử lại',
                  () => _load(page: _requestedPage),
                )
              else if (_result!.total == 0)
                _message(
                  'Không có đánh giá',
                  _filtered
                      ? 'Không có đánh giá khớp tìm kiếm và bộ lọc.'
                      : 'Danh sách đánh giá hiện đang trống.',
                  _filtered ? 'Xóa bộ lọc' : 'Tải lại',
                  _filtered ? _clear : () => _load(),
                )
              else ...[
                for (final review in _result!.items) ...[
                  ReviewCard(review: review),
                  const SizedBox(height: 16),
                ],
                AdminListPagination(
                  summary:
                      'Hiển thị ${_result!.start}-${_result!.end} trong số ${_result!.total} đánh giá',
                  page: _result!.page,
                  pages: _result!.pages,
                  onPage: (page) {
                    _load(page: page);
                    _scroll.jumpTo(0);
                  },
                  accent: reviewAccent,
                  previousIcon: reviewAsset('imgContainer15', 4.317, 7),
                  nextIcon: reviewAsset('imgContainer16', 4.317, 7),
                ),
              ],
              const SizedBox(height: 16),
              const Text(
                'Dữ liệu mock • Chỉ đọc • Chưa kết nối backend',
                style: TextStyle(fontSize: 12, color: adminListMuted),
              ),
            ],
          ),
        ),
      ),
    ],
  );

  Widget _message(
    String title,
    String description,
    String button,
    VoidCallback action,
  ) => Container(
    padding: const EdgeInsets.all(24),
    constraints: const BoxConstraints(minHeight: 300),
    decoration: adminListSurface(),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: adminListInk,
          ),
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
  );
}
