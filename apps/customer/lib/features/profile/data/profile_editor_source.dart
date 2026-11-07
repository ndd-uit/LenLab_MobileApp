import 'dart:typed_data';

import 'package:lenlab_shared/lenlab_shared.dart';

import 'avatar_picker_source.dart';

import '../../auth/presentation/auth_validators.dart';

class ProfileDraft {
  const ProfileDraft({
    required this.name,
    required this.phone,
    required this.email,
    required this.gender,
    required this.birthday,
    this.avatar,
    this.avatarBytes,
  });
  final String name, phone, email, gender, birthday;
  final String? avatar;
  final Uint8List? avatarBytes;
}

String normalizedProfilePhone(String value) =>
    value.replaceAll(RegExp(r'\s+'), '');
DateTime? parseBirthday(String value) {
  final match = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(value.trim());
  if (match == null) return null;
  final day = int.parse(match[1]!),
      month = int.parse(match[2]!),
      year = int.parse(match[3]!);
  if (year < 1) return null;
  final date = DateTime(year, month, day);
  return date.year == year && date.month == month && date.day == day
      ? date
      : null;
}

String? birthdayError(String? value) {
  if ((value ?? '').trim().isEmpty) return null;
  final date = parseBirthday(value!);
  if (date == null) return 'Ngày sinh chưa hợp lệ (ngày/tháng/năm).';
  final now = DateTime.now();
  if (date.isAfter(DateTime(now.year, now.month, now.day))) {
    return 'Ngày sinh không được ở tương lai.';
  }
  return null;
}

abstract interface class ProfileEditorSource {
  Future<ProfileDraft> load();
  Future<void> save({
    required String name,
    required String phone,
    required String gender,
    required String birthday,
    Uint8List? avatarBytes,
  });
}

class MockProfileEditorSource implements ProfileEditorSource {
  MockProfileEditorSource(this.store);
  final LenlabStore store;
  Future<void> operation(String name) async {
    store.requireCustomer();
    final session = store.captureSession();
    if (store.repository case final MockLenlabRepository mock) {
      await mock.operation(name);
    } else {
      throw const RepositoryException('Chưa cấu hình nguồn sửa hồ sơ.');
    }
    store.requireSession(session);
  }

  @override
  Future<ProfileDraft> load() async {
    store.requireCustomer();
    final actor = store.captureSession();
    await operation('profileEditor');
    store.requireSession(actor);
    final p = store.profile;
    return ProfileDraft(
      name: p.name,
      phone: p.phone,
      email: p.email,
      gender: p.gender,
      birthday: p.birthday,
      avatar: p.avatar,
      avatarBytes: p.avatarBytes,
    );
  }

  @override
  Future<void> save({
    required String name,
    required String phone,
    required String gender,
    required String birthday,
    Uint8List? avatarBytes,
  }) async {
    store.requireCustomer();
    final session = store.captureSession();
    final normalized = normalizedProfilePhone(phone);
    final error =
        requiredText(name) ??
        phoneValidator(normalized) ??
        birthdayError(birthday);
    if (error != null) throw RepositoryException(error);
    if (!['', 'Nam', 'Nữ', 'Khác'].contains(gender) &&
        gender != store.profile.gender) {
      throw const RepositoryException('Giới tính chưa hợp lệ.');
    }
    final checkedAvatar = avatarBytes == null
        ? null
        : await validatedAvatar(avatarBytes);
    await operation('saveProfile');
    store.requireSession(session);
    final p = store.profile;
    p.name = name.trim();
    p.phone = normalized;
    p.gender = gender;
    p.birthday = birthday.trim();
    if (checkedAvatar != null) p.avatarBytes = checkedAvatar;
    store.changed();
  }
}
