import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

import 'catalog_product_card.dart';

class CatalogGrid extends StatelessWidget {
  const CatalogGrid({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Column(
      children: [
        for (int i = 0; i < children.length; i += 2)
          Padding(
            padding: EdgeInsets.only(bottom: i + 2 < children.length ? 16 : 0),
            child: _row(context, i, (constraints.maxWidth - 16) / 2),
          ),
      ],
    ),
  );

  Widget _row(BuildContext context, int index, double width) {
    final first = children[index];
    final second = index + 1 < children.length
        ? children[index + 1]
        : const SizedBox();
    if (first is! CatalogProductCard) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: first),
          const SizedBox(width: 16),
          Expanded(child: second),
        ],
      );
    }
    final cards = [first, if (second is CatalogProductCard) second];
    double titleHeight = MediaQuery.textScalerOf(context).scale(40);
    bool stackPrice = false;
    final reserveOldPrice = cards.any((card) => card.product.oldPrice != null);
    for (final card in cards) {
      final titleStyle = P2
          .serif(16, weight: FontWeight.w600)
          .copyWith(height: 1.25, letterSpacing: 0);
      final titlePainter = TextPainter(
        text: TextSpan(text: card.product.name, style: titleStyle),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout(maxWidth: width);
      if (titlePainter.height > titleHeight) titleHeight = titlePainter.height;
      titlePainter.dispose();
      final pricePainter = TextPainter(
        text: TextSpan(
          text: money(card.product.price),
          style: DefaultTextStyle.of(context).style.merge(
            const TextStyle(
              fontSize: 16,
              height: 1.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout();
      if (pricePainter.width + 48 > width) stackPrice = true;
      pricePainter.dispose();
    }
    Widget align(CatalogProductCard card) => CatalogProductCard(
      product: card.product,
      titleHeight: titleHeight,
      reserveOldPrice: reserveOldPrice,
      stackPrice: stackPrice,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: align(first)),
        const SizedBox(width: 16),
        Expanded(child: second is CatalogProductCard ? align(second) : second),
      ],
    );
  }
}

class CatalogLoading extends StatelessWidget {
  const CatalogLoading({super.key});
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Đang tải sản phẩm',
    liveRegion: true,
    child: Column(
      children: [
        const LinearProgressIndicator(),
        gap,
        CatalogGrid(
          children: List.generate(
            6,
            (_) => Column(
              children: [
                AspectRatio(
                  aspectRatio: 4 / 5,
                  child: Container(
                    decoration: BoxDecoration(
                      color: P2.rose.withValues(alpha: .4),
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(height: 40, color: P2.rose.withValues(alpha: .25)),
                gap,
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
