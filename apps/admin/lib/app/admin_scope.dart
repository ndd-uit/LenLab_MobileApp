import 'package:flutter/widgets.dart';

import 'admin_session.dart';

class AdminScope extends InheritedNotifier<AdminSession> {
  const AdminScope({
    super.key,
    required AdminSession session,
    required super.child,
  }) : super(notifier: session);
  static AdminSession of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AdminScope>()!.notifier!;
}
