import 'package:flutter/material.dart';

import '../../data/admin_order_summary.dart';

class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({super.key, required this.status});
  final AdminOrderStatus status;
  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (status) {
      AdminOrderStatus.pending => (
        const Color(0xFFFEF9C3),
        const Color(0xFF854D0E),
      ),
      AdminOrderStatus.shipping => (
        const Color(0xFFDBEAFE),
        const Color(0xFF1E40AF),
      ),
      AdminOrderStatus.delivered => (
        const Color(0xFFDCFCE7),
        const Color(0xFF166534),
      ),
      AdminOrderStatus.cancelled => (
        const Color(0xFFFEE2E2),
        const Color(0xFF991B1B),
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 12,
          height: 16 / 12,
          fontWeight: FontWeight.w500,
          color: foreground,
        ),
      ),
    );
  }
}
