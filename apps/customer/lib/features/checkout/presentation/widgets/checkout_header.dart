import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';
import 'package:lenlab_customer/app/navigation.dart';
import 'package:lenlab_customer/shared/widgets/header_widgets.dart';

class CheckoutHeader extends StatelessWidget implements PreferredSizeWidget {
  const CheckoutHeader({
    super.key,
    this.title = 'Địa chỉ giao hàng',
    this.activeStep = 0,
    this.overlayProgress = false,
    this.overlayHeight = 87,
  });
  final String title;
  final int activeStep;
  final bool overlayProgress;
  final double overlayHeight;
  @override
  Size get preferredSize =>
      Size.fromHeight(overlayProgress ? overlayHeight : 86);
  @override
  Widget build(BuildContext context) => Material(
    color: P2.rose,
    child: SafeArea(
      bottom: false,
      child: overlayProgress
          ? SizedBox(
              height: overlayHeight,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Row(
                      children: [
                        const SizedBox(width: 14),
                        HeaderBackButton(
                          onFallback: () => go(context, '/order-review'),
                        ),
                        Expanded(
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              height: 1.25,
                              fontWeight: FontWeight.w700,
                              color: P2.ink,
                              letterSpacing: -.45,
                            ),
                          ),
                        ),
                        const SizedBox(width: 58),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Row(
                      children: [
                        for (int i = 0; i < 3; i++) ...[
                          Expanded(
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: i == activeStep
                                    ? P2.brown
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(99),
                              ),
                            ),
                          ),
                          if (i < 2) const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                SizedBox(
                  height: 64,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        HeaderBackButton(
                          onFallback: () => go(context, '/cart'),
                        ),
                        Expanded(
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: P2.ink,
                              letterSpacing: -.27,
                            ),
                          ),
                        ),
                        const SizedBox(width: 44),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: Row(
                    children: [
                      for (int i = 0; i < 3; i++)
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                            height: 6,
                            decoration: BoxDecoration(
                              color: i == activeStep ? P2.brown : Colors.white,
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    ),
  );
}
