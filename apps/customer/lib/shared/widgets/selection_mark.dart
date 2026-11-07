import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

/// Visual only: the parent supplies checkbox/radio semantics and interaction.
class CustomerSelectionMark extends StatelessWidget {
  const CustomerSelectionMark({
    super.key,
    required this.selected,
    this.size = 24,
  });
  final bool selected;
  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: P2.brown, width: 1.5),
      ),
      child: selected
          ? ColorFiltered(
              colorFilter: const ColorFilter.mode(P2.brown, BlendMode.srcIn),
              child: P2Asset.node(
                '2026:1325',
                'imgImage',
                width: size - 2,
                height: size - 2,
              ),
            )
          : null,
    ),
  );
}
