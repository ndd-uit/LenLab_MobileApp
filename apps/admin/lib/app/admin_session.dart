import 'package:flutter/foundation.dart';

import '../features/auth/data/admin_auth_source.dart';

/// In-memory UI session. Real authorization must be enforced by the backend.
class AdminSession extends ChangeNotifier {
  AdminSession({required this.source});
  final AdminAuthSource source;
  AdminUser? _user;
  AdminUser? get user => _user;
  bool get signedIn => _user != null;
  bool _busy = false;
  bool get busy => _busy;
  int _generation = 0;
  bool _disposed = false;

  Future<void> signIn(String email, String password) async {
    if (_busy) return;
    final generation = ++_generation;
    _busy = true;
    notifyListeners();
    try {
      final user = await source.signIn(email, password);
      if (!_disposed && generation == _generation) {
        _user = user;
      }
    } finally {
      if (!_disposed && generation == _generation) {
        _busy = false;
        notifyListeners();
      }
    }
  }

  void signOut() {
    _generation++;
    _user = null;
    _busy = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    super.dispose();
  }
}
