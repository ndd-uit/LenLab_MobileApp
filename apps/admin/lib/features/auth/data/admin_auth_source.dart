class AdminUser {
  const AdminUser({required this.id, required this.name, required this.email});
  final String id, name, email;
}

class AdminAuthException implements Exception {
  const AdminAuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

abstract interface class AdminAuthSource {
  Future<AdminUser> signIn(String email, String password);
}

/// Explicit demo fixture only; never a production credential or access control.
class MockAdminAuthSource implements AdminAuthSource {
  MockAdminAuthSource({this.latency = const Duration(milliseconds: 300)});
  static const demoEmail = 'admin@gm.vn';
  static const demoPassword = '1';
  final Duration latency;
  bool failNext = false;

  @override
  Future<AdminUser> signIn(String email, String password) async {
    await Future<void>.delayed(latency);
    if (failNext) {
      failNext = false;
      throw const AdminAuthException(
        'Không thể đăng nhập lúc này. Vui lòng thử lại.',
      );
    }
    if (email.trim().toLowerCase() != demoEmail || password != demoPassword) {
      throw const AdminAuthException('Email hoặc mật khẩu không đúng.');
    }
    return const AdminUser(
      id: 'admin-demo',
      name: 'Admin User',
      email: demoEmail,
    );
  }
}
