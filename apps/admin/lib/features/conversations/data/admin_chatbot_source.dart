class AdminChatbotScenario {
  const AdminChatbotScenario({
    this.topic,
    this.requiredInformation,
    this.limitNotice,
    this.missingInformation,
    this.unableToAnswer,
    this.enabled,
  });
  final String? topic,
      requiredInformation,
      limitNotice,
      missingInformation,
      unableToAnswer;
  final bool? enabled;
}

abstract interface class AdminChatbotSource {
  Future<AdminChatbotScenario?> fetch();
}

class MockAdminChatbotSource implements AdminChatbotSource {
  MockAdminChatbotSource({
    this.latency = const Duration(milliseconds: 300),
    this.scenario = adminChatbotScenarioFixture,
  });
  final Duration latency;
  final AdminChatbotScenario? scenario;
  bool failNext = false;
  @override
  Future<AdminChatbotScenario?> fetch() async {
    await Future<void>.delayed(latency);
    if (failNext) {
      failNext = false;
      throw StateError('Mock chatbot scenario unavailable');
    }
    return scenario;
  }
}

const adminChatbotScenarioFixture = AdminChatbotScenario(
  topic: 'Ước tính số lượng len',
  requiredInformation: 'Loại sản phẩm, kích thước, trọng lượng mẫu thử, trọng lượng và chiều dài mỗi cuộn.',
  limitNotice:
      'Kết quả là ước tính; lượng len thay đổi theo mũi đan và lực tay.',
  missingInformation: 'Hỏi bổ sung từng thông số trước khi tính.',
  unableToAnswer: 'Mời khách gửi yêu cầu hỗ trợ cho nhân viên.',
  enabled: true,
);
