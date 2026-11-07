import 'admin_order_summary.dart';

class AdminOrderLine {
  const AdminOrderLine({
    required this.sku,
    required this.name,
    required this.variant,
    required this.quantity,
    required this.unitPrice,
    this.imageAlias,
  });
  final String sku, name, variant;
  final int quantity, unitPrice;
  final String? imageAlias;
  int get total => quantity * unitPrice;
}

class AdminOrderDetail {
  AdminOrderDetail({
    required this.summary,
    List<AdminOrderLine> lines = const [],
    this.email,
    this.address,
    this.shipping,
    this.discount,
  }) : lines = List.unmodifiable(lines);
  final AdminOrderSummary summary;
  final List<AdminOrderLine> lines;
  final String? email, address;
  final int? shipping, discount;
  int? get subtotal => lines.isEmpty
      ? null
      : lines.fold<int>(0, (sum, line) => sum + line.total);
}

/// Supplement keyed by the exact list ID. Missing fields stay missing.
AdminOrderDetail mockAdminOrderDetail(AdminOrderSummary summary) =>
    summary.id == 'ORD-202502'
    ? AdminOrderDetail(
        summary: summary,
        email: 'tranthib@example.com',
        address: 'Số 15, Ngõ 123 đường Xuân Thủy, Cầu Giấy, Hà Nội',
        shipping: 30000,
        discount: 0,
        lines: const [
          AdminOrderLine(
            sku: 'MC125-05',
            name: 'Len Milk Cotton 125g',
            variant: 'Màu: #05 Vàng nhạt',
            quantity: 5,
            unitPrice: 40000,
            imageAlias: 'imgLenMilkCotton',
          ),
          AdminOrderLine(
            sku: 'TULIP-25',
            name: 'Kim móc cán dẻo Tulip',
            variant: 'Size: 2.5mm',
            quantity: 1,
            unitPrice: 270000,
            imageAlias: 'imgKimMoc',
          ),
        ],
      )
    : AdminOrderDetail(summary: summary);
