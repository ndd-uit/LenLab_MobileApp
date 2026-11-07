import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

class CustomerScope extends InheritedNotifier<LenlabStore> {
  const CustomerScope({
    super.key,
    required LenlabStore store,
    required super.child,
  }) : super(notifier: store);
  static LenlabStore of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CustomerScope>()!.notifier!;
}
