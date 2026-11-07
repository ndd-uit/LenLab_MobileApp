import 'package:flutter/material.dart';
import 'package:lenlab_customer/shared/navigation/customer_drawer.dart';

import '../../../shared/widgets/catalog_products.dart';

import '../data/home_content.dart';
import 'widgets/home_header.dart';
import 'widgets/home_hero.dart';
import 'widgets/home_categories.dart';
import 'widgets/home_section_heading.dart';
import 'widgets/home_featured_card.dart';
import 'widgets/home_campaign.dart';
import 'widgets/home_footer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, this.copyrightYear});
  final int? copyrightYear;
  @override
  Widget build(BuildContext context) => Scaffold(
    drawer: const CustomerDrawer(),
    drawerScrimColor: const Color(0x996E6E6D),
    appBar: const HomeHeader(),
    body: SafeArea(
      top: false,
      child: SingleChildScrollView(
        key: const ValueKey('home-scroll'),
        child: HomeContent(copyrightYear: copyrightYear),
      ),
    ),
  );
}

/// Home-only header; the catalog header is reviewed in its own task.
class HomeContent extends StatelessWidget {
  const HomeContent({super.key, this.copyrightYear});
  final int? copyrightYear;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Padding(
        padding: EdgeInsets.fromLTRB(16, 20.35, 16, 10.17),
        child: HomeHero(),
      ),
      const HomeCategories(),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const HomeSectionHeading('Sản phẩm nổi bật', route: '/products'),
            const SizedBox(height: 4),
            CatalogProducts(
              builder: (context, products) => LayoutBuilder(
                builder: (context, available) => Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    for (final item in homeFeaturedItems)
                      if (purchasableProduct(products, item.productId)
                          case final product?)
                        SizedBox(
                          width: (available.maxWidth - 16) / 2,
                          child: HomeFeaturedCard(item: item, product: product),
                        ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10.16),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: HomeCampaign(),
            ),
            const SizedBox(height: 15.25),
          ],
        ),
      ),
      HomeFooter(copyrightYear: copyrightYear),
    ],
  );
}
