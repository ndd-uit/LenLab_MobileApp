import 'dart:typed_data';

import 'package:lenlab_shared/lenlab_shared.dart';

class ProfileSummary {
  const ProfileSummary({
    required this.name,
    required this.email,
    this.membership,
    this.avatar,
    this.avatarBytes,
  });
  final String name, email;
  final String? membership;
  final String? avatar;
  final Uint8List? avatarBytes;
}

abstract interface class ProfileSource {
  Future<ProfileSummary> load();
}

class MockProfileSource implements ProfileSource {
  MockProfileSource(this.store);
  final LenlabStore store;
  @override
  Future<ProfileSummary> load() async {
    store.requireCustomer();
    final actor = store.captureSession();
    if (store.repository case final MockLenlabRepository mock) {
      await mock.operation('profile');
    } else {
      throw const RepositoryException('Chưa cấu hình nguồn hồ sơ.');
    }
    store.requireSession(actor);
    return ProfileSummary(
      name: store.profile.name,
      email: store.profile.email,
      membership: 'Thành viên thân thiết',
      avatar: store.profile.avatar,
      avatarBytes: store.profile.avatarBytes,
    ); // P2 mock label, not a loyalty rule.
  }
}
