import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

import '../../../app/customer_scope.dart';
import '../../../app/navigation.dart';
import '../../../app/auth_return_intent.dart';
import 'login_layout.dart';
import 'register_layout.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key, this.register = false, this.returnIntent});
  final bool register;
  final AuthReturnIntent? returnIntent;
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final form = GlobalKey<FormState>();
  final identity = TextEditingController(),
      password = TextEditingController(),
      name = TextEditingController(),
      repeat = TextEditingController();
  bool hidden = true, busy = false;
  String? error;
  @override
  void dispose() {
    for (final c in [identity, password, name, repeat]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> submit() async {
    if (busy) return;
    if (!form.currentState!.validate()) return;
    final store = CustomerScope.of(context);
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final applied = widget.register
          ? await store.register(
              name: name.text,
              identity: identity.text,
              password: password.text,
              canApply: () => mounted,
            )
          : await store.signIn(
              identity: identity.text,
              password: password.text,
              canApply: () => mounted,
            );
      if (!mounted || !applied) return;
      toast(
        context,
        widget.register ? 'Đăng ký thành công.' : 'Đăng nhập thành công.',
      );
      if (widget.returnIntent case final intent?) {
        intent.complete(context, store);
      } else {
        home(context);
      }
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => !widget.register
      ? LoginLayout(
          formKey: form,
          identity: identity,
          password: password,
          hidden: hidden,
          busy: busy,
          error: error,
          onTogglePassword: () => setState(() => hidden = !hidden),
          onSubmit: submit,
          onForgot: () => missingSpec(context, 'Quên mật khẩu'),
          onGoogle: () => missingSpec(context, 'Đăng nhập Google'),
          onRegister: () => Navigator.pushReplacementNamed(
            context,
            '/register',
            arguments: widget.returnIntent,
          ),
        )
      : RegisterLayout(
          formKey: form,
          name: name,
          identity: identity,
          password: password,
          repeat: repeat,
          hidden: hidden,
          busy: busy,
          error: error,
          onTogglePassword: () => setState(() => hidden = !hidden),
          onSubmit: submit,
          onGoogle: () => missingSpec(context, 'Đăng nhập Google'),
          onLogin: () => Navigator.pushReplacementNamed(
            context,
            '/login',
            arguments: widget.returnIntent,
          ),
        );
}
