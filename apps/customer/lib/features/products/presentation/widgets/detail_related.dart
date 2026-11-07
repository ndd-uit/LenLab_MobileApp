import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';
import 'package:lenlab_customer/app/navigation.dart';

import '../../../../shared/widgets/catalog_products.dart';

import '../detail_styles.dart';

const relatedProductIds = [
  'related-356e2.png',
  'related-dc895.png',
  'related-eb513.png',
];

class DetailRelated extends StatelessWidget {
  const DetailRelated({super.key});
  @override
  Widget build(BuildContext context) => CatalogProducts(
    builder: (context, products) => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final id in relatedProductIds)
            if (purchasableProduct(products, id) case final product?)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 160,
                  child: InkWell(
                    key: ValueKey('related-product-$id'),
                    onTap: () => go(context, '/product', product),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AspectRatio(
                          aspectRatio: 3 / 4,
                          child: P2Asset(
                            product.image,
                            radius: 16,
                            label: product.name,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: detailText,
                          ),
                        ),
                        Text(
                          money(product.price).replaceAll('đ', '₫'),
                          style: const TextStyle(
                            fontSize: 14,
                            height: 20 / 14,
                            fontWeight: FontWeight.w700,
                            color: P2.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        ],
      ),
    ),
  );
}
