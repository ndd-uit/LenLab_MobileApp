import 'package:flutter/material.dart';

import '../../data/admin_conversations_source.dart';
import 'conversation_styles.dart';

class SelectedConversation extends StatelessWidget {
  const SelectedConversation({super.key, required this.conversation});
  final AdminConversation? conversation;
  @override
  Widget build(BuildContext context) {
    final item = conversation;
    return conversationCard(
      padding: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: item == null
            ? [conversationText('Chưa có hội thoại được chọn')]
            : [
                Text(
                  item.name,
                  key: const ValueKey('conversation-selected-name'),
                  style: const TextStyle(
                    fontSize: 18,
                    height: 1.5,
                    fontWeight: FontWeight.bold,
                    color: conversationInk,
                  ),
                ),
                const SizedBox(height: 20),
                conversationText(
                  item.supportLabel ?? 'Chưa có dữ liệu trạng thái hỗ trợ',
                  size: 13,
                  height: 20 / 13,
                ),
                const SizedBox(height: 20),
                if (item.messages == null)
                  conversationText(
                    'Chưa có dữ liệu nội dung hội thoại',
                    size: 14,
                  )
                else if (item.messages!.isEmpty)
                  conversationText('Hội thoại chưa có tin nhắn', size: 14)
                else
                  for (final message in item.messages!) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: message.fromAdmin
                            ? const Color(0xFFF2E0CC)
                            : const Color(0xFFF7F0E5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          conversationText(message.text),
                          const SizedBox(height: 8),
                          conversationText(
                            message.caption,
                            size: 11,
                            height: 17 / 11,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                if (item.messages == null || item.messages!.isEmpty)
                  const SizedBox(height: 20),
                Tooltip(
                  message: 'Phản hồi chưa khả dụng, đây là màn chỉ đọc',
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFDBBAA8)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const TextField(
                          key: ValueKey('conversation-reply'),
                          enabled: false,
                          minLines: 1,
                          maxLines: null,
                          style: TextStyle(
                            fontSize: 14,
                            color: conversationInk,
                          ),
                          decoration: InputDecoration(
                            filled: false,
                            hintText: 'Nhập phản hồi cho khách hàng…',
                            hintStyle: TextStyle(color: conversationInk),
                            border: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: 180,
                            child: conversationDisabledAction(
                              'Gửi phản hồi',
                              key: const ValueKey('conversation-send'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                conversationDisabledAction(
                  'Đánh dấu đã xử lý',
                  key: const ValueKey('conversation-resolve'),
                ),
              ],
      ),
    );
  }
}
