import 'package:flutter/material.dart';

import '../../data/admin_conversations_source.dart';
import 'conversation_styles.dart';

class ConversationsList extends StatelessWidget {
  const ConversationsList({
    super.key,
    required this.items,
    required this.selectedId,
    required this.onSelect,
    required this.search,
    required this.onSearch,
  });
  final List<AdminConversation> items;
  final String? selectedId;
  final ValueChanged<String> onSelect, onSearch;
  final TextEditingController search;
  @override
  Widget build(BuildContext context) => conversationCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: const ValueKey('conversation-search'),
          controller: search,
          onChanged: onSearch,
          style: const TextStyle(
            fontSize: 13,
            height: 20 / 13,
            color: conversationInk,
          ),
          decoration: InputDecoration(
            filled: false,
            hintText: 'Tìm tên, email, mã yêu cầu…',
            hintStyle: const TextStyle(color: conversationInk),
            isDense: true,
            contentPadding: EdgeInsets.zero,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: conversationInk),
            ),
            suffixIcon: search.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Xóa tìm kiếm hội thoại',
                    onPressed: () {
                      search.clear();
                      onSearch('');
                    },
                    icon: const Icon(
                      Icons.close,
                      size: 18,
                      color: conversationInk,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        if (items.isEmpty)
          conversationText('Không có hội thoại phù hợp', size: 13),
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(height: 16),
          Semantics(
            selected: items[i].id == selectedId,
            button: true,
            child: Material(
              color: items[i].id == selectedId
                  ? conversationSelected
                  : const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                key: ValueKey('conversation-${items[i].id}'),
                borderRadius: BorderRadius.circular(12),
                onTap: () => onSelect(items[i].id),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      conversationText(
                        '${items[i].name}${(items[i].unreadCount ?? 0) > 0 ? ' · ${items[i].unreadCount} tin mới' : ''}',
                        bold: true,
                      ),
                      const SizedBox(height: 8),
                      conversationText(items[i].preview, size: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    ),
  );
}
