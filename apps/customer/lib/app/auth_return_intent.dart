import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

/// Route-local and RAM-only. Never stores a callback that could submit an order.
class AuthReturnIntent {
  const AuthReturnIntent(this.session, this.route, {this.arguments});
  final CustomerSessionStamp session;
  final String route;
  final String? arguments;

  static const privateRoutes = {
    '/checkout',
    '/order-review',
    '/payment-method',
    '/bank-transfer',
    '/cod-confirmation',
    '/orders',
    '/order-detail',
    '/profile',
    '/addresses',
    '/write-review',
    '/support',
  };
  static const checkoutRoutes = {
    '/checkout',
    '/order-review',
    '/payment-method',
    '/bank-transfer',
    '/cod-confirmation',
  };

  factory AuthReturnIntent.forRoute(
    LenlabStore store,
    String route, [
    String? arguments,
  ]) => AuthReturnIntent(
    store.captureSession(),
    checkoutRoutes.contains(route) ? '/cart' : route,
    arguments: checkoutRoutes.contains(route) ? null : arguments,
  );

  void complete(BuildContext context, LenlabStore store) {
    final allowed =
        route == '/cart' ||
        (route == '/product' && (arguments?.trim().isNotEmpty ?? false)) ||
        privateRoutes.contains(route);
    final valid =
        session.userId == null &&
        store.signedIn &&
        store.sessionGeneration == session.generation + 1 &&
        allowed;
    final destination = valid ? route : '/';
    Navigator.pushNamedAndRemoveUntil(
      context,
      destination,
      (route) => destination != '/' && route.settings.name == '/',
      arguments: valid ? arguments : null,
    );
  }
}
