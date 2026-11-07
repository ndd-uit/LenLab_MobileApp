import 'package:flutter/services.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

String reviewPhotoError(Object error) {
  if (error is RepositoryException) return error.message;
  if (error is MissingPluginException ||
      error is PlatformException && error.code == 'channel-error') {
    return 'Chưa kết nối được thư viện ảnh của thiết bị. Hãy dừng app và chạy lại bằng flutter run; hot reload không cập nhật plugin native.';
  }
  if (error is PlatformException) {
    if (error.code.startsWith('photo_access')) {
      return 'Không có quyền truy cập ảnh. Vui lòng kiểm tra quyền Ảnh trong cài đặt thiết bị.';
    }
    if (error.code == 'already_active') {
      return 'Thư viện ảnh đang mở. Hãy đóng cửa sổ chọn ảnh rồi thử lại.';
    }
    return 'Không mở được thư viện ảnh (mã: ${error.code}). Vui lòng thử lại.';
  }
  if (error is UnsupportedError || error is UnimplementedError) {
    return 'Thiết bị hiện tại chưa hỗ trợ cách chọn ảnh này. Vui lòng báo nền tảng đang chạy để kiểm tra.';
  }
  return 'Không thể chọn ảnh. Vui lòng thử lại.';
}
