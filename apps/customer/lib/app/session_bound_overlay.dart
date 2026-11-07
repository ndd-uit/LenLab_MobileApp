import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

import 'customer_scope.dart';

/// Dialogs/sheets have their own routes, outside the protected page subtree.
class SessionBoundOverlay extends StatelessWidget {
  const SessionBoundOverlay({
    super.key,
    required this.session,
    required this.builder,
  });
  final CustomerSessionStamp session;
  final WidgetBuilder builder;
  @override
  Widget build(BuildContext context) {
    final store = CustomerScope.of(context);
    final route = ModalRoute.of(context);
    if (store.isCurrentSession(session)) return builder(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted &&
          route?.isCurrent == true &&
          Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });
    return const SizedBox.shrink();
  }
}
