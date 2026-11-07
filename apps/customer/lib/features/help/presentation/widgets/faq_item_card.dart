import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

import '../../data/faq_source.dart';

class FaqItemCard extends StatelessWidget {
  const FaqItemCard({
    super.key,
    required this.item,
    required this.expanded,
    required this.onToggle,
  });
  final FaqItem item;
  final bool expanded;
  final VoidCallback onToggle;
  @override
  Widget build(BuildContext context) => Material(
    color: P2.rose,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(32),
      side: BorderSide(color: Colors.white.withValues(alpha: .05)),
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          toggled: expanded,
          child: InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.question,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.25,
                        fontWeight: FontWeight.w600,
                        color: P2.ink,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Transform.rotate(
                    angle: expanded ? 3.141592653589793 : 0,
                    child: P2Asset.node(
                      '2026:2669',
                      expanded ? 'imgContainer2' : 'imgContainer3',
                      width: 12,
                      height: 7.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (expanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 17),
            child: Text(
              item.answer?.trim().isNotEmpty == true
                  ? item.answer!
                  : 'Nội dung câu trả lời đang được cập nhật.',
              style: const TextStyle(
                fontSize: 14,
                height: 22.75 / 14,
                color: P2.ink,
              ),
            ),
          ),
      ],
    ),
  );
}
