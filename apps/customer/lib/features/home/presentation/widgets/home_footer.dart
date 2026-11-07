import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';
import 'package:lenlab_customer/app/navigation.dart';

import '../home_styles.dart';

class HomeFooter extends StatelessWidget {
  const HomeFooter({super.key, this.copyrightYear});
  // Optional override keeps visual fixtures independent of the system year.
  final int? copyrightYear;
  @override
  Widget build(BuildContext context) => Container(
    key: const ValueKey('home-footer'),
    color: Color.alphaBlend(P2.rose.withValues(alpha: .9), P2.cream),
    padding: const EdgeInsets.fromLTRB(16, 49, 16, 32),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LENLAB',
          style: P2
              .serif(24, color: P2.ink, weight: FontWeight.w700)
              .copyWith(height: 32 / 24, letterSpacing: -.6),
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 327),
          child: Text(
            'Thương hiệu đồ len thủ công hàng đầu, mang đến sự ấm áp và phong cách sống bền vững cho bạn.',
            style: P2
                .serif(14, color: P2.ink)
                .copyWith(height: 20 / 14, letterSpacing: 0),
          ),
        ),
        const SizedBox(height: 32),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _FooterLinks(
                title: 'KHÁM PHÁ',
                links: [
                  ('Về chúng tôi', () => go(context, '/about')),
                  ('Sản phẩm', () => go(context, '/products')),
                  ('Liên hệ', () => go(context, '/chat')),
                ],
              ),
            ),
            const SizedBox(width: 32),
            Expanded(
              child: _FooterLinks(
                title: 'HỖ TRỢ',
                links: [
                  ('Chính sách đổi trả', () => go(context, '/policies')),
                  (
                    'Hướng dẫn chọn size',
                    () => missingSpec(context, 'Hướng dẫn chọn size'),
                  ),
                  ('Bảo mật thông tin', () => go(context, '/policies')),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Divider(
          height: 1,
          thickness: 1,
          color: Colors.white.withValues(alpha: .05),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            for (final social in [
              ('Facebook', 'imgSvg'),
              ('Instagram', 'imgSvg1'),
            ])
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: IconButton(
                  tooltip: social.$1,
                  onPressed: () => missingSpec(context, 'Kênh ${social.$1}'),
                  style: IconButton.styleFrom(
                    backgroundColor: P2.cream,
                    minimumSize: const Size(44, 44),
                  ),
                  icon: P2Asset.node(
                    '2026:664',
                    social.$2,
                    width: 20,
                    height: 20,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          '© ${copyrightYear ?? DateTime.now().year} LENLAB. All rights reserved.',
          style: P2
              .serif(12, color: const Color(0xFF523A30))
              .copyWith(height: 16 / 12),
        ),
      ],
    ),
  );
}

class _FooterLinks extends StatelessWidget {
  const _FooterLinks({required this.title, required this.links});
  final String title;
  final List<(String, VoidCallback)> links;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: P2
            .serif(14, color: const Color(0xFF523A30), weight: FontWeight.w700)
            .copyWith(height: 20 / 14, letterSpacing: .7),
      ),
      const SizedBox(height: 8),
      for (final link in links)
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: link.$2,
            style: TextButton.styleFrom(
              alignment: Alignment.centerLeft,
              minimumSize: const Size(44, 28),
              padding: const EdgeInsets.symmetric(vertical: 4),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              textStyle: const TextStyle(
                fontFamily: homeFont,
                fontSize: 14,
                height: 20 / 14,
              ),
              foregroundColor: P2.ink,
            ),
            child: Text(link.$1),
          ),
        ),
    ],
  );
}
