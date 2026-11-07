import 'package:flutter/material.dart';

import '../../../../shared/layout/admin_styles.dart';
import '../../data/dashboard_source.dart';

class DashboardCard extends StatelessWidget {
  const DashboardCard({super.key, required this.child, this.padding = 20});
  final Widget child;
  final double padding;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(padding),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFF9FAFB)),
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [
        BoxShadow(
          color: Color(0x08000000),
          offset: Offset(0, 2),
          blurRadius: 10,
        ),
      ],
    ),
    child: child,
  );
}

class DashboardMetrics extends StatelessWidget {
  const DashboardMetrics({super.key, required this.snapshot});
  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
      final columns = constraints.maxWidth >= 880 * scale
          ? 4
          : constraints.maxWidth >= 420 * scale
          ? 2
          : 1;
      final width = (constraints.maxWidth - (columns - 1) * 24) / columns;
      final cards = [
        _Metric(
          'Tổng doanh số',
          snapshot.salesLabel,
          'imgBackground',
          snapshot.salesChange ?? '—',
          const Color(0xFFF0FDF4),
          const Color(0xFF344D24),
          'imgContainer13',
        ),
        _Metric(
          'Đơn hàng mới',
          '${snapshot.newOrders}',
          'imgBackground1',
          snapshot.ordersChange ?? '—',
          const Color(0xFFEFF6FF),
          const Color(0xFF244968),
          'imgContainer14',
        ),
        _Metric(
          'Khách hàng mới',
          '${snapshot.newCustomers}',
          'imgBackground2',
          snapshot.customersChange ?? '—',
          const Color(0xFFFFF7ED),
          adminActive,
          'imgContainer15',
        ),
        _Metric(
          'Sắp hết kho',
          '${snapshot.lowStock}',
          'imgBackground3',
          snapshot.lowStock > 0 ? '!' : '—',
          const Color(0xFFFEF2F2),
          adminActive,
          null,
        ),
      ];
      return Wrap(
        spacing: 24,
        runSpacing: 24,
        children: [
          for (final card in cards) SizedBox(width: width, child: card),
        ],
      );
    },
  );
}

class _Metric extends StatelessWidget {
  const _Metric(
    this.label,
    this.value,
    this.icon,
    this.change,
    this.badgeBackground,
    this.badgeColor,
    this.arrow,
  );
  final String label, value, icon, change;
  final Color badgeBackground, badgeColor;
  final String? arrow;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(minHeight: 144),
    child: DashboardCard(
      padding: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 35, height: 36, child: adminAsset(icon, 35, 36)),
              Tooltip(
                message: 'Chỉ số minh họa P2; chưa có kỳ đối chiếu thực tế.',
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (arrow != null) ...[
                        adminAsset(arrow!, 8, 8),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        change,
                        style: TextStyle(
                          fontSize: 12,
                          height: 16 / 12,
                          fontWeight: FontWeight.w600,
                          color: badgeColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              height: 16 / 12,
              color: adminText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              height: 32 / 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    ),
  );
}
