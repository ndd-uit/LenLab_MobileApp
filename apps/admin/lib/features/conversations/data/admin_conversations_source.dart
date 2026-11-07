class AdminConversationMessage {
  const AdminConversationMessage({
    required this.text,
    required this.caption,
    this.fromAdmin = false,
  });
  final String text, caption;
  final bool fromAdmin;
}

class AdminConversation {
  AdminConversation({
    required this.id,
    required this.name,
    required this.preview,
    this.email,
    this.requestCode,
    this.unreadCount,
    this.supportLabel,
    List<AdminConversationMessage>? messages,
  }) : messages = messages == null ? null : List.unmodifiable(messages);
  final String id, name, preview;
  final String? email, requestCode, supportLabel;
  final int? unreadCount;
  // null means history is unknown; an empty list means no messages.
  final List<AdminConversationMessage>? messages;
  bool matches(String query) {
    final value = query.trim().toLowerCase();
    return value.isEmpty ||
        [name, email, requestCode].whereType<String>().any(
          (field) => field.toLowerCase().contains(value),
        );
  }
}

abstract interface class AdminConversationsSource {
  Future<List<AdminConversation>> fetch();
}

class MockAdminConversationsSource implements AdminConversationsSource {
  MockAdminConversationsSource({
    this.latency = const Duration(milliseconds: 300),
    List<AdminConversation>? conversations,
  }) : conversations = List.unmodifiable(
         conversations ?? adminConversationFixtures,
       );
  final Duration latency;
  final List<AdminConversation> conversations;
  bool failNext = false;
  @override
  Future<List<AdminConversation>> fetch() async {
    await Future<void>.delayed(latency);
    if (failNext) {
      failNext = false;
      throw StateError('Mock conversations unavailable');
    }
    return conversations;
  }
}

final adminConversationFixtures = List<AdminConversation>.unmodifiable([
  AdminConversation(
    id: 'P2-CHAT-001',
    name: 'Nguyễn Văn A',
    preview: 'Hỏi về yêu cầu #CUS-202501',
    requestCode: 'CUS-202501',
    unreadCount: 2,
    supportLabel: 'Đang được nhân viên hỗ trợ · Yêu cầu #CUS-202501',
    messages: const [
      AdminConversationMessage(
        text: 'Mình muốn hỏi báo giá 550.000đ đã gồm phí vận chuyển chưa?',
        caption: 'Khách hàng · 10:23',
      ),
      AdminConversationMessage(
        text: 'Chào bạn, báo giá gồm nguyên liệu và công đan. Phí vận chuyển sẽ được xác nhận riêng theo địa chỉ nhận hàng.',
        caption: 'LENLAB · 10:25 · Đã gửi',
        fromAdmin: true,
      ),
    ],
  ),
  AdminConversation(
    id: 'P2-CHAT-002',
    name: 'Trần Thị Bích',
    preview: 'Cần hỗ trợ chọn màu len',
  ),
  AdminConversation(
    id: 'P2-CHAT-003',
    name: 'Lê Hoàng Cường',
    preview: 'Tôi muốn hỏi ngày giao hàng',
  ),
]);
