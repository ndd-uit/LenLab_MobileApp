import 'package:flutter/material.dart';

import '../../../../shared/widgets/admin_list_styles.dart';
import 'review_card.dart';

class ReviewsHeader extends StatelessWidget {
  const ReviewsHeader({
    super.key,
    required this.search,
    required this.onSearch,
    required this.stars,
    required this.onStars,
    this.onMenu,
  });
  final TextEditingController search;
  final ValueChanged<String> onSearch;
  final int? stars;
  final ValueChanged<int?> onStars;
  final VoidCallback? onMenu;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(bottom: BorderSide(color: adminListBorder)),
    ),
    child: LayoutBuilder(
      builder: (context, c) {
        final title = Row(
          children: [
            if (onMenu != null)
              IconButton(
                tooltip: 'Mở menu quản trị',
                onPressed: onMenu,
                icon: const Icon(Icons.menu, color: adminListInk),
              ),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Đánh giá sản phẩm',
                    style: TextStyle(
                      fontSize: 24,
                      height: 32 / 24,
                      fontWeight: FontWeight.bold,
                      color: adminListInk,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Quản lý phản hồi và đánh giá từ khách hàng.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 20 / 14,
                      color: adminListMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
        final input = TextField(
          key: const ValueKey('reviews-search'),
          controller: search,
          onChanged: onSearch,
          style: const TextStyle(fontSize: 14, color: adminListInk),
          decoration: InputDecoration(
            hintText: 'Tìm tên, sản phẩm...',
            hintStyle: const TextStyle(color: adminListMuted, fontSize: 14),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            prefixIcon: Center(
              widthFactor: 1,
              heightFactor: 1,
              child: reviewAsset('imgContainer8', 13.5, 13.5),
            ),
            suffixIcon: search.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Xóa tìm kiếm',
                    onPressed: () {
                      search.clear();
                      onSearch('');
                    },
                    icon: const Icon(Icons.close, size: 16),
                  ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
          ),
        );
        final filter = PopupMenuButton<int>(
          key: const ValueKey('reviews-stars'),
          tooltip: 'Lọc theo sao',
          initialValue: stars ?? 0,
          onSelected: (value) => onStars(value == 0 ? null : value),
          itemBuilder: (_) => [
            for (var value = 0; value <= 5; value++)
              PopupMenuItem(
                value: value,
                child: Text(value == 0 ? 'Tất cả số sao' : '$value sao'),
              ),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD1D5DB)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                reviewAsset('imgContainer9', 13.5, 9),
                const SizedBox(width: 8),
                Text(
                  stars == null ? 'Lọc theo sao' : '$stars sao',
                  style: const TextStyle(fontSize: 14, color: adminListInk),
                ),
              ],
            ),
          ),
        );
        final controls = Wrap(
          spacing: 16,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(width: c.maxWidth < 300 ? c.maxWidth : 264, child: input),
            filter,
          ],
        );
        return c.maxWidth >= 930 &&
                MediaQuery.textScalerOf(context).scale(14) <= 16
            ? Row(
                children: [
                  Expanded(child: title),
                  const SizedBox(width: 16),
                  controls,
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [title, const SizedBox(height: 16), controls],
              );
      },
    ),
  );
}
