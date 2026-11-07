import 'package:flutter/material.dart';

import 'auth_validators.dart';

import 'package:lenlab_shared/lenlab_shared.dart';

import './widgets/auth_widgets.dart';

/// P2 User 2026:3. Layout only; authentication stays in AuthPage/store.
class LoginLayout extends StatelessWidget {
  const LoginLayout({
    super.key,
    required this.formKey,
    required this.identity,
    required this.password,
    required this.hidden,
    required this.busy,
    required this.error,
    required this.onTogglePassword,
    required this.onSubmit,
    required this.onForgot,
    required this.onGoogle,
    required this.onRegister,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController identity, password;
  final bool hidden, busy;
  final String? error;
  final VoidCallback onTogglePassword, onSubmit, onForgot, onGoogle, onRegister;

  @override
  Widget build(BuildContext context) => Scaffold(
    resizeToAvoidBottomInset: true,
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, viewport) => SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: viewport.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 14),
                    child: AutofillGroup(
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const AuthBanner(),
                            const SizedBox(height: 24),
                            const Text(
                              'Chào mừng bạn trở lại!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: authFont,
                                fontSize: 30,
                                height: 1.25,
                                letterSpacing: -.75,
                                fontWeight: FontWeight.w700,
                                color: P2.brown,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Thế giới len thủ công đang chờ bạn',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: authFont,
                                fontSize: 16,
                                height: 1.5,
                                letterSpacing: -1,
                                color: P2.brown,
                              ),
                            ),
                            const SizedBox(height: 32),
                            AuthField(
                              label: 'Email hoặc số điện thoại',
                              hint: 'Nhập email hoặc số điện thoại',
                              controller: identity,
                              validator: (v) => (v ?? '').contains('@')
                                  ? emailValidator(v)
                                  : phoneValidator(v),
                              autofillHints: const [AutofillHints.username],
                              suffix: Center(
                                child: P2Asset.node(
                                  '2026:3',
                                  'imgContainer',
                                  width: 16,
                                  height: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            AuthField(
                              label: 'Mật khẩu',
                              hint: 'Nhập mật khẩu',
                              controller: password,
                              obscure: hidden,
                              validator: (v) => (v ?? '').isEmpty
                                  ? 'Vui lòng nhập mật khẩu.'
                                  : null,
                              autofillHints: const [AutofillHints.password],
                              onSubmitted: (_) {
                                if (!busy) onSubmit();
                              },
                              suffix: IconButton(
                                tooltip: hidden
                                    ? 'Hiện mật khẩu'
                                    : 'Ẩn mật khẩu',
                                onPressed: onTogglePassword,
                                icon: P2Asset.node(
                                  '2026:3',
                                  'imgContainer1',
                                  width: 22,
                                  height: 15,
                                ),
                              ),
                            ),
                            if (error != null) ...[
                              const SizedBox(height: 6),
                              Semantics(
                                liveRegion: true,
                                child: Text(
                                  error!,
                                  style: const TextStyle(
                                    fontFamily: authFont,
                                    fontSize: 12,
                                    height: 1.5,
                                    color: Color(0xFF94291C),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: onForgot,
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(44, 44),
                                  foregroundColor: P2.ink,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  textStyle: const TextStyle(
                                    fontFamily: authFont,
                                    fontSize: 14,
                                    height: 20 / 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                child: const Text('Quên mật khẩu?'),
                              ),
                            ),
                            const SizedBox(height: 16),
                            AuthButton(
                              label: busy ? 'Đang đăng nhập…' : 'Đăng nhập',
                              onPressed: busy ? null : onSubmit,
                              busy: busy,
                              color: busy
                                  ? P2.authButtonLoading
                                  : P2.authButton,
                              fontSize: busy ? 14 : 18,
                              lineHeight: busy ? 22 / 14 : 28 / 18,
                              shadows: authShadow,
                            ),
                            const SizedBox(height: 32),
                            LayoutBuilder(
                              builder: (context, available) => Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      height: 1,
                                      thickness: 1,
                                      color: Color(0xFFE8DDD0),
                                    ),
                                  ),
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: available.maxWidth - 80,
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: Text(
                                        'Hoặc đăng nhập bằng',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: authFont,
                                          fontSize: 14,
                                          height: 20 / 14,
                                          color: authText,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      height: 1,
                                      thickness: 1,
                                      color: Color(0xFFE8DDD0),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                            AuthButton(
                              label: 'Google',
                              onPressed: onGoogle,
                              fontSize: 16,
                              lineHeight: 1.5,
                              color: Color.alphaBlend(
                                const Color(0x0FB4AEA4),
                                Color.alphaBlend(
                                  const Color(0x78B4AEA4),
                                  P2.cream,
                                ),
                              ),
                              leading: const SizedBox(
                                width: 24,
                                height: 24,
                                child: Center(
                                  child: P2Asset(
                                    '373bd.png',
                                    width: 20,
                                    height: 20,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              shadows: const [
                                BoxShadow(
                                  color: Color(0x1A000000),
                                  offset: Offset(0, 4),
                                  blurRadius: 6,
                                  spreadRadius: -1,
                                ),
                                BoxShadow(
                                  color: Color(0x1A000000),
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                  spreadRadius: -2,
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            TextButton(
                              onPressed: onRegister,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(44, 44),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text.rich(
                                TextSpan(
                                  style: TextStyle(
                                    fontFamily: authFont,
                                    color: authText,
                                    fontSize: 16,
                                    height: 1.5,
                                  ),
                                  children: [
                                    TextSpan(text: 'Chưa có tài khoản? '),
                                    TextSpan(
                                      text: 'Đăng ký ngay',
                                      style: TextStyle(
                                        color: P2.ink,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
