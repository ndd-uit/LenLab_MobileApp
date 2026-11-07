import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:lenlab_shared/lenlab_shared.dart';

Future<Uint8List> validatedLocalImage(Uint8List data) async {
  if (data.isEmpty) {
    throw const RepositoryException(
      'Ảnh đã chọn đang trống. Vui lòng chọn ảnh khác.',
    );
  }
  final bytes = Uint8List.fromList(data).asUnmodifiableView();
  ui.Codec? codec;
  ui.FrameInfo? frame;
  try {
    codec = await ui.instantiateImageCodec(bytes, targetWidth: 256);
    frame = await codec.getNextFrame();
    return bytes;
  } catch (_) {
    throw const RepositoryException(
      'Không đọc được ảnh này. Vui lòng chọn ảnh khác.',
    );
  } finally {
    frame?.image.dispose();
    codec?.dispose();
  }
}
