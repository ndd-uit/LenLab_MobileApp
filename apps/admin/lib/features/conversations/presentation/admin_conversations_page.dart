import 'package:flutter/material.dart';

import '../data/admin_conversations_source.dart';
import 'widgets/conversation_styles.dart';
import 'widgets/conversations_list.dart';
import 'widgets/selected_conversation.dart';

class AdminConversationsPage extends StatefulWidget {
  const AdminConversationsPage({super.key, this.source, this.onMenu});
  final AdminConversationsSource? source;
  final VoidCallback? onMenu;
  @override
  State<AdminConversationsPage> createState() => _AdminConversationsPageState();
}

class _AdminConversationsPageState extends State<AdminConversationsPage> {
  late AdminConversationsSource _source;
  late Future<List<AdminConversation>> _request;
  final _search = TextEditingController();
  String? _selectedId;
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _source = widget.source ?? MockAdminConversationsSource();
    _request = _source.fetch();
    _selectedId = null;
  }

  @override
  void didUpdateWidget(covariant AdminConversationsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source != widget.source) _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
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
                  'Hội thoại khách hàng',
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
          FutureBuilder<List<AdminConversation>>(
            future: _request,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const SizedBox(
                  height: 400,
                  child: Center(
                    child: CircularProgressIndicator(
                      semanticsLabel: 'Đang tải hội thoại',
                    ),
                  ),
                );
              }
              if (snapshot.hasError) {
                return conversationCard(
                  child: Column(
                    children: [
                      conversationText('Không thể tải hội thoại'),
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
              final all = snapshot.data ?? const <AdminConversation>[];
              if (all.isEmpty) {
                return conversationCard(
                  child: conversationText('Chưa có hội thoại'),
                );
              }
              final items = all
                  .where((item) => item.matches(_search.text))
                  .toList(growable: false);
              final selected =
                  items.where((item) => item.id == _selectedId).firstOrNull ??
                  items.firstOrNull;
              final list = ConversationsList(
                items: items,
                selectedId: selected?.id,
                search: _search,
                onSearch: (_) => setState(() {
                  _selectedId = null;
                }),
                onSelect: (id) => setState(() {
                  _selectedId = id;
                }),
              );
              final detail = SelectedConversation(conversation: selected);
              return LayoutBuilder(
                builder: (context, c) =>
                    c.maxWidth >= 900 &&
                        MediaQuery.textScalerOf(context).scale(14) <= 16
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: 280, child: list),
                          const SizedBox(width: 24),
                          Expanded(child: detail),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [list, const SizedBox(height: 24), detail],
                      ),
              );
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Dữ liệu minh họa P2 • Chỉ đọc • Chưa kết nối dịch vụ nhắn tin',
            style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    ),
  );
}
