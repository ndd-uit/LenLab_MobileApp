import 'package:flutter/material.dart';

import '../../../shared/layout/admin_styles.dart';
import '../data/dashboard_source.dart';
import 'widgets/dashboard_metrics.dart';
import 'widgets/dashboard_products.dart';

class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key, this.source});
  final DashboardSource? source;

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  late DashboardSource _source;
  late Future<DashboardSnapshot?> _request;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  @override
  void didUpdateWidget(covariant DashboardContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source != widget.source) _reset();
  }

  void _reset() {
    _source = widget.source ?? MockDashboardSource();
    _request = _source.load();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 12,
        children: [
          const Text(
            'Tổng quan',
            style: TextStyle(
              fontSize: 24,
              height: 32 / 24,
              fontWeight: FontWeight.bold,
              color: adminHeading,
            ),
          ),
          FilledButton.icon(
            onPressed: () => adminPendingNotice(
              context,
              'Tạo đơn hàng mới',
              'Tạo đơn chưa được triển khai. Dashboard hiện chỉ đọc dữ liệu minh họa.',
            ),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFD97757),
              foregroundColor: const Color(0xFF332620),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: adminAsset('imgContainer11', 14, 14),
            label: const Text(
              'Tạo đơn hàng mới',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      const SizedBox(height: 32),
      Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 12,
        children: [
          const Text(
            'Thống kê kinh doanh',
            style: TextStyle(
              fontSize: 18,
              height: 28 / 18,
              fontWeight: FontWeight.bold,
              color: adminHeading,
            ),
          ),
          OutlinedButton(
            onPressed: () => adminPendingNotice(
              context,
              'Tháng này',
              'Chỉ có kỳ minh họa theo P2. Các khoảng ngày và cách tính thống kê chưa chốt.',
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              backgroundColor: Colors.white,
              foregroundColor: adminActive,
              side: const BorderSide(color: Color(0xFFE5E7EB)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Tháng này',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                adminAsset('imgContainer12', 7, 4),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      FutureBuilder<DashboardSnapshot?>(
        future: _request,
        builder: (context, result) {
          if (result.connectionState != ConnectionState.done) {
            return const DashboardCard(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: CircularProgressIndicator(
                    semanticsLabel: 'Đang tải thống kê',
                  ),
                ),
              ),
            );
          }
          if (result.hasError || result.data == null) {
            return DashboardCard(
              child: Column(
                children: [
                  Text(
                    result.hasError
                        ? 'Không thể tải thống kê'
                        : 'Chưa có dữ liệu thống kê',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: adminHeading,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    result.hasError
                        ? 'Vui lòng thử lại.'
                        : 'Chưa có số liệu cho kỳ đang xem.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () {
                      final request = _source.load();
                      setState(() {
                        _request = request;
                      });
                    },
                    child: Text(result.hasError ? 'Thử lại' : 'Tải lại'),
                  ),
                ],
              ),
            );
          }
          final snapshot = result.requireData!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DashboardMetrics(snapshot: snapshot),
              const SizedBox(height: 32),
              DashboardProducts(items: snapshot.products),
            ],
          );
        },
      ),
      const SizedBox(height: 16),
      const Text(
        'Dữ liệu minh họa • Chưa kết nối backend',
        style: TextStyle(fontSize: 12, color: adminText),
      ),
    ],
  );
}
