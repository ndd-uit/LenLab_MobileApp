import 'package:image_picker/image_picker.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

import '../../../shared/data/gallery_selection_context.dart';

abstract interface class ReviewPhotoPicker {
  Future<List<ReviewPhoto>> pick({required int remaining});
}

class GalleryReviewPhotoPicker implements ReviewPhotoPicker {
  GalleryReviewPhotoPicker({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();
  final ImagePicker _picker;
  @override
  Future<List<ReviewPhoto>> pick({required int remaining}) async {
    if (remaining <= 0) return const [];
    await GallerySelectionContext.begin('review');
    try {
      final files = await _picker.pickMultiImage(
        limit: remaining,
        requestFullMetadata: false,
      );
      if (files.length > remaining) {
        throw const RepositoryException(
          'Mỗi đánh giá được đính kèm tối đa 5 ảnh.',
        );
      }
      final photos = <ReviewPhoto>[];
      for (final file in files) {
        if (await file.length() > maxReviewPhotoBytes) {
          throw RepositoryException('${file.name}: ảnh tối đa 5 MB.');
        }
        photos.add(
          ReviewPhoto(name: file.name, bytes: await file.readAsBytes()),
        );
      }
      return photos;
    } finally {
      await GallerySelectionContext.take();
    }
  }
}
