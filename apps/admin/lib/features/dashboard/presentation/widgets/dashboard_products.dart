import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

import '../../data/dashboard_source.dart';
import '../../../../shared/layout/admin_styles.dart';

class DashboardProducts extends StatelessWidget {
  const DashboardProducts({super.key, required this.items});
  final List<DashboardProductPreview> items;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          const Expanded(
            child: Text(
              'Sản phẩm đang bán',
              style: TextStyle(
                fontSize: 18,
                height: 28 / 18,
                fontWeight: FontWeight.bold,
                color: adminHeading,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pushNamed('/products'),
            child: const Text(
              'Xem tất cả',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: adminActive,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      if (items.isEmpty) const Text('Chưa có dữ liệu sản phẩm đang bán'),
      LayoutBuilder(
        builder: (context, c) {
          final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
          final columns = c.maxWidth >= 900 && scale <= 1.15
              ? 4
              : c.maxWidth >= 540
              ? 2
              : 1;
          final width = (c.maxWidth - 24 * (columns - 1)) / columns;
          return Wrap(
            spacing: 24,
            runSpacing: 24,
            children: [
              for (final item in items)
                SizedBox(width: width, child: _card(item)),
            ],
          );
        },
      ),
    ],
  );

  Widget _card(DashboardProductPreview item) => Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFF9FAFB)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Stack(
          children: [
            SizedBox(
              height: 220,
              width: double.infinity,
              child: item.imageAlias == null
                  ? ColoredBox(
                      color: const Color(0xFFE5E7EB),
                      child: Center(
                        child: adminAsset('imgContainer18', 30, 30),
                      ),
                    )
                  : P2Asset.node(
                      '2026:5862',
                      item.imageAlias!,
                      height: 220,
                      fit: BoxFit.cover,
                    ),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: item.badge == 'Mới'
                      ? const Color(0xFFDBEAFE)
                      : const Color(0xE6FFFFFF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.badge,
                  style: TextStyle(
                    fontSize: 10,
                    height: 1.5,
                    fontWeight: FontWeight.bold,
                    color: item.badge == 'Mới'
                        ? const Color(0xFF1E40AF)
                        : item.badge == 'Sắp hết'
                        ? const Color(0xFF9A3412)
                        : const Color(0xFF1A592E),
                  ),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                item.name,
                style: const TextStyle(
                  fontSize: 14,
                  height: 20 / 14,
                  fontWeight: FontWeight.bold,
                  color: adminHeading,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 12,
                runSpacing: 8,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      adminAsset('imgContainer17', 12, 12),
                      const SizedBox(width: 4),
                      Text(
                        item.priceLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: adminActive,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Kho: ${item.stock}',
                    style: const TextStyle(
                      fontSize: 10,
                      height: 1.5,
                      color: adminText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
