import 'package:flutter/material.dart';

import '../data/admin_chatbot_source.dart';
import 'widgets/chatbot_scenario.dart';
import 'widgets/conversation_styles.dart';

class AdminChatbotPage extends StatefulWidget {
  const AdminChatbotPage({super.key, this.source, this.onMenu});
  final AdminChatbotSource? source;
  final VoidCallback? onMenu;
  @override
  State<AdminChatbotPage> createState() => _AdminChatbotPageState();
}

class _AdminChatbotPageState extends State<AdminChatbotPage> {
  late AdminChatbotSource _source;
  late Future<AdminChatbotScenario?> _request;
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _source = widget.source ?? MockAdminChatbotSource();
    _request = _source.fetch();
  }

  @override
  void didUpdateWidget(covariant AdminChatbotPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source != widget.source) _load();
  }

  @override
  Widget build(BuildContext context) => SizedBox.expand(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (widget.onMenu != null)
                IconButton(
                  tooltip: 'Mở menu quản trị',
                  onPressed: widget.onMenu,
                  icon: const Icon(Icons.menu, color: conversationInk),
                ),
              const Expanded(
                child: Text(
                  'Kịch bản Chatbot',
                  style: TextStyle(
                    fontSize: 24,
                    height: 1.5,
                    fontWeight: FontWeight.bold,
                    color: conversationInk,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          conversationText(
            'Nội dung trả lời và điều hướng trước khi chuyển đến nhân viên.',
          ),
          const SizedBox(height: 24),
          FutureBuilder<AdminChatbotScenario?>(
            future: _request,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const SizedBox(
                  height: 400,
                  child: Center(
                    child: CircularProgressIndicator(
                      semanticsLabel: 'Đang tải kịch bản chatbot',
                    ),
                  ),
                );
              }
              if (snapshot.hasError) {
                return conversationCard(
                  child: Column(
                    children: [
                      conversationText('Không thể tải kịch bản chatbot'),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () => setState(() {
                          _request = _source.fetch();
                        }),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                );
              }
              final scenario = snapshot.data;
              if (scenario == null) {
                return conversationCard(
                  child: conversationText('Chưa có kịch bản chatbot'),
                );
              }
              return ChatbotScenario(scenario: scenario);
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Dữ liệu minh họa P2 • Chỉ đọc • Chưa kết nối chatbot',
            style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    ),
  );
}
