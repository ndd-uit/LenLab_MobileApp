import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';
import 'package:lenlab_customer/app/customer_scope.dart';
import 'package:lenlab_customer/shared/widgets/header_widgets.dart';

import '../data/faq_source.dart';
import 'widgets/faq_item_card.dart';
import 'widgets/faq_support_card.dart';
import '../../../app/customer_session_gate.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({super.key, this.source, this.orderId});
  final FaqSource? source;
  final String? orderId;
  @override
  Widget build(BuildContext context) => orderId == null
      ? _FaqContent(source: source)
      : CustomerSessionGate(
          route: '/support',
          arguments: orderId,
          builder: (context) =>
              CustomerScope.of(context).findOwnedOrder(orderId!) == null
              ? const Scaffold(
                  body: Center(child: EmptyPanel('Không tìm thấy đơn hàng')),
                )
              : _FaqContent(source: source, orderId: orderId),
        );
}

class _FaqContent extends StatefulWidget {
  const _FaqContent({this.source, this.orderId});
  final FaqSource? source;
  final String? orderId;
  @override
  State<_FaqContent> createState() => _FaqPageState();
}

class _FaqPageState extends State<_FaqContent> {
  FaqSource? source;
  Future<List<FaqItem>>? request;
  final search = TextEditingController();
  final expanded = <String>{'pilling'};
  FaqCategory? category;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    source ??=
        widget.source ?? MockFaqSource(CustomerScope.of(context).repository);
    request ??= source!.load();
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  void retry() => setState(() {
    request = source!.load();
  });
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      toolbarHeight: 64,
      automaticallyImplyLeading: false,
      leadingWidth: 72,
      leading: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 14),
        child: HeaderBackButton(),
      ),
      title: const Text(
        'Hỏi đáp Thường gặp',
        maxLines: 2,
        textAlign: TextAlign.center,
      ),
      actions: const [SizedBox(width: 72)],
    ),
    body: SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: search,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 16, color: P2.ink),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm câu hỏi...',
                hintStyle: const TextStyle(fontSize: 16, color: P2.ink),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                prefixIcon: SizedBox(
                  width: 48,
                  child: Center(
                    child: P2Asset.node(
                      '2026:2669',
                      'imgContainer1',
                      width: 16.5,
                      height: 16.5,
                    ),
                  ),
                ),
                fillColor: P2.rose,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32),
                  borderSide: const BorderSide(color: P2.brown),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final tab in <(String, FaqCategory?)>[
                    ('Tất cả', null),
                    ('Sản phẩm', FaqCategory.products),
                    ('Đơn hàng', FaqCategory.orders),
                    ('Thanh toán', FaqCategory.payments),
                    ('Vận chuyển', FaqCategory.shipping),
                  ])
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Semantics(
                        button: true,
                        selected: category == tab.$2,
                        child: InkWell(
                          onTap: () => setState(() {
                            category = tab.$2;
                          }),
                          borderRadius: BorderRadius.circular(24),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: category == tab.$2
                                    ? P2.rose
                                    : tab.$2 == FaqCategory.shipping
                                    ? const Color(0xFF221910)
                                    : P2.categoryButton,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    offset: Offset(0, 4),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                              child: Text(
                                tab.$1,
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 20 / 14,
                                  fontWeight: FontWeight.w500,
                                  color: category == tab.$2
                                      ? const Color(0xFF523A30)
                                      : const Color(0xFFD1D5DB),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FutureBuilder<List<FaqItem>>(
              future: request,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: CircularProgressIndicator(
                        semanticsLabel: 'Đang tải câu hỏi thường gặp',
                      ),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return EmptyPanel(
                    'Không thể tải câu hỏi',
                    action: P2Button('Thử lại', onPressed: retry),
                  );
                }
                final all = snapshot.data ?? [];
                final query = search.text.trim().toLowerCase();
                final items = all
                    .where(
                      (item) =>
                          (category == null || category == item.category) &&
                          item.question.toLowerCase().contains(query),
                    )
                    .toList();
                if (items.isEmpty) {
                  return EmptyPanel(
                    all.isEmpty
                        ? 'Chưa có câu hỏi thường gặp'
                        : 'Không tìm thấy câu hỏi phù hợp',
                    action: P2Button(
                      all.isEmpty ? 'Thử lại' : 'Xóa bộ lọc',
                      onPressed: all.isEmpty
                          ? retry
                          : () => setState(() {
                              search.clear();
                              category = null;
                            }),
                    ),
                  );
                }
                final groups = <String, List<FaqItem>>{};
                for (final item in items) {
                  (groups[item.group] ??= []).add(item);
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final group in groups.entries)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 4,
                                bottom: 12,
                              ),
                              child: Text(
                                group.key,
                                style: const TextStyle(
                                  fontSize: 12,
                                  height: 16 / 12,
                                  letterSpacing: .6,
                                  fontWeight: FontWeight.w600,
                                  color: P2.green,
                                ),
                              ),
                            ),
                            for (final item in group.value)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: FaqItemCard(
                                  key: ValueKey(item.id),
                                  item: item,
                                  expanded: expanded.contains(item.id),
                                  onToggle: () => setState(() {
                                    if (!expanded.remove(item.id)) {
                                      expanded.add(item.id);
                                    }
                                  }),
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            FaqSupportCard(orderId: widget.orderId),
          ],
        ),
      ),
    ),
  );
}
