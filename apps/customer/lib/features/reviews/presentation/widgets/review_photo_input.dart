import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

class ReviewPhotoInput extends StatelessWidget {
  const ReviewPhotoInput({
    super.key,
    required this.photos,
    required this.busy,
    required this.picking,
    required this.onPick,
    required this.onRemove,
    this.error,
  });
  final List<ReviewPhoto> photos;
  final bool busy, picking;
  final VoidCallback onPick;
  final ValueChanged<int> onRemove;
  final String? error;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Text(
        'Ảnh đính kèm (không bắt buộc)',
        style: TextStyle(fontWeight: FontWeight.w600, color: P2.brown),
      ),
      const SizedBox(height: 8),
      const Text(
        'Tối đa 5 ảnh JPG/PNG, mỗi ảnh tối đa 5 MB.',
        style: TextStyle(fontSize: 12, color: P2.brown),
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (var i = 0; i < photos.length; i++)
            SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        photos[i].bytes,
                        fit: BoxFit.cover,
                        cacheWidth: 300,
                        semanticLabel: 'Ảnh đánh giá ${i + 1}',
                        errorBuilder: (_, error, stack) => const Icon(
                          Icons.broken_image_outlined,
                          color: P2.brown,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      tooltip: 'Bỏ ảnh ${i + 1}',
                      onPressed: busy || picking ? null : () => onRemove(i),
                      style: IconButton.styleFrom(
                        backgroundColor: P2.cream,
                        foregroundColor: P2.brown,
                      ),
                      icon: const Icon(Icons.close, size: 20),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      if (photos.isNotEmpty) const SizedBox(height: 12),
      OutlinedButton.icon(
        key: const ValueKey('review-add-photos'),
        onPressed: busy || picking || photos.length >= maxReviewPhotos
            ? null
            : onPick,
        icon: const Icon(Icons.add_photo_alternate_outlined),
        label: Text('Thêm ảnh (${photos.length}/5)'),
      ),
      if (picking)
        const LinearProgressIndicator(semanticsLabel: 'Đang đọc ảnh đánh giá'),
      if (error != null)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Semantics(
            liveRegion: true,
            child: Text(
              error!,
              style: const TextStyle(color: Color(0xFF7A2929)),
            ),
          ),
        ),
    ],
  );
}
