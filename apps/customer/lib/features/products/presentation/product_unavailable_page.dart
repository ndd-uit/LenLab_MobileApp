import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';
import 'package:lenlab_customer/app/navigation.dart';
import 'package:lenlab_customer/shared/widgets/header_widgets.dart';

/// A missing route payload must never select a different product implicitly.
class ProductUnavailablePage extends StatelessWidget {
  const ProductUnavailablePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      leadingWidth: 72,
      leading: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 14),
        child: HeaderBackButton(),
      ),
      title: const Text('Chi tiết sản phẩm'),
    ),
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: EmptyPanel(
            'Không tìm thấy sản phẩm',
            description:
                'Thông tin sản phẩm không hợp lệ hoặc chưa được cung cấp.',
            action: P2Button(
              'Xem sản phẩm',
              onPressed: () => go(context, '/products'),
            ),
          ),
        ),
      ),
    ),
  );
}
