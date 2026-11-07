import 'package:flutter/material.dart';

class AdminOrderDetailOrigin {
  const AdminOrderDetailOrigin();
}

Future<void> openAdminOrderDetail(BuildContext context, String id) =>
    Navigator.of(context).pushNamed<void>(
      Uri(path: '/orders/detail', queryParameters: {'id': id}).toString(),
      arguments: const AdminOrderDetailOrigin(),
    );

void backToAdminOrders(BuildContext context) {
  final navigator = Navigator.of(context);
  if (ModalRoute.of(context)?.settings.arguments is AdminOrderDetailOrigin &&
      navigator.canPop()) {
    navigator.pop();
  } else {
    navigator.pushReplacementNamed('/orders');
  }
}
