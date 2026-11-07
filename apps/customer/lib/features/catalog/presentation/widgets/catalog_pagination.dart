import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

import '../catalog_styles.dart';

class CatalogPagination extends StatelessWidget {
  const CatalogPagination({
    super.key,
    required this.page,
    required this.count,
    required this.onChanged,
  });
  final int page, count;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 48),
    child: Wrap(
      alignment: WrapAlignment.center,
      spacing: 4,
      children: [
        IconButton(
          tooltip: 'Trang trước',
          onPressed: page > 0 ? () => onChanged(page - 1) : null,
          icon: P2Asset.node(
            catalogNode,
            'imgContainer8',
            width: 7.4,
            height: 12,
          ),
        ),
        for (int i = 0; i < count; i++)
          Semantics(
            selected: i == page,
            child: TextButton(
              onPressed: () => onChanged(i),
              style: TextButton.styleFrom(
                minimumSize: const Size(44, 44),
                padding: EdgeInsets.zero,
                backgroundColor: page == i ? P2.rose : Colors.white,
                foregroundColor: const Color(0xFF523A30),
                shape: const CircleBorder(),
              ),
              child: Text(
                '${i + 1}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        IconButton(
          tooltip: 'Trang sau',
          onPressed: page + 1 < count ? () => onChanged(page + 1) : null,
          icon: P2Asset.node(
            catalogNode,
            'imgContainer9',
            width: 7.4,
            height: 12,
          ),
        ),
      ],
    ),
  );
}
