import 'package:flutter/material.dart';

import '../../data/admin_chatbot_source.dart';
import 'conversation_styles.dart';

class ChatbotScenario extends StatelessWidget {
  const ChatbotScenario({super.key, required this.scenario});
  final AdminChatbotScenario scenario;
  @override
  Widget build(BuildContext context) {
    final fields = [
      ('Chủ đề', scenario.topic),
      ('Thông tin cần thu thập', scenario.requiredInformation),
      ('Thông báo giới hạn', scenario.limitNotice),
      ('Khi thiếu thông tin', scenario.missingInformation),
      ('Khi không thể trả lời', scenario.unableToAnswer),
      (
        'Trạng thái',
        scenario.enabled == null
            ? null
            : scenario.enabled!
            ? 'Đang bật'
            : 'Đang tắt',
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        conversationCard(
          padding: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < fields.length; i++) ...[
                if (i > 0) const SizedBox(height: 20),
                conversationText(
                  fields[i].$1,
                  size: 13,
                  height: 20 / 13,
                  bold: true,
                ),
                const SizedBox(height: 6),
                Container(
                  key: ValueKey('chatbot-field-$i'),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F5F0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: conversationText(
                    fields[i].$2?.trim().isNotEmpty == true
                        ? fields[i].$2!
                        : 'Chưa có dữ liệu',
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: 220,
            child: conversationDisabledAction(
              'Lưu kịch bản',
              key: const ValueKey('chatbot-save'),
            ),
          ),
        ),
      ],
    );
  }
}
