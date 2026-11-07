import '../../../app/customer_session_gate.dart';

import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';
import 'package:lenlab_customer/app/customer_scope.dart';
import 'package:lenlab_customer/app/navigation.dart';
import 'package:lenlab_customer/shared/widgets/header_widgets.dart';

import '../data/profile_source.dart';
import 'widgets/profile_section.dart';
import 'widgets/profile_avatar.dart';
import 'profile_editor_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, this.source});
  final ProfileSource? source;
  @override
  Widget build(BuildContext context) => CustomerSessionGate(
    route: '/profile',
    builder: (_) => _ProfilePageContent(source: source),
  );
}

class _ProfilePageContent extends StatefulWidget {
  const _ProfilePageContent({this.source});
  final ProfileSource? source;
  @override
  State<_ProfilePageContent> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<_ProfilePageContent> {
  ProfileSource? source;
  Future<ProfileSummary>? request;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final store = CustomerScope.of(context);
    source ??= widget.source ?? MockProfileSource(store);
    if (store.signedIn) request ??= source!.load();
  }

  void retry() => setState(() {
    request = source!.load();
  });
  Future<void> edit() async {
    final store = CustomerScope.of(context);
    final actor = store.captureSession();
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const ProfileEditorPage()),
    );
    if (mounted && store.isCurrentSession(actor) && saved == true) retry();
  }

  @override
  Widget build(BuildContext context) {
    final store = CustomerScope.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 64,
        leadingWidth: 72,
        leading: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: HeaderBackButton(),
        ),
        title: const Text('Hồ sơ của tôi'),
        actions: [
          if (store.signedIn)
            TextButton(
              onPressed: edit,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  P2Asset.node(
                    '2026:244',
                    'imgContainer9',
                    width: 13.5,
                    height: 13.5,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Sửa',
                    style: TextStyle(
                      color: P2.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        top: false,
        child: !store.signedIn
            ? _message(
                'Bạn chưa đăng nhập',
                P2Button('Đăng nhập', onPressed: () => go(context, '/login')),
              )
            : FutureBuilder<ProfileSummary>(
                future: request,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(
                      child: CircularProgressIndicator(
                        semanticsLabel: 'Đang tải hồ sơ',
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return _message(
                      'Không thể tải hồ sơ',
                      P2Button('Thử lại', onPressed: retry),
                    );
                  }
                  final profile = snapshot.data;
                  if (profile == null ||
                      (profile.name.trim().isEmpty &&
                          profile.email.trim().isEmpty)) {
                    return _message(
                      'Chưa có thông tin hồ sơ',
                      P2Button('Thử lại', onPressed: retry),
                    );
                  }
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: ProfileAvatar(
                            file: profile.avatar,
                            bytes: profile.avatarBytes,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          profile.name.trim().isEmpty
                              ? 'Chưa có tên'
                              : profile.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            height: 32 / 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        if (profile.membership?.isNotEmpty ?? false) ...[
                          const SizedBox(height: 4),
                          Text(
                            profile.membership!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 20 / 14,
                              fontWeight: FontWeight.w600,
                              color: P2.ink,
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          profile.email.trim().isEmpty
                              ? 'Chưa có email'
                              : profile.email,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 20 / 14,
                            color: Color(0xFF523A30),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ProfileSection(
                          title: 'MUA SẮM',
                          entries: [
                            ProfileEntry(
                              'Đơn hàng của tôi',
                              'imgContainer1',
                              18,
                              () => go(context, '/orders'),
                              white: true,
                            ),
                            ProfileEntry(
                              'Sổ địa chỉ',
                              'imgContainer3',
                              16,
                              () => go(context, '/addresses'),
                            ),
                            ProfileEntry(
                              'Voucher của tôi',
                              'imgContainer4',
                              19.975,
                              () => go(context, '/vouchers'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        ProfileSection(
                          title: 'CÀI ĐẶT & ỨNG DỤNG',
                          entries: [
                            ProfileEntry(
                              'Cài đặt tài khoản',
                              'imgContainer6',
                              20.1,
                              () => missingSpec(context, 'Cài đặt tài khoản'),
                            ),
                            ProfileEntry(
                              'Trung tâm trợ giúp',
                              'imgContainer7',
                              20,
                              () => go(context, '/faq'),
                              white: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        TextButton(
                          onPressed: () {
                            store.logout();
                            home(context);
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: P2.authButton,
                            foregroundColor: const Color(0xFF523A30),
                            padding: const EdgeInsets.all(17),
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: .52),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: const TextStyle(
                              fontFamily: 'packages/lenlab_shared/BeVietnamPro',
                              fontSize: 16,
                              height: 1.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: const Text('Đăng xuất'),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Phiên bản 1.0.0 (Build 1)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            height: 16 / 12,
                            color: Color(0xFF4B5563),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _message(String title, Widget action) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: EmptyPanel(title, action: action),
    ),
  );
}
