import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

import '../../../app/customer_scope.dart';
import '../../../shared/widgets/header_widgets.dart';
import '../data/comment_source.dart';
import 'widgets/comment_card.dart';

class CommentsPage extends StatefulWidget {
  const CommentsPage({super.key, required this.productId, this.source});
  final String productId;
  final CommentSource? source;
  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  CommentSource? source;
  Future<List<ProductComment>>? request;
  void load() {
    source =
        widget.source ??
        MockCommentSource(CustomerScope.of(context).repository);
    request = source!.load(widget.productId);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (request == null) load();
  }

  @override
  void didUpdateWidget(covariant CommentsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.productId != widget.productId ||
        oldWidget.source != widget.source) {
      load();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      toolbarHeight: 72,
      backgroundColor: const Color(0xFFDBBCAB),
      automaticallyImplyLeading: false,
      leadingWidth: 64,
      leading: const Padding(
        padding: EdgeInsets.only(left: 14, right: 6),
        child: HeaderBackButton(),
      ),
      title: const Text(
        'Bình luận',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: P2.ink,
        ),
      ),
      actions: const [SizedBox(width: 64)],
    ),
    body: FutureBuilder<List<ProductComment>>(
      future: request,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return SingleChildScrollView(
            child: EmptyPanel(
              'Không tải được bình luận',
              action: P2Button('Thử lại', onPressed: () => setState(load)),
            ),
          );
        }
        // Enforce isolation even when the source is replaced by an API adapter.
        final items = (snapshot.data ?? [])
            .where((c) => c.productId == widget.productId)
            .toList();
        if (items.isEmpty) {
          return const SingleChildScrollView(
            child: EmptyPanel('Chưa có bình luận cho sản phẩm này'),
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          children: [
            Text(
              '${items.length} bình luận',
              style: const TextStyle(
                fontSize: 14,
                height: 20 / 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF523A30),
              ),
            ),
            const SizedBox(height: 16),
            for (final c in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 25),
                child: CommentCard(key: ValueKey(c.id), comment: c),
              ),
          ],
        );
      },
    ),
    bottomNavigationBar: ColoredBox(
      color: const Color(0xFFDBBCAB),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => commentNotice(context),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(17, 15, 12, 15),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Thêm bình luận...',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF523A30),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          commentAsset('imgContainer', 16.667, 16.667),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                tooltip: 'Gửi bình luận (chưa hỗ trợ)',
                onPressed: () => commentNotice(context),
                style: IconButton.styleFrom(
                  backgroundColor: P2.productDetailButton,
                  fixedSize: const Size(46, 46),
                ),
                icon: commentAsset('imgContainer1', 17.417, 14.667),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
