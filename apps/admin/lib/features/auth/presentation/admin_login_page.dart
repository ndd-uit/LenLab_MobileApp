import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

import '../../../app/admin_scope.dart';
import '../../../shared/layout/admin_styles.dart';
import '../data/admin_auth_source.dart';
import 'admin_login_background.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key, this.copyrightYear});
  final int? copyrightYear;
  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final form = GlobalKey<FormState>();
  final email = TextEditingController(), password = TextEditingController();
  String? error;
  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final session = AdminScope.of(context);
    if (session.busy || !form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => error = null);
    try {
      await session.signIn(email.text.trim(), password.text);
      if (mounted &&
          session.signedIn &&
          ModalRoute.of(context)?.settings.name == '/login') {
        Navigator.of(context).pushReplacementNamed('/');
      }
    } catch (e) {
      if (mounted) {
        setState(
          () => error = e is AdminAuthException
              ? e.message
              : 'Không thể đăng nhập. Vui lòng thử lại.',
        );
      }
    }
  }

  InputDecoration decoration(String hint, String asset) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: adminText, fontSize: 16),
    filled: true,
    fillColor: Colors.white,
    prefixIcon: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: P2Asset.node(
        '2026:10729',
        asset,
        width: asset == 'imgContainer' ? 16.667 : 13.333,
        height: asset == 'imgContainer' ? 13.333 : 17.5,
      ),
    ),
    prefixIconConstraints: const BoxConstraints(minWidth: 44, maxWidth: 49),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFE3E0DD)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFE3E0DD)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
    ),
    errorMaxLines: 3,
  );

  @override
  Widget build(BuildContext context) {
    final busy = AdminScope.of(context).busy;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F6),
      body: AdminLoginBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight > 32
                        ? constraints.maxHeight - 32
                        : 0,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: EdgeInsets.all(
                              constraints.maxWidth < 480 ? 24 : 40,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: const Color(0xFFE3E0DD),
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0D000000),
                                  offset: Offset(0, 20),
                                  blurRadius: 40,
                                  spreadRadius: -5,
                                ),
                              ],
                            ),
                            child: Form(
                              key: form,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Center(
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFD1A171)
                                            .withValues(alpha: .1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Opacity(
                                          opacity: .9,
                                          child: P2Asset.node(
                                            '2026:10729',
                                            'imgImage',
                                            width: 48,
                                            height: 48,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'LENLAB Official',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 22,
                                      height: 1.25,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -.33,
                                      color: Color(0xFF161412),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'ADMIN PORTAL',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      height: 20 / 14,
                                      letterSpacing: .35,
                                      color: P2.ink,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  const Text(
                                    'Chào mừng trở lại!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 28,
                                      height: 1.25,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -.7,
                                      color: Color(0xFF161412),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Vui lòng đăng nhập để quản lý cửa hàng',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      height: 1.5,
                                      color: adminText,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  const Text(
                                    'Email',
                                    style: TextStyle(
                                      fontSize: 14,
                                      height: 1.5,
                                      color: Color(0xFF161412),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    key: const ValueKey('admin-email'),
                                    controller: email,
                                    enabled: !busy,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    autocorrect: false,
                                    enableSuggestions: false,
                                    decoration: decoration(
                                      'name@example.com',
                                      'imgContainer',
                                    ),
                                    validator: (value) =>
                                        RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                                            .hasMatch((value ?? '').trim())
                                        ? null
                                        : 'Vui lòng nhập email hợp lệ.',
                                  ),
                                  const SizedBox(height: 20),
                                  const Text(
                                    'Mật khẩu',
                                    style: TextStyle(
                                      fontSize: 14,
                                      height: 1.5,
                                      color: Color(0xFF161412),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    key: const ValueKey('admin-password'),
                                    controller: password,
                                    enabled: !busy,
                                    obscureText: true,
                                    autocorrect: false,
                                    enableSuggestions: false,
                                    textInputAction: TextInputAction.done,
                                    decoration: decoration(
                                      '••••••••',
                                      'imgContainer1',
                                    ),
                                    onFieldSubmitted: (_) => submit(),
                                    validator: (value) =>
                                        value == null || value.isEmpty
                                        ? 'Vui lòng nhập mật khẩu.'
                                        : null,
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    alignment: WrapAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    spacing: 8,
                                    children: [
                                      InkWell(
                                        onTap: busy
                                            ? null
                                            : () => adminPendingNotice(
                                                context,
                                                'Ghi nhớ đăng nhập',
                                                'Phiên mock chỉ được giữ khi ứng dụng đang mở. Chưa hỗ trợ ghi nhớ sau khi tải lại.',
                                              ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 16,
                                                height: 16,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: const Color(
                                                      0xFFD1D5DB,
                                                    ),
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              const Flexible(
                                                child: Text(
                                                  'Ghi nhớ đăng nhập',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: adminText,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: busy
                                            ? null
                                            : () => adminPendingNotice(
                                                context,
                                                'Quên mật khẩu?',
                                                'Khôi phục mật khẩu admin chưa được tích hợp.',
                                              ),
                                        style: TextButton.styleFrom(
                                          foregroundColor: P2.ink,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                        ),
                                        child: const Text(
                                          'Quên mật khẩu?',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (error != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: Semantics(
                                        liveRegion: true,
                                        child: Text(
                                          error!,
                                          style: const TextStyle(
                                            color: Color(0xFFB91C1C),
                                            height: 1.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 12),
                                  ElevatedButton(
                                    onPressed: busy ? null : submit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2563EB),
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor: const Color(
                                        0xFF2563EB,
                                      ).withValues(alpha: .6),
                                      minimumSize: const Size.fromHeight(48),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: busy
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text(
                                            'Đăng nhập ngay',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            '© ${widget.copyrightYear ?? DateTime.now().year} LENLAB - Hệ thống quản trị nội bộ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              height: 16 / 12,
                              color: adminText.withValues(alpha: .8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
