import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

class ReviewRatingInput extends StatelessWidget {
  const ReviewRatingInput({
    super.key,
    required this.rating,
    required this.busy,
    required this.onChanged,
  });
  final int rating;
  final bool busy;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.center,
    spacing: 4,
    children: [
      for (var star = 1; star <= 5; star++)
        Semantics(
          selected: rating == star,
          child: IconButton(
            tooltip: '$star sao',
            onPressed: busy ? null : () => onChanged(star),
            icon: ColorFiltered(
              colorFilter: ColorFilter.mode(
                star <= rating ? Colors.transparent : P2.brown,
                star <= rating ? BlendMode.dst : BlendMode.srcIn,
              ),
              child: P2Asset.node(
                '2026:1037',
                star <= rating ? 'imgIcon4' : 'imgIcon11',
                width: 24,
                height: 23,
              ),
            ),
          ),
        ),
    ],
  );
}
