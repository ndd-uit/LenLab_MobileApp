enum AdminOrderStatus {
  pending('Chờ duyệt'),
  shipping('Đang giao'),
  delivered('Đã giao'),
  cancelled('Đã hủy');

  const AdminOrderStatus(this.label);
  final String label;
}

enum AdminOrderPayment {
  cod('COD'),
  bankTransfer('CK');

  const AdminOrderPayment(this.label);
  final String label;
}

class AdminOrderSummary {
  const AdminOrderSummary({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.placedAt,
    required this.total,
    required this.payment,
    required this.status,
    this.note,
  });
  final String id, customerName, phone;
  final DateTime? placedAt;
  final int total;
  final AdminOrderPayment payment;
  final AdminOrderStatus status;
  final String? note;
}
