import 'dart:typed_data';

import 'lenlab_repository.dart';

const maxReviewPhotos = 5;
const maxReviewPhotoBytes = 5 * 1024 * 1024;

/// Local attachment only; not an uploaded URL or a persisted file path.
class ReviewPhoto {
  ReviewPhoto({required this.name, required Uint8List bytes})
    : bytes = Uint8List.fromList(bytes).asUnmodifiableView();
  final String name;
  final Uint8List bytes;
}

void validateReviewPhotos(List<ReviewPhoto> photos) {
  if (photos.length > maxReviewPhotos) {
    throw const RepositoryException('Mỗi đánh giá được đính kèm tối đa 5 ảnh.');
  }
  for (final photo in photos) {
    if (photo.bytes.isEmpty || photo.bytes.length > maxReviewPhotoBytes) {
      throw RepositoryException(
        '${photo.name}: ảnh phải có dung lượng lớn hơn 0 và tối đa 5 MB.',
      );
    }
    final b = photo.bytes;
    final png =
        b.length >= 8 &&
        b[0] == 137 &&
        b[1] == 80 &&
        b[2] == 78 &&
        b[3] == 71 &&
        b[4] == 13 &&
        b[5] == 10 &&
        b[6] == 26 &&
        b[7] == 10;
    final jpg = b.length >= 3 && b[0] == 255 && b[1] == 216 && b[2] == 255;
    if (!png && !jpg) {
      throw RepositoryException('${photo.name}: chỉ hỗ trợ ảnh JPG/PNG.');
    }
  }
}
