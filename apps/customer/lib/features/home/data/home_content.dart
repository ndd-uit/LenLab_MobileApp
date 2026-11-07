/// Display fixtures from P2 2026:664. Promotions are labels, not pricing rules.
class HomeFeaturedItem {
  const HomeFeaturedItem(this.productId, {this.badge, this.sale = false});
  final String productId;
  final String? badge;
  final bool sale;
}

const homeFeaturedItems = [
  HomeFeaturedItem('featured-handknit', badge: 'BEST SELLER'),
  HomeFeaturedItem('featured-beanie'),
  HomeFeaturedItem('featured-socks'),
  HomeFeaturedItem('featured-crochet-bag', badge: '-20%', sale: true),
];

const homeCategories = [
  (label: 'Nguyên phụ liệu', icon: 'imgContainer4', width: 25.0, height: 25.0),
  (label: 'Đồ trang trí', icon: 'imgContainer5', width: 22.5, height: 25.0),
  (label: 'Thời trang len', icon: 'imgContainer6', width: 25.0, height: 20.0),
  (label: 'Combo tiết kiệm', icon: 'imgContainer7', width: 25.0, height: 23.75),
  (label: 'Thú bông len', icon: 'imgContainer8', width: 25.0, height: 23.75),
];
