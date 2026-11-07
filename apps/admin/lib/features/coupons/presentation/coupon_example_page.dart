import 'package:flutter/material.dart';

import '../data/admin_coupon_fields.dart';
import 'widgets/coupon_styles.dart';
import 'widgets/coupon_header_footer.dart';

class CouponExamplePage<T extends AdminCouponFields> extends StatefulWidget {
  const CouponExamplePage({
    super.key,
    required this.source,
    required this.sections,
    this.onMenu,
  });
  final AdminCouponSource<T> source;
  final Widget Function(T) sections;
  final VoidCallback? onMenu;
  @override
  State<CouponExamplePage<T>> createState() => _CouponExamplePageState<T>();
}

class _CouponExamplePageState<T extends AdminCouponFields>
    extends State<CouponExamplePage<T>> {
  late AdminCouponSource<T> _source;
  late Future<T?> _request;
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant CouponExamplePage<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source != widget.source) _load();
  }

  void _load() {
    _source = widget.source;
    _request = _source.fetch();
  }

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: couponCanvas,
    child: Column(
      children: [
        CouponHeader(onMenu: widget.onMenu),
        Expanded(
          child: LayoutBuilder(
            builder: (context, c) => SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: c.maxWidth >= 900 ? 64 : 16,
                vertical: 24,
              ),
              child: Align(
                alignment: Alignment.topLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 896),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: c.maxWidth >= 900 ? 20 : 0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Wrap(
                          spacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            InkWell(
                              key: const ValueKey('coupon-parent-breadcrumb'),
                              onTap: () => backToCouponParent(context),
                              child: const Text(
                                'Tổng quan',
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 20 / 14,
                                  color: couponBlue,
                                ),
                              ),
                            ),
                            couponAsset('imgContainer11', 4, 6),
                            const Text(
                              'Mã giảm giá',
                              style: TextStyle(
                                fontSize: 14,
                                height: 20 / 14,
                                color: couponBrown,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Chi tiết mã',
                          style: TextStyle(
                            fontSize: 30,
                            height: 36 / 30,
                            letterSpacing: -.75,
                            fontWeight: FontWeight.bold,
                            color: couponInk,
                          ),
                        ),
                        const SizedBox(height: 24),
                        FutureBuilder<T?>(
                          future: _request,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState !=
                                ConnectionState.done) {
                              return const SizedBox(
                                height: 400,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    semanticsLabel: 'Đang tải mẫu mã giảm giá',
                                  ),
                                ),
                              );
                            }
                            if (snapshot.hasError) {
                              return couponCard(
                                Column(
                                  children: [
                                    const Text('Không thể tải mẫu mã giảm giá'),
                                    const SizedBox(height: 16),
                                    OutlinedButton(
                                      onPressed: () => setState(() {
                                        _request = _source.fetch();
                                      }),
                                      child: const Text('Thử lại'),
                                    ),
                                  ],
                                ),
                              );
                            }
                            final example = snapshot.data;
                            if (example == null) {
                              return couponCard(
                                const Text('Chưa có dữ liệu mẫu mã giảm giá'),
                              );
                            }
                            return widget.sections(example);
                          },
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Dữ liệu minh họa P2 • Chỉ đọc • Chưa tạo mã. Các ô ví dụ/chưa điền chưa phải dữ liệu mã đã lưu.',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.5,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const CouponFooter(),
      ],
    ),
  );
}
