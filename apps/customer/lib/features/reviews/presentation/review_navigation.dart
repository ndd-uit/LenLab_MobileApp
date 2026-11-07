import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

import '../../../app/customer_scope.dart';
import '../../../app/navigation.dart';

void openOrderReview(BuildContext context, String orderId) {
  try {
    CustomerScope.of(context).reviewOrder(orderId);
    go(context, '/write-review', orderId);
  } on RepositoryException catch (error) {
    toast(context, error.message);
  }
}
