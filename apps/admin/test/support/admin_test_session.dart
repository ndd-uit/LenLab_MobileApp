import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_admin/app/admin_session.dart';
import 'package:lenlab_admin/features/auth/data/admin_auth_source.dart';

class ImmediateTestAuth implements AdminAuthSource {
  @override
  Future<AdminUser> signIn(String email, String password) async =>
      const AdminUser(id: 'test', name: 'Admin User', email: 'admin@lenlab.vn');
}

Future<AdminSession> createSession() async {
  final session = AdminSession(source: ImmediateTestAuth());
  addTearDown(session.dispose);
  await session.signIn('test', 'test');
  return session;
}
