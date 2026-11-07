import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_admin/app/admin_session.dart';
import 'package:lenlab_admin/features/auth/data/admin_auth_source.dart';

class DeferredAuth implements AdminAuthSource {
  final gate = Completer<AdminUser>();
  int calls = 0;
  @override
  Future<AdminUser> signIn(String email, String password) {
    calls++;
    return gate.future;
  }
}

void main() {
  test(
    'Demo account validates credentials and permits retry after failure',
    () async {
      final source = MockAdminAuthSource(latency: Duration.zero);
      final session = AdminSession(source: source);
      addTearDown(session.dispose);
      await expectLater(
        session.signIn('any@example.com', 'any'),
        throwsA(isA<AdminAuthException>()),
      );
      expect(session.signedIn, isFalse);
      expect(session.busy, isFalse);
      source.failNext = true;
      await expectLater(
        session.signIn(
          MockAdminAuthSource.demoEmail,
          MockAdminAuthSource.demoPassword,
        ),
        throwsA(isA<AdminAuthException>()),
      );
      expect(session.signedIn, isFalse);
      await session.signIn(
        MockAdminAuthSource.demoEmail,
        MockAdminAuthSource.demoPassword,
      );
      expect(session.user!.email, MockAdminAuthSource.demoEmail);
      session.signOut();
      expect(session.signedIn, isFalse);
      final fresh = AdminSession(source: source);
      addTearDown(fresh.dispose);
      expect(fresh.signedIn, isFalse);
    },
  );
  test(
    'Duplicate submit is blocked and logout prevents a late login result',
    () async {
      final source = DeferredAuth();
      final active = AdminSession(source: source);
      addTearDown(active.dispose);
      final request = active.signIn('demo', 'demo');
      await active.signIn('demo', 'demo');
      expect(source.calls, 1);
      expect(active.busy, isTrue);
      active.signOut();
      source.gate.complete(
        const AdminUser(id: 'demo', name: 'Demo', email: 'demo@example.com'),
      );
      await request;
      expect(active.signedIn, isFalse);
      expect(active.busy, isFalse);
    },
  );
  test('Disposing a pending session ignores a late result', () async {
    final source = DeferredAuth();
    final session = AdminSession(source: source);
    final request = session.signIn('demo', 'demo');
    session.dispose();
    source.gate.complete(
      const AdminUser(id: 'demo', name: 'Demo', email: 'demo@example.com'),
    );
    await request;
    expect(session.signedIn, isFalse);
  });
}
