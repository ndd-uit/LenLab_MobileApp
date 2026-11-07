import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';
import 'package:lenlab_customer/shared/widgets/header_widgets.dart';

import '../detail_styles.dart';

class DetailActionBar extends StatelessWidget {
  const DetailActionBar({
    super.key,
    required this.quantity,
    required this.onMinus,
    required this.onPlus,
    required this.onAdd,
  });
  final int quantity;
  final VoidCallback? onMinus, onPlus, onAdd;
  @override
  Widget build(BuildContext context) => Material(
    color: P2.rose.withValues(alpha: .95),
    child: SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stepper = Container(
            width: 132,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xCCFFFFFF),
              border: Border.all(color: const Color(0xFF9B4B3E), width: 2),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  tooltip: 'Giảm số lượng',
                  onPressed: onMinus,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 44,
                    height: 44,
                  ),
                  icon: detailAsset('imgContainer4', 11.667, 1.667),
                ),
                Expanded(
                  child: Text(
                    '$quantity',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Tăng số lượng',
                  onPressed: onPlus,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 44,
                    height: 44,
                  ),
                  icon: detailAsset('imgContainer5', 11.667, 11.667),
                ),
              ],
            ),
          );
          final button = ElevatedButton(
            onPressed: onAdd,
            style: ElevatedButton.styleFrom(
              backgroundColor: detailOrange,
              foregroundColor: detailText,
              minimumSize: const Size(double.infinity, 56),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              elevation: 4,
              side: BorderSide.none,
              shape: const StadiumBorder(),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const HeaderCartIcon(showBadge: false),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    onAdd == null ? 'Hết hàng' : 'Thêm vào giỏ',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          );
          if (constraints.maxWidth < 340 &&
              MediaQuery.textScalerOf(context).scale(16) > 16) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [stepper, const SizedBox(height: 12), button],
            );
          }
          return Row(
            children: [
              stepper,
              const SizedBox(width: 16),
              Expanded(child: button),
            ],
          );
        },
      ),
    ),
  );
}
