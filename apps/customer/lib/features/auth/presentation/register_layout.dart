import 'package:flutter/material.dart';

import 'auth_validators.dart';

import 'package:lenlab_shared/lenlab_shared.dart';

import './widgets/auth_widgets.dart';

/// P2 User 2026:59 and 2032:113. Uses the existing mock authentication flow.
class RegisterLayout extends StatefulWidget {
  const RegisterLayout({
    super.key,
    required this.formKey,
    required this.name,
    required this.identity,
    required this.password,
    required this.repeat,
    required this.hidden,
    required this.busy,
    required this.error,
    required this.onTogglePassword,
    required this.onSubmit,
    required this.onGoogle,
    required this.onLogin,
  });
  final GlobalKey<FormState> formKey;
  final TextEditingController name, identity, password, repeat;
  final bool hidden, busy;
  final String? error;
  final VoidCallback onTogglePassword, onSubmit, onGoogle, onLogin;
  @override
  State<RegisterLayout> createState() => _RegisterLayoutState();
}

class _RegisterLayoutState extends State<RegisterLayout> {
  bool attempted = false;
  void submit() {
    if (widget.busy) return;
    setState(() => attempted = true);
    widget.onSubmit();
  }

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
                        key: widget.formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const AuthBanner(),
                            const SizedBox(height: 24),
                            const Text(
                              'Tạo tài khoản mới',
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
                              'Gia nhập cộng đồng yêu len thủ công bền vững',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: authFont,
                                fontSize: 16,
                                height: 1.5,
                                letterSpacing: -1,
                                color: P2.brown,
                              ),
                            ),
                            const SizedBox(height: 24),
                            if (widget.error != null)
                              Notice(widget.error!, error: true),
                            AuthField(
                              label: 'Họ và tên',
                              hint: 'Họ và tên',
                              controller: widget.name,
                              validator: requiredText,
                              p2Validation: true,
                              autofillHints: const [AutofillHints.name],
                              suffix: Center(
                                child: P2Asset.node(
                                  '2026:59',
                                  'imgContainer',
                                  width: 16,
                                  height: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            AuthField(
                              label: 'Email hoặc số điện thoại',
                              hint: 'Email hoặc số điện thoại',
                              controller: widget.identity,
                              validator: (v) => (v ?? '').contains('@')
                                  ? emailValidator(v)
                                  : phoneValidator(v),
                              letterSpacing: 0,
                              p2Validation: true,
                              autofillHints: const [AutofillHints.username],
                              suffix: Center(
                                child: P2Asset.node(
                                  '2026:59',
                                  'imgContainer1',
                                  width: 20,
                                  height: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            AuthField(
                              label: 'Mật khẩu',
                              hint: 'Mật khẩu',
                              controller: widget.password,
                              obscure: widget.hidden,
                              p2Validation: true,
                              autofillHints: const [AutofillHints.newPassword],
                              validator: (v) => (v ?? '').isEmpty
                                  ? 'Vui lòng nhập mật khẩu.'
                                  : null,
                              suffix: IconButton(
                                tooltip: widget.hidden
                                    ? 'Hiện mật khẩu'
                                    : 'Ẩn mật khẩu',
                                onPressed: widget.onTogglePassword,
                                icon: P2Asset.node(
                                  '2026:59',
                                  'imgContainer2',
                                  width: 22,
                                  height: 15,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ListenableBuilder(
                              listenable: Listenable.merge([
                                widget.password,
                                widget.repeat,
                              ]),
                              builder: (context, _) {
                                final mismatch =
                                    attempted &&
                                    widget.repeat.text != widget.password.text;
                                return AuthField(
                                  label: 'Xác nhận mật khẩu',
                                  hint: 'Xác nhận mật khẩu',
                                  controller: widget.repeat,
                                  obscure: widget.hidden,
                                  p2Validation: true,
                                  autofillHints: const [
                                    AutofillHints.newPassword,
                                  ],
                                  autovalidateMode: attempted
                                      ? AutovalidateMode.always
                                      : AutovalidateMode.disabled,
                                  validator: (v) => v != widget.password.text
                                      ? 'Mật khẩu xác nhận chưa khớp. Nhập lại mật khẩu.'
                                      : null,
                                  onSubmitted: (_) => submit(),
                                  suffix: mismatch
                                      ? null
                                      : Center(
                                          child: P2Asset.node(
                                            '2026:59',
                                            'imgContainer3',
                                            width: 20,
                                            height: 20,
                                          ),
                                        ),
                                );
                              },
                            ),
                            const SizedBox(height: 32),
                            AuthButton(
                              label: widget.busy ? 'Đang đăng ký…' : 'Đăng ký',
                              onPressed: widget.busy ? null : submit,
                              busy: widget.busy,
                              color: P2.authButton,
                              fontSize: widget.busy ? 14 : 18,
                              lineHeight: widget.busy ? 22 / 14 : 28 / 18,
                              shadows: authShadow,
                            ),
                            const SizedBox(height: 24),
                            LayoutBuilder(
                              builder: (context, available) => Row(
                                children: [
                                  const Expanded(
                                    child: Divider(
                                      height: 1,
                                      thickness: 1,
                                      color: Color(0xFF374151),
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
                                        'Hoặc tiếp tục với',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: authFont,
                                          fontSize: 14,
                                          height: 20 / 14,
                                          fontWeight: FontWeight.w500,
                                          color: authText,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Expanded(
                                    child: Divider(
                                      height: 1,
                                      thickness: 1,
                                      color: Color(0xFF374151),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            AuthButton(
                              label: 'Google',
                              onPressed: widget.onGoogle,
                              fontSize: 16,
                              lineHeight: 1.5,
                              color: Color.alphaBlend(
                                const Color(0x0F6B4B3E),
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
                            const SizedBox(height: 22),
                            TextButton(
                              onPressed: widget.onLogin,
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
                                    TextSpan(text: 'Đã có tài khoản? '),
                                    TextSpan(
                                      text: 'Đăng nhập ngay',
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
