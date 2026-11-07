import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

import '../../data/comment_source.dart';
import '../../../reviews/presentation/review_styles.dart';

Widget commentAsset(String alias, double width, double height) =>
    P2Asset.node('2026:120', alias, width: width, height: height);

void commentNotice(BuildContext context) => reviewNotice(
  context,
  'Bình luận đang ở chế độ xem mock. Chưa hỗ trợ gửi, trả lời, đính kèm ảnh hoặc cập nhật lượt hữu ích.',
);

class CommentCard extends StatelessWidget {
  const CommentCard({super.key, required this.comment});
  final ProductComment comment;
  @override
  Widget build(BuildContext context) {
    final c = comment;
    final colors = switch (c.initials) {
      'MA' => [const Color(0xFF60A5FA), const Color(0xFFA855F7)],
      'HP' => [const Color(0xFFFB923C), const Color(0xFFEC4899)],
      'LM' => [P2.productDetailButton, P2.productDetailButton],
      _ => [const Color(0xFF4ADE80), const Color(0xFF14B8A6)],
    };
    final size = c.shop ? 32.0 : 40.0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(
          child: ClipOval(
            child: c.avatar != null
                ? commentAsset(c.avatar!, size, size)
                : Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: colors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      c.initials,
                      style: TextStyle(
                        color: const Color(0xFF332620),
                        fontSize: c.shop ? 12 : 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),
        ),
        SizedBox(width: c.shop ? 12 : 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  spacing: 8,
                  runSpacing: 2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Wrap(
                      spacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          c.name,
                          style: TextStyle(
                            fontSize: 14,
                            height: 20 / 14,
                            fontWeight: FontWeight.bold,
                            color: c.shop ? P2.ink : P2.brown,
                          ),
                        ),
                        if (c.shop)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: P2.productDetailButton.withValues(
                                alpha: .2,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Shop',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: P2.ink,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Text(
                      c.timeLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 16 / 12,
                        color: Color(0xFF523A30),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                c.text,
                textAlign: c.shop || c.initials == 'MA'
                    ? TextAlign.justify
                    : TextAlign.start,
                style: const TextStyle(
                  fontSize: 14,
                  height: 22.75 / 14,
                  color: Colors.black,
                ),
              ),
              if (c.photo != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: commentAsset(c.photo!, 112, 112),
                  ),
                ),
              Wrap(
                spacing: 20,
                children: [
                  Semantics(
                    button: true,
                    label: 'Hữu ích, dữ liệu minh họa',
                    child: InkWell(
                      onTap: () => commentNotice(context),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight: 44,
                          minWidth: 44,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            commentAsset(
                              c.highlighted ? 'imgContainer4' : 'imgContainer3',
                              15,
                              13.762,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              c.helpful?.toString() ?? 'Hữu ích',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF523A30),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => commentNotice(context),
                    child: const SizedBox(
                      height: 44,
                      child: Center(
                        widthFactor: 1,
                        child: Text(
                          'Trả lời',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF523A30),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (c.reply != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Container(
                    padding: const EdgeInsets.only(left: 14),
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: Colors.white.withValues(alpha: .1),
                          width: 2,
                        ),
                      ),
                    ),
                    child: CommentCard(comment: c.reply!),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
