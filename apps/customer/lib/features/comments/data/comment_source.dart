import 'package:lenlab_shared/lenlab_shared.dart';

/// Relative labels and helpful counts are fixed P2 samples, not live activity.
class ProductComment {
  const ProductComment({
    required this.id,
    required this.productId,
    required this.name,
    required this.initials,
    required this.timeLabel,
    required this.text,
    this.helpful,
    this.highlighted = false,
    this.avatar,
    this.photo,
    this.reply,
    this.shop = false,
  });
  final String id, productId, name, initials, timeLabel, text;
  final int? helpful;
  final bool highlighted, shop;
  final String? avatar, photo;
  final ProductComment? reply;
}

const mockProductComments = [
  ProductComment(
    id: 'merino-minh-anh',
    productId: 'merino',
    name: 'Minh Anh',
    initials: 'MA',
    timeLabel: '2 giờ trước',
    helpful: 24,
    photo: 'imgImageBorder',
    text: 'Khăn len rất mềm và ấm, màu sắc đúng như hình mô tả. Mình rất thích cách shop đóng gói, thân thiện với môi trường! 😍',
  ),
  ProductComment(
    id: 'merino-hoang-phuc',
    productId: 'merino',
    name: 'Hoàng Phúc',
    initials: 'HP',
    timeLabel: '5 giờ trước',
    text: 'Len này đan kim số mấy thì vừa vậy shop ơi? Mình mới tập đan nên chưa rành lắm.',
    reply: ProductComment(
      id: 'merino-shop',
      productId: 'merino',
      name: 'Len Merino',
      initials: 'LM',
      timeLabel: '1 giờ trước',
      helpful: 2,
      shop: true,
      text: 'Chào bạn, dòng len Merino này phù hợp nhất với kim đan size 4mm - 5mm bạn nhé! Nếu đan lỏng tay bạn có thể dùng kim 4mm ạ.',
    ),
  ),
  ProductComment(
    id: 'merino-thu-ha',
    productId: 'merino',
    name: 'Thu Hà',
    initials: 'TH',
    timeLabel: '1 ngày trước',
    helpful: 128,
    highlighted: true,
    avatar: 'imgImage',
    text: 'Tuyệt vời! Mua tặng mẹ mà mẹ khen mãi. Len Merino này sờ vào mát tay mà lại rất ấm. Rất đáng tiền.',
  ),
  ProductComment(
    id: 'merino-tuan',
    productId: 'merino',
    name: 'Tuấn',
    initials: 'T',
    timeLabel: '2 ngày trước',
    helpful: 1,
    text: 'Sản phẩm ổn, nhưng màu sắc thực tế hơi tối hơn so với ảnh chụp studio.',
  ),
];

abstract interface class CommentSource {
  Future<List<ProductComment>> load(String productId);
}

class MockCommentSource implements CommentSource {
  MockCommentSource(this.repository);
  final LenlabRepository repository;
  @override
  Future<List<ProductComment>> load(String productId) async {
    if (repository case final MockLenlabRepository mock) {
      await mock.operation('comments');
    } else {
      throw const RepositoryException('Chưa cấu hình nguồn bình luận.');
    }
    return List.unmodifiable(
      mockProductComments.where((c) => c.productId == productId),
    );
  }
}
