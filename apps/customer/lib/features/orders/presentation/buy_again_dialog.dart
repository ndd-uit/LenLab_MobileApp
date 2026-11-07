import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

import '../../../app/customer_scope.dart';
import '../../../app/navigation.dart';
import '../../../app/session_bound_overlay.dart';
import '../data/buy_again_source.dart';

Future<void> openBuyAgain(
  BuildContext context,
  Order order, {
  BuyAgainSource? source,
}) async {
  final store = CustomerScope.of(context);
  final actor = store.captureSession();
  if (!store.ownsOrder(order)) return;
  if (order.state != OrderState.delivered) return;
  final resolvedSource =
      source ?? CatalogBuyAgainSource(store.repository, session: store);
  final product = await showDialog<Product>(
    context: context,
    builder: (_) => SessionBoundOverlay(
      session: actor,
      builder: (_) => _BuyAgainDialog(
        order: order,
        source: resolvedSource,
        store: store,
        session: actor,
      ),
    ),
  );
  if (!context.mounted ||
      !store.isCurrentSession(actor) ||
      product == null ||
      order.state != OrderState.delivered) {
    return;
  }
  go(context, '/product', product);
}

class _BuyAgainDialog extends StatefulWidget {
  const _BuyAgainDialog({
    required this.order,
    required this.source,
    required this.store,
    required this.session,
  });
  final Order order;
  final BuyAgainSource source;
  final LenlabStore store;
  final CustomerSessionStamp session;
  @override
  State<_BuyAgainDialog> createState() => _BuyAgainDialogState();
}

class _BuyAgainDialogState extends State<_BuyAgainDialog> {
  late Future<List<BuyAgainChoice>> request;
  @override
  void initState() {
    super.initState();
    request = load();
  }

  Future<List<BuyAgainChoice>> load() async {
    final choices = await widget.source.load(widget.order);
    if (mounted &&
        widget.store.isCurrentSession(widget.session) &&
        ModalRoute.of(context)?.isCurrent == true &&
        choices.length == 1 &&
        choices.single.product != null) {
      Navigator.pop(context, choices.single.product);
    }
    return choices;
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: P2.cream,
    title: const Text('Mua lại', style: TextStyle(color: P2.brown)),
    scrollable: true,
    content: FutureBuilder<List<BuyAgainChoice>>(
      future: request,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(
                semanticsLabel: 'Đang kiểm tra sản phẩm',
              ),
            ),
          );
        }
        if (snapshot.hasError) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Không thể tải sản phẩm để mua lại.'),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => setState(() {
                  request = load();
                }),
                child: const Text('Thử lại'),
              ),
            ],
          );
        }
        final choices = snapshot.data!;
        if (choices.isEmpty) {
          return const Text('Đơn hàng chưa có thông tin sản phẩm để mua lại.');
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chọn sản phẩm để xem giá hiện tại và chọn lại phân loại, số lượng.',
            ),
            const SizedBox(height: 12),
            for (final choice in choices)
              ListTile(
                contentPadding: EdgeInsets.zero,
                enabled: choice.product != null,
                title: Text(choice.name),
                subtitle: Text(
                  choice.unavailableReason ?? 'Chọn lại trên trang chi tiết',
                ),
                trailing: choice.product == null
                    ? null
                    : const Icon(Icons.chevron_right, color: P2.brown),
                onTap: choice.product == null
                    ? null
                    : () => Navigator.pop(context, choice.product),
              ),
          ],
        );
      },
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Đóng'),
      ),
    ],
  );
}
