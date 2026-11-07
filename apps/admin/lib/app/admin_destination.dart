enum AdminDestination {
  dashboard('/', 'Tổng quan'),
  appearance('/appearance', 'Giao diện'),
  products('/products', 'Sản phẩm'),
  reviews('/reviews', 'Đánh giá'),
  orders('/orders', 'Đơn hàng'),
  conversations('/conversations', 'Hội thoại'),
  chatbot('/conversations/chatbot', 'Kịch bản Chatbot'),
  customers('/customers', 'Khách hàng'),
  percentageCoupon('/vouchers/percentage', 'Mã giảm giá'),
  fixedCoupon('/vouchers/fixed', 'Mã giảm giá'),
  settings('/settings', 'Cấu hình chung'),
  notFound('/not-found', 'Không tìm thấy trang');

  const AdminDestination(this.path, this.title);
  final String path, title;
  static AdminDestination fromPath(String? path) =>
      values.firstWhere((item) => item.path == path, orElse: () => notFound);
}
