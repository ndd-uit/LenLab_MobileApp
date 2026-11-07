import 'package:lenlab_shared/lenlab_shared.dart';

class AboutContent {
  const AboutContent({
    required this.introduction,
    required this.vision,
    required this.mission,
    required this.milestones,
  });
  final String introduction, vision, mission;
  final List<({String year, String title, String description})> milestones;
}

const mockAboutContent = AboutContent(
  introduction: 'LENLAB là ngôi nhà của những sản phẩm len thủ công bền vững. Chúng tôi tin rằng mỗi mũi len là một câu chuyện về sự tỉ mỉ, kiên nhẫn và tình yêu thiên nhiên được gửi gắm đến bạn.',
  vision: 'Trở thành thương hiệu len thủ công hàng đầu Việt Nam, nơi lan tỏa lối sống chậm và trân trọng giá trị lao động nghệ thuật.',
  mission: 'Mang đến những sản phẩm len ấm áp, chất lượng cao, đồng thời tạo ra cộng đồng yêu thủ công và bảo vệ môi trường.',
  milestones: [
    (
      year: '2021',
      title: 'Khởi đầu khiêm tốn',
      description: 'LENLAB bắt đầu từ một căn phòng nhỏ với niềm đam mê đan móc của người sáng lập.',
    ),
    (
      year: '2022',
      title: 'Bộ sưu tập đầu tiên',
      description: 'Ra mắt bộ sưu tập "Thu Đông Ấm Áp" và nhận được sự ủng hộ nhiệt tình từ cộng đồng trẻ.',
    ),
    (
      year: '2025',
      title: 'Mở rộng & Bền vững',
      description: 'Chuyển đổi sang 100% len hữu cơ và mở rộng xưởng sản xuất tại Đà Lạt.',
    ),
  ],
);

abstract interface class AboutSource {
  Future<AboutContent?> load();
}

class MockAboutSource implements AboutSource {
  MockAboutSource(this.repository);
  final LenlabRepository repository;
  @override
  Future<AboutContent?> load() async {
    if (repository case final MockLenlabRepository mock) {
      await mock.operation('about');
    } else {
      throw const RepositoryException('Chưa cấu hình nguồn giới thiệu.');
    }
    return mockAboutContent;
  }
}
