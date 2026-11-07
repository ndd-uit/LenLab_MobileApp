import 'package:flutter/material.dart';

import '../features/auth/presentation/auth_page.dart';
import 'auth_return_intent.dart';
import 'customer_scope.dart';

/// Guards the page itself, including pages opened without named routes.
/// The private builder is never invoked for a Guest.
class CustomerSessionGate extends StatefulWidget {
  const CustomerSessionGate({
    super.key,
    required this.route,
    required this.builder,
    this.arguments,
  });
  final String route;
  final String? arguments;
  final WidgetBuilder builder;
  @override
  State<CustomerSessionGate> createState() => _CustomerSessionGateState();
}

class _CustomerSessionGateState extends State<CustomerSessionGate> {
  AuthReturnIntent? intent;
  @override
  void didUpdateWidget(covariant CustomerSessionGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.route != widget.route ||
        oldWidget.arguments != widget.arguments) {
      intent = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = CustomerScope.of(context);
    if (!store.signedIn) {
      if (intent == null ||
          intent!.session.generation != store.sessionGeneration) {
        intent = AuthReturnIntent.forRoute(
          store,
          widget.route,
          widget.arguments,
        );
      }
    }
    // Keep Auth mounted until it replaces this blocked route. Otherwise the
    // sign-in notification can mount checkout behind the outgoing transition.
    if (intent != null) return AuthPage(returnIntent: intent);
    return KeyedSubtree(
      key: ValueKey((store.userId, store.sessionGeneration)),
      child: Builder(builder: widget.builder),
    );
  }
}
