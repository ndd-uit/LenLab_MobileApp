import 'package:flutter/material.dart';

class AdminCustomerDetailOrigin {
  const AdminCustomerDetailOrigin();
}

Future<void> openAdminCustomerDetail(BuildContext context, String id) =>
    Navigator.of(context).pushNamed<void>(
      Uri(path: '/customers/detail', queryParameters: {'id': id}).toString(),
      arguments: const AdminCustomerDetailOrigin(),
    );

void backToAdminCustomers(BuildContext context) {
  final navigator = Navigator.of(context);
  if (ModalRoute.of(context)?.settings.arguments is AdminCustomerDetailOrigin &&
      navigator.canPop()) {
    navigator.pop();
  } else {
    navigator.pushReplacementNamed('/customers');
  }
}
