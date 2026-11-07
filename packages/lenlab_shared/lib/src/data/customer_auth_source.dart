import '../domain/customer_identity.dart';
import 'lenlab_repository.dart';

abstract interface class CustomerAuthSource {
  Future<CustomerIdentity> signIn({
    required String identity,
    required String password,
  });
  Future<CustomerIdentity> register({
    required String name,
    required String identity,
    required String password,
  });
}

const mockCustomerAId = 'customer-demo-a';
const mockCustomerA = CustomerIdentity(
  id: mockCustomerAId,
  name: 'Nguyễn Văn A',
  email: 'nguyenvan.a@example.com',
  phone: '0901234567',
);
const mockCustomerB = CustomerIdentity(
  id: 'customer-demo-b',
  name: 'Nguyễn Văn B',
  email: 'nguyenvan.b@example.com',
  phone: '0901234568',
);

/// RAM-only identity simulation. Any nonempty password is accepted; passwords
/// are never saved, logged, or compared with real credentials.
class MockCustomerAuthSource implements CustomerAuthSource {
  MockCustomerAuthSource({
    List<CustomerIdentity> accounts = const [mockCustomerA, mockCustomerB],
    this.latency = const Duration(milliseconds: 300),
    this.operation,
  }) {
    for (final account in accounts) {
      if (account.id.trim().isEmpty || !_ids.add(account.id)) {
        throw ArgumentError('Mock customer IDs must be nonempty and unique.');
      }
      final aliases = [
        account.email,
        account.phone,
      ].where((value) => value.trim().isNotEmpty);
      if (aliases.isEmpty) {
        throw ArgumentError('Mock customer needs an email or phone.');
      }
      for (final alias in aliases) {
        final key = _key(alias);
        if (_accounts.containsKey(key)) {
          throw ArgumentError('Duplicate mock login identity.');
        }
        _accounts[key] = account;
      }
    }
  }

  final Duration latency;
  final Future<void> Function(String)? operation;
  final _accounts = <String, CustomerIdentity>{};
  final _ids = <String>{};
  int _nextId = 1;

  String _key(String value) => value.trim().toLowerCase();
  Future<void> _operation(String name) =>
      operation?.call(name) ?? Future<void>.delayed(latency);

  void _validate(String identity, String password) {
    final key = _key(identity);
    final valid = key.contains('@')
        ? RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(key)
        : RegExp(r'^0\d{9}$').hasMatch(key);
    if (!valid || password.isEmpty) {
      throw const RepositoryException(
        'Email/số điện thoại hoặc mật khẩu chưa hợp lệ.',
      );
    }
  }

  @override
  Future<CustomerIdentity> signIn({
    required String identity,
    required String password,
  }) async {
    _validate(identity, password);
    await _operation('login');
    final account = _accounts[_key(identity)];
    if (account == null) {
      throw const RepositoryException(
        'Không tìm thấy tài khoản mock. Vui lòng đăng ký hoặc dùng tài khoản demo.',
      );
    }
    return account;
  }

  @override
  Future<CustomerIdentity> register({
    required String name,
    required String identity,
    required String password,
  }) async {
    _validate(identity, password);
    if (name.trim().isEmpty) {
      throw const RepositoryException('Vui lòng nhập họ tên.');
    }
    await _operation('register');
    final key = _key(identity);
    if (_accounts.containsKey(key)) {
      throw const RepositoryException(
        'Email/số điện thoại đã được đăng ký trong mock.',
      );
    }
    String id;
    do {
      id = 'customer-mock-registered-${_nextId++}';
    } while (_ids.contains(id));
    final account = CustomerIdentity(
      id: id,
      name: name.trim(),
      email: key.contains('@') ? key : '',
      phone: key.contains('@') ? '' : key,
    );
    _ids.add(id);
    _accounts[key] = account;
    return account;
  }
}

/// A non-mock product repository must not silently enable mock authentication.
class UnconfiguredCustomerAuthSource implements CustomerAuthSource {
  const UnconfiguredCustomerAuthSource();
  @override
  Future<CustomerIdentity> signIn({
    required String identity,
    required String password,
  }) async =>
      throw const RepositoryException('Chưa cấu hình dịch vụ đăng nhập.');
  @override
  Future<CustomerIdentity> register({
    required String name,
    required String identity,
    required String password,
  }) async => throw const RepositoryException('Chưa cấu hình dịch vụ đăng ký.');
}
