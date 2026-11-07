import 'package:flutter/material.dart';

void go(BuildContext context, String route, [Object? arguments]) =>
    Navigator.pushNamed(context, route, arguments: arguments);
void home(BuildContext context) =>
    Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
