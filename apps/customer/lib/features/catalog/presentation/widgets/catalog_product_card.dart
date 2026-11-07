import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';
import 'package:lenlab_customer/app/navigation.dart';
import 'package:lenlab_customer/app/customer_scope.dart';

import '../catalog_styles.dart';

class CatalogProductCard extends StatelessWidget {
  const CatalogProductCard({
    super.key,
    required this.product,
    this.titleHeight,
    this.reserveOldPrice = false,
    this.stackPrice,
  });
  final Product product;
  final double? titleHeight;
  final bool reserveOldPrice;
  final bool? stackPrice;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => go(context, '/product', product),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 4 / 5,
          child: Stack(
            fit: StackFit.expand,
            children: [
              P2Asset(product.image, radius: 32, label: product.name),
              if (CustomerScope.of(context)
                  .reviewsFor(product.id)
                  .reviews
                  .isNotEmpty)
                Positioned(
                  left: 8,
                  bottom: 8,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        color: Colors.black.withValues(alpha: .4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            P2Asset.node(
                              catalogNode,
                              'imgContainer6',
                              width: 11.667,
                              height: 11.083,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              CustomerScope.of(context)
                                  .reviewsFor(product.id)
                                  .average
                                  .toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                height: 16 / 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: BoxConstraints(
            minHeight:
                titleHeight ?? MediaQuery.textScalerOf(context).scale(40),
          ),
          child: Text(
            product.name,
            style: P2
                .serif(
                  16,
                  color: const Color(0xFF9B4B3E),
                  weight: FontWeight.w600,
                )
                .copyWith(height: 1.25, letterSpacing: 0),
          ),
        ),
        const SizedBox(height: 4),
        if (product.oldPrice != null || reserveOldPrice)
          Text(
            product.oldPrice == null ? ' ' : money(product.oldPrice!),
            style: const TextStyle(
              fontSize: 10,
              height: 1.6,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        LayoutBuilder(
          builder: (context, constraints) {
            final priceStyle = const TextStyle(
              color: P2.ink,
              fontSize: 16,
              height: 1.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            );
            final painter = TextPainter(
              text: TextSpan(
                text: money(product.price),
                style: DefaultTextStyle.of(context).style.merge(priceStyle),
              ),
              textDirection: Directionality.of(context),
              textScaler: MediaQuery.textScalerOf(context),
            )..layout();
            final fits = painter.width + 48 <= constraints.maxWidth;
            painter.dispose();
            final children = <Widget>[
              Text(
                money(product.price),
                style: const TextStyle(
                  color: P2.ink,
                  fontSize: 16,
                  height: 1.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
              IconButton.filled(
                tooltip: 'Chọn biến thể ${product.name}',
                onPressed: () => go(context, '/product', product),
                style: IconButton.styleFrom(
                  backgroundColor: P2.productCardButton,
                  fixedSize: const Size(44, 44),
                ),
                icon: P2Asset.node(
                  catalogNode,
                  'imgContainer7',
                  width: 10.5,
                  height: 10.5,
                ),
              ),
            ];
            return !(stackPrice ?? !fits)
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: children,
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      children.first,
                      Align(
                        alignment: Alignment.centerRight,
                        child: children.last,
                      ),
                    ],
                  );
          },
        ),
      ],
    ),
  );
}
