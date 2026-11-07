import 'dart:io';

/// Only the picker purpose survives Android process death, never image/user data.
/// A review attachment must not be restored as an avatar after restart.
abstract final class GallerySelectionContext {
  static File get _file => File(
    '${Directory.systemTemp.path}${Platform.pathSeparator}lenlab-gallery-purpose',
  );
  static Future<void> begin(String purpose) async {
    await _file.writeAsString(purpose, flush: true);
  }

  static Future<String?> take() async {
    final file = _file;
    try {
      if (!await file.exists()) return null;
      final value = await file.readAsString();
      await file.delete();
      return value;
    } on FileSystemException {
      return null;
    }
  }
}
