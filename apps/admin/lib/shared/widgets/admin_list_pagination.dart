import 'package:flutter/material.dart';

import 'admin_list_styles.dart';

class AdminListPagination extends StatelessWidget {
  const AdminListPagination({
    super.key,
    required this.summary,
    required this.page,
    required this.pages,
    required this.onPage,
    required this.accent,
    required this.previousIcon,
    required this.nextIcon,
  });
  final String summary;
  final int page, pages;
  final ValueChanged<int> onPage;
  final Color accent;
  final Widget previousIcon, nextIcon;

  List<int> get _visiblePages {
    if (pages <= 7) {
      return List.generate(pages, (index) => index + 1);
    }
    return {
      1,
      pages,
      if (page <= 2) 3,
      for (var candidate = page - 1; candidate <= page + 1; candidate++)
        if (candidate >= 1 && candidate <= pages) candidate,
    }.toList()..sort();
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    decoration: const BoxDecoration(
      border: Border(top: BorderSide(color: adminListBorder)),
    ),
    child: Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 12,
      children: [
        Text(
          summary,
          style: const TextStyle(fontSize: 14, color: adminListMuted),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _button(
              'Trang trước',
              page > 1 ? () => onPage(page - 1) : null,
              previousIcon,
            ),
            for (var index = 0; index < _visiblePages.length; index++) ...[
              if (index > 0 &&
                  _visiblePages[index] > _visiblePages[index - 1] + 1)
                const Padding(padding: EdgeInsets.all(8), child: Text('…')),
              _button(
                'Trang ${_visiblePages[index]}',
                _visiblePages[index] == page
                    ? null
                    : () => onPage(_visiblePages[index]),
                Text('${_visiblePages[index]}'),
                selected: _visiblePages[index] == page,
              ),
            ],
            _button(
              'Trang sau',
              page < pages ? () => onPage(page + 1) : null,
              nextIcon,
            ),
          ],
        ),
      ],
    ),
  );

  Widget _button(
    String label,
    VoidCallback? onPressed,
    Widget child, {
    bool selected = false,
  }) => Semantics(
    selected: selected,
    child: Tooltip(
      message: label,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(34, 34),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          backgroundColor: selected ? accent : Colors.white,
          disabledBackgroundColor: selected ? accent : Colors.white,
          foregroundColor: const Color(0xFF4B5563),
          disabledForegroundColor: const Color(0xFF523A30),
          side: BorderSide(color: selected ? accent : adminListBorder),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: child,
      ),
    ),
  );
}
