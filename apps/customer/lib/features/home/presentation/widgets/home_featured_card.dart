import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';
import 'package:lenlab_customer/app/navigation.dart';

import '../home_styles.dart';
import '../../data/home_content.dart';

class HomeFeaturedCard extends StatelessWidget {
  const HomeFeaturedCard({
    super.key,
    required this.item,
    required this.product,
  });
  final HomeFeaturedItem item;
  final Product product;
  @override
  Widget build(BuildContext context) => InkWell(
    key: ValueKey('home-product-${product.id}'),
    onTap: () => go(context, '/product', product),
    borderRadius: BorderRadius.circular(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 3 / 4,
          child: Stack(
            fit: StackFit.expand,
            children: [
              P2Asset(product.image, radius: 16, label: product.name),
              if (item.badge != null)
                Positioned(
                  left: 12,
                  top: 12,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        color: item.sale
                            ? const Color(0xE6FF1111)
                            : const Color(0x99000000),
                        child: Text(
                          item.badge!,
                          style: const TextStyle(
                            fontFamily: homeFont,
                            fontSize: 10,
                            height: 1.5,
                            letterSpacing: .25,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          product.name,
          style: P2
              .serif(16, weight: FontWeight.w600)
              .copyWith(height: 1.5, letterSpacing: 0),
        ),
        const SizedBox(height: 4),
        Text(
          money(product.price).replaceAll('đ', '₫'),
          style: const TextStyle(
            fontFamily: homeFont,
            fontSize: 14,
            height: 20 / 14,
            letterSpacing: 0,
            fontWeight: FontWeight.w700,
            color: P2.ink,
          ),
        ),
      ],
    ),
  );
}
