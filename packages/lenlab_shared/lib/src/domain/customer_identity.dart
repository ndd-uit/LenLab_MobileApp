/// Mock identity, not a token or proof of backend authorization.
class CustomerIdentity {
  const CustomerIdentity({
    required this.id,
    required this.name,
    this.email = '',
    this.phone = '',
  });
  final String id, name, email, phone;
}

/// Identifies one local session, including a Guest session.
class CustomerSessionStamp {
  const CustomerSessionStamp({required this.userId, required this.generation});
  final String? userId;
  final int generation;
}
