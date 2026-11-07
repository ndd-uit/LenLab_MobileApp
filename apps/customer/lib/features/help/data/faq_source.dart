import 'package:lenlab_shared/lenlab_shared.dart';

enum FaqCategory { products, orders, payments, shipping }

class FaqItem {
  const FaqItem({
    required this.id,
    required this.category,
    required this.group,
    required this.question,
    this.answer,
  });
  final String id, group, question;
  final String? answer;
  final FaqCategory category;
}

abstract interface class FaqSource {
  Future<List<FaqItem>> load();
}

/// Approved P2 copy, not a complete or operational shop policy.
const mockFaqItems = <FaqItem>[
  FaqItem(
    id: 'pilling',
    category: FaqCategory.products,
    group: 'VỀ SẢN PHẨM',
    question: 'Len này có bị xù lông không?',
    answer: 'Sản phẩm của chúng tôi sử dụng dòng len Milk Cotton cao cấp đã qua xử lý. Tuy nhiên, với đặc tính tự nhiên của len, hiện tượng xù nhẹ có thể xảy ra sau thời gian dài sử dụng ma sát nhiều. Chúng tôi khuyên bạn nên giặt tay nhẹ nhàng để giữ độ bền tốt nhất.',
  ),
  FaqItem(
    id: 'washing',
    category: FaqCategory.products,
    group: 'VỀ SẢN PHẨM',
    question: 'Hướng dẫn giặt ủi sản phẩm?',
  ),
  FaqItem(
    id: 'shipping',
    category: FaqCategory.shipping,
    group: 'VẬN CHUYỂN & ĐƠN HÀNG',
    question: 'Thời gian giao hàng bao lâu?',
  ),
  FaqItem(
    id: 'sizing',
    category: FaqCategory.products,
    group: 'VẬN CHUYỂN & ĐƠN HÀNG',
    question: 'Làm sao để chọn đúng size?',
  ),
  FaqItem(
    id: 'returns',
    category: FaqCategory.orders,
    group: 'VẬN CHUYỂN & ĐƠN HÀNG',
    question: 'Chính sách đổi trả thế nào?',
  ),
];

class MockFaqSource implements FaqSource {
  MockFaqSource(this.repository);
  final LenlabRepository repository;
  @override
  Future<List<FaqItem>> load() async {
    if (repository case final MockLenlabRepository mock) {
      await mock.operation('faq');
    } else {
      throw const RepositoryException('Chưa cấu hình nguồn hỏi đáp.');
    }
    return mockFaqItems;
  }
}
