import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';
import 'package:lenlab_customer/app/customer_scope.dart';
import 'package:lenlab_customer/app/navigation.dart';
import 'package:lenlab_customer/app/auth_return_intent.dart';
import 'package:lenlab_customer/shared/widgets/header_widgets.dart';

import 'detail_styles.dart';
import 'widgets/detail_overlay_button.dart';
import 'widgets/detail_action_bar.dart';
import 'widgets/detail_reviews.dart';
import 'widgets/detail_related.dart';
import 'widgets/merino_variant_sheet.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key, required this.product});
  final Product product;
  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  String color = 'Kem', size = '180cm';
  int quantity = 1;
  bool expanded = false;
  bool choosingVariant = false;

  Future<void> chooseVariant() async {
    if (choosingVariant) return;
    choosingVariant = true;
    final store = CustomerScope.of(context);
    final product = widget.product;
    try {
      final selected = await showModalBottomSheet<MerinoSelection>(
        context: context,
        isScrollControlled: true,
        backgroundColor: const Color(0xFFF7F2E8),
        barrierColor: const Color(0x59000000),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * .94,
        ),
        builder: (_) => MerinoVariantSheet(
          product: product,
          initial: MerinoSelection(color, size, quantity),
          existingQuantity: (variant) => store.cart
              .where(
                (line) =>
                    line.product.id == product.id && line.variant == variant,
              )
              .fold(0, (sum, line) => sum + line.quantity),
          onConfirm: (selection) {
            if (store.isSubmittingCod || !product.published) return false;
            store.addToCart(product, selection.quantity, selection.variant);
            return true;
          },
        ),
      );
      if (!mounted || selected == null) return;
      setState(() {
        color = selected.color;
        size = selected.size;
        quantity = selected.quantity;
      });
      toast(context, 'Đã thêm sản phẩm vào giỏ hàng.');
    } finally {
      choosingVariant = false;
    }
  }

  void add() {
    final store = CustomerScope.of(context);
    final variant = widget.product.id == 'merino'
        ? '$color · $size'
        : widget.product.detail;
    final existing = store.cart
        .where(
          (line) =>
              line.product.id == widget.product.id && line.variant == variant,
        )
        .fold(0, (n, line) => n + line.quantity);
    if (quantity + existing > widget.product.stock) {
      toast(context, 'Số lượng trong giỏ vượt tồn kho hiện có.');
      return;
    }
    store.addToCart(widget.product, quantity, variant);
    toast(context, 'Đã thêm sản phẩm vào giỏ hàng.');
  }

  @override
  Widget build(BuildContext context) {
    final store = CustomerScope.of(context);
    final p = widget.product;
    final reviews = store.reviewsFor(p.id);
    return Scaffold(
      backgroundColor: P2.rose,
      bottomNavigationBar: DetailActionBar(
        quantity: quantity,
        onMinus: quantity > 1 ? () => setState(() => quantity--) : null,
        onPlus: quantity < p.stock ? () => setState(() => quantity++) : null,
        onAdd: p.stock > 0 ? (p.id == 'merino' ? chooseVariant : add) : null,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            key: const ValueKey('merino-scroll'),
            child: Column(
              children: [
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 390 / 480,
                      child: P2Asset(p.image, label: p.name),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 32,
                      child: Center(
                        child: TextButton(
                          onPressed: () =>
                              missingSpec(context, 'Ảnh bổ sung sản phẩm'),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (int i = 0; i < 4; i++)
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  width: i == 0 ? 24 : 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(
                                      alpha: i == 0 ? 1 : .5,
                                    ),
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Transform.translate(
                  offset: const Offset(0, -32),
                  child: Container(
                    key: const ValueKey('merino-sheet'),
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                    decoration: const BoxDecoration(
                      color: P2.rose,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 0,
                          child: OverflowBox(
                            maxHeight: 4,
                            child: Transform.translate(
                              offset: const Offset(0, -18),
                              child: Container(
                                width: 48,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: .1),
                                  borderRadius: BorderRadius.circular(99),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                p.name,
                                style: detailSerif(
                                  24,
                                  weight: FontWeight.w700,
                                  height: 1.25,
                                ).copyWith(letterSpacing: -.6),
                              ),
                            ),
                            if (reviews.reviews.isNotEmpty)
                              const SizedBox(width: 8),
                            if (reviews.reviews.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: .05),
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: Row(
                                  children: [
                                    detailAsset(
                                      'imgContainer3',
                                      13.333,
                                      12.667,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      reviews.average.toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              money(p.price).replaceAll('đ', '₫'),
                              style: const TextStyle(
                                fontSize: 24,
                                height: 32 / 24,
                                fontWeight: FontWeight.w700,
                                color: Color(0xCC080808),
                              ),
                            ),
                            if (p.oldPrice != null)
                              Text(
                                money(p.oldPrice!).replaceAll('đ', '₫'),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: detailText,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            if (p.id == 'merino')
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0x249B4B3E),
                                  border: Border.all(
                                    color: const Color(0x4D9B4B3E),
                                  ),
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: Text('Bền vững', style: detailSerif(12)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Divider(color: Color(0x0DFFFFFF), height: 1),
                        const SizedBox(height: 24),
                        if (p.id == 'merino') ...[
                          Text(
                            'Màu sắc',
                            style: detailSerif(14, color: Colors.black),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            children: [
                              for (final choice in [
                                ('Kem', const Color(0xFFD2B48C)),
                                ('Nâu', const Color(0xFF8B4513)),
                                ('Xám', const Color(0xFFA9A9A9)),
                              ])
                                Semantics(
                                  selected: color == choice.$1,
                                  button: true,
                                  child: Tooltip(
                                    message: choice.$1,
                                    child: InkWell(
                                      onTap: () =>
                                          setState(() => color = choice.$1),
                                      borderRadius: BorderRadius.circular(99),
                                      child: SizedBox(
                                        width: 44,
                                        height: 44,
                                        child: Center(
                                          child: Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: choice.$2,
                                              shape: BoxShape.circle,
                                              border: color == choice.$1
                                                  ? Border.all(
                                                      color: Colors.white,
                                                      width: 2,
                                                    )
                                                  : null,
                                              boxShadow: color == choice.$1
                                                  ? const [
                                                      BoxShadow(
                                                        color: Color(
                                                          0xFF181411,
                                                        ),
                                                        spreadRadius: 2,
                                                      ),
                                                      BoxShadow(
                                                        color: detailOrange,
                                                        spreadRadius: 4,
                                                      ),
                                                    ]
                                                  : null,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Kích thước',
                                  style: detailSerif(14, color: Colors.black),
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    missingSpec(context, 'Hướng dẫn đo'),
                                child: const Text(
                                  'Hướng dẫn đo',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: detailText,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children: [
                              for (final value in ['180cm', '200cm'])
                                Semantics(
                                  selected: value == size,
                                  child: OutlinedButton(
                                    onPressed: () =>
                                        setState(() => size = value),
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: value == size
                                          ? detailOrange
                                          : Colors.transparent,
                                      foregroundColor: detailText,
                                      side: BorderSide(
                                        color: value == size
                                            ? Colors.transparent
                                            : Colors.white,
                                      ),
                                      minimumSize: const Size(92, 44),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                      ),
                                    ),
                                    child: Text(value),
                                  ),
                                ),
                            ],
                          ),
                        ],
                        if (p.id != 'merino' && p.detail.isNotEmpty)
                          Text(p.detail, style: detailSerif(14)),
                        const SizedBox(height: 32),
                        const Text(
                          'Mô tả sản phẩm',
                          style: TextStyle(
                            fontSize: 18,
                            height: 28 / 18,
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          p.description.isEmpty
                              ? 'Sản phẩm len thủ công từ LENLAB.'
                              : p.description,
                          textAlign: TextAlign.justify,
                          maxLines: expanded ? null : 7,
                          overflow: expanded
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                          style: detailSerif(
                            16,
                            weight: FontWeight.w400,
                            height: 26 / 16,
                          ),
                        ),
                        TextButton(
                          onPressed: () => setState(() => expanded = !expanded),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            alignment: Alignment.centerLeft,
                          ),
                          child: Text(
                            expanded ? 'Thu gọn' : 'Xem thêm...',
                            style: const TextStyle(
                              color: detailText,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Divider(color: Color(0x0DFFFFFF), height: 1),
                        const SizedBox(height: 24),
                        DetailReviews(product: p),
                        const SizedBox(height: 32),
                        const Text(
                          'Có thể bạn cũng thích',
                          style: TextStyle(
                            fontSize: 18,
                            height: 28 / 18,
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const DetailRelated(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
              child: Row(
                children: [
                  const HeaderBackButton(round: true),
                  const Spacer(),
                  DetailOverlayButton(
                    label: 'Yêu thích',
                    asset: 'imgContainer1',
                    width: 20,
                    height: 18.35,
                    selected: store.favorites.contains(p.id),
                    onPressed: () {
                      if (!store.signedIn) {
                        go(
                          context,
                          '/login',
                          AuthReturnIntent.forRoute(store, '/product', p.id),
                        );
                        return;
                      }
                      store.toggleFavorite(p.id);
                    },
                  ),
                  const SizedBox(width: 8),
                  DetailOverlayButton(
                    label: 'Giỏ hàng',
                    asset: 'cart',
                    width: 16,
                    height: 20,
                    badge: store.cartCount > 0,
                    onPressed: () => go(context, '/cart'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
