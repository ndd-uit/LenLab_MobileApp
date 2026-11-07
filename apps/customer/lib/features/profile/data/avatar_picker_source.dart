import '../../../shared/data/gallery_selection_context.dart';
import '../../../shared/data/local_image_validation.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

abstract interface class AvatarPickerSource {
  Future<Uint8List?> pick();
  Future<Uint8List?> recover();
}

/// Decode before displaying/saving: a file extension is not image validation.
Future<Uint8List> validatedAvatar(Uint8List data) => validatedLocalImage(data);

class GalleryAvatarPicker implements AvatarPickerSource {
  GalleryAvatarPicker({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();
  final ImagePicker _picker;
  Future<Uint8List?>? _recovery;
  Uint8List? _recovered;
  Object? _recoveryError;

  Future<void> startRecovery() async {
    _recovery ??= _retrieve();
    await _recovery;
  }

  Future<Uint8List?> _retrieve() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return null;
    try {
      final purpose = await GallerySelectionContext.take();
      final lost = await _picker.retrieveLostData();
      if (lost.exception != null) throw lost.exception!;
      final file = lost.files?.firstOrNull;
      if (file != null && purpose == 'avatar') {
        _recovered = await validatedAvatar(await file.readAsBytes());
      }
    } on MissingPluginException {
      // Widget tests and unsupported hosts have no native gallery implementation.
    } catch (error) {
      // Recovery cannot prevent startup; show the error when editor is opened.
      _recoveryError = error;
    }
    return _recovered;
  }

  @override
  Future<Uint8List?> recover() async {
    // Startup (main) starts the native request once. Opening an editor should
    // never initiate a second native picker recovery request.
    if (_recovery == null) return null;
    await _recovery;
    final error = _recoveryError;
    _recoveryError = null;
    if (error != null) {
      throw const RepositoryException(
        'Không khôi phục được ảnh đã chọn. Bạn có thể chọn lại ảnh.',
      );
    }
    final bytes = _recovered;
    _recovered = null;
    return bytes;
  }

  @override
  Future<Uint8List?> pick() async {
    await GallerySelectionContext.begin('avatar');
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        requestFullMetadata: false,
      );
      return file == null
          ? null
          : await validatedAvatar(await file.readAsBytes());
    } finally {
      await GallerySelectionContext.take();
    }
  }
}

final galleryAvatarPicker = GalleryAvatarPicker();
