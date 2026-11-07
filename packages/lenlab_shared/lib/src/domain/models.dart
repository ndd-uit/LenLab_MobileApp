import 'dart:typed_data';

enum CheckoutPaymentMethod { cod, bankTransfer }

String money(num value) {
  final digits = value.round().toString();
  return '${digits.replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ';
}

class Product {
  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.category,
    this.sku = '',
    this.stock = 45,
    this.published = true,
    this.oldPrice,
    this.description = '',
    this.detail = '',
    this.rating = 4.9,
  });

  /// Detached display/pricing snapshot; catalog changes must be reviewed.
  Product.snapshot(Product product)
    : this(
        id: product.id,
        name: product.name,
        price: product.price,
        image: product.image,
        category: product.category,
        sku: product.sku,
        stock: product.stock,
        published: product.published,
        oldPrice: product.oldPrice,
        description: product.description,
        detail: product.detail,
        rating: product.rating,
      );
  final String id;
  String name;
  int price;
  final String image;
  String category, sku;
  int stock;
  bool published;
  int? oldPrice;
  String description, detail;

  /// Legacy metadata retained for snapshot compatibility. Customer rating UI
  /// derives its score from LenlabStore.reviewsFor instead.
  double rating;
}

class CartLine {
  CartLine(Product product, {this.quantity = 1, this.variant = 'Kem · 180cm'})
    : product = Product.snapshot(product);
  final Product product;
  int quantity;
  final String variant;
  int get total => product.price * quantity;
  String get key => '${product.id}:$variant';
}

class Address {
  const Address({
    this.ownerId,
    this.name = 'Nguyễn Văn A',
    this.phone = '0901234567',
    this.city = 'TP. Hồ Chí Minh',
    this.district = 'Quận 1',
    this.ward = 'Phường Bến Nghé',
    this.street = '123 Đường Nguyễn Huệ',
    this.isDefault = true,
  });
  final String name, phone, city, district, ward, street;
  final String? ownerId;
  final bool isDefault;
  Address ownedBy(String owner) => ownerId == owner
      ? this
      : Address(
          ownerId: owner,
          name: name,
          phone: phone,
          city: city,
          district: district,
          ward: ward,
          street: street,
          isDefault: isDefault,
        );
  String get full => '$street, $ward, $district, $city';
}

enum PaymentState { cod, pending, pendingConfirmation, confirmed, failed }

enum OrderState { pending, processing, shipping, delivered, cancelled }

enum QuoteState { waiting, quoted, accepted, rejected }

String orderLabel(OrderState state) => switch (state) {
  OrderState.pending => 'Chờ xác nhận',
  OrderState.processing => 'Đang xử lý',
  OrderState.shipping => 'Đang giao hàng',
  OrderState.delivered => 'Đã giao thành công',
  OrderState.cancelled => 'Đã hủy',
};
String paymentLabel(PaymentState state) => switch (state) {
  PaymentState.cod => 'Thanh toán khi nhận hàng (COD)',
  PaymentState.pending => 'Chờ thanh toán',
  PaymentState.pendingConfirmation => 'Chờ xác nhận thanh toán',
  PaymentState.confirmed => 'Đã xác nhận thanh toán',
  PaymentState.failed => 'Thanh toán chưa thành công',
};
String quoteLabel(QuoteState state) => switch (state) {
  QuoteState.waiting => 'Chờ báo giá',
  QuoteState.quoted => 'Đã báo giá',
  QuoteState.accepted => 'Đã chốt',
  QuoteState.rejected => 'Đã từ chối',
};

class Order {
  Order({
    this.ownerId,
    required this.id,
    required this.lines,
    required this.address,
    this.state = OrderState.pending,
    this.payment = PaymentState.cod,
    this.shipping = 30000,
    this.discount = 0,
    this.note = '',
    this.deliveryEstimate,
    this.createdAt,
  });
  final String id;
  final String? ownerId;
  final List<CartLine> lines;
  final String? deliveryEstimate;
  final DateTime? createdAt;
  final Address address;
  OrderState state;
  PaymentState payment;
  int shipping, discount;
  String note;
  int get subtotal => lines.fold(0, (a, b) => a + b.total);
  int get total => subtotal + shipping - discount;
}

class CustomRequest {
  CustomRequest(
    this.id,
    this.title,
    this.image, {
    this.ownerId,
    this.state = QuoteState.waiting,
    this.price = 550000,
    this.description = 'Size M · Màu navy · Len cotton milk, thêm nơ ở cổ áo. Mong muốn nhận trước ngày 10/06.',
  });
  final String id, title, image;
  final String? ownerId;
  QuoteState state;
  int price;
  String description;
  String internalNote = '';
}

class CustomerProfile {
  CustomerProfile({
    this.ownerId,
    this.name = 'Nguyễn Văn A',
    this.email = 'nguyenvan.a@example.com',
    this.phone = '0901234567',
    this.gender = 'Nam',
    this.birthday = '01/01/1995',
  });
  final String? ownerId;
  String? avatar;
  Uint8List? avatarBytes;
  String name, email, phone, gender, birthday;
}
