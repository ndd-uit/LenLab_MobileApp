import 'package:lenlab_customer/shared/widgets/selection_mark.dart';
import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

class PaymentMethodOption extends StatelessWidget {
  const PaymentMethodOption({
    super.key,
    required this.title,
    required this.subtitle,
    required this.asset,
    required this.selected,
    required this.onSelected,
  });
  final String title, subtitle, asset;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '$title. $subtitle',
    checked: selected,
    inMutuallyExclusiveGroup: true,
    onTap: onSelected,
    excludeSemantics: true,
    child: Material(
      color: selected ? P2.rose.withValues(alpha: .95) : P2.cream,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: P2.brown, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onSelected,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black),
                ),
                alignment: Alignment.center,
                child: P2Asset.node(
                  '2026:1627',
                  asset,
                  width: asset == 'imgContainer1' ? 22 : 20,
                  height: asset == 'imgContainer1' ? 16 : 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: P2
                          .serif(
                            16,
                            color: selected ? P2.ink : P2.brown,
                            weight: FontWeight.w600,
                          )
                          .copyWith(height: 1.5),
                    ),
                    Text(
                      subtitle,
                      style: P2
                          .serif(
                            14,
                            color: selected ? const Color(0xFF523A30) : P2.ink,
                          )
                          .copyWith(height: 20 / 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              CustomerSelectionMark(selected: selected),
            ],
          ),
        ),
      ),
    ),
  );
}
