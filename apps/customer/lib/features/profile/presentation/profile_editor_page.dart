import '../../../app/customer_session_gate.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lenlab_shared/lenlab_shared.dart';
import 'package:lenlab_customer/app/customer_scope.dart';
import 'package:lenlab_customer/app/navigation.dart';
import 'package:lenlab_customer/shared/widgets/header_widgets.dart';
import 'package:lenlab_customer/features/auth/presentation/auth_validators.dart';

import '../data/profile_editor_source.dart';
import '../data/avatar_picker_source.dart';
import 'widgets/profile_editor_fields.dart';
import 'widgets/profile_avatar.dart';

class ProfileEditorPage extends StatelessWidget {
  const ProfileEditorPage({super.key, this.source, this.avatarPicker});
  final ProfileEditorSource? source;
  final AvatarPickerSource? avatarPicker;
  @override
  Widget build(BuildContext context) => CustomerSessionGate(
    route: '/profile',
    builder: (_) =>
        _ProfileEditorPageContent(source: source, avatarPicker: avatarPicker),
  );
}

class _ProfileEditorPageContent extends StatefulWidget {
  const _ProfileEditorPageContent({this.source, this.avatarPicker});
  final ProfileEditorSource? source;
  final AvatarPickerSource? avatarPicker;
  @override
  State<_ProfileEditorPageContent> createState() => _ProfileEditorPageState();
}

class _ProfileEditorPageState extends State<_ProfileEditorPageContent> {
  ProfileEditorSource? source;
  Future<ProfileDraft>? request;
  ProfileDraft? loaded;
  final form = GlobalKey<FormState>();
  final name = TextEditingController(),
      phone = TextEditingController(),
      email = TextEditingController(),
      birthday = TextEditingController();
  String gender = '';
  bool busy = false;
  bool pickingAvatar = false;
  Uint8List? avatarBytes;
  String? avatarError;
  late final avatarPicker = widget.avatarPicker ?? galleryAvatarPicker;
  String? error;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final store = CustomerScope.of(context);
    source ??= widget.source ?? MockProfileEditorSource(store);
    if (store.signedIn) request ??= loadProfile();
  }

  Future<ProfileDraft> loadProfile() async {
    final store = CustomerScope.of(context);
    final session = store.captureSession();
    final profile = await source!.load();
    store.requireSession(session);
    var preview = profile.avatarBytes;
    try {
      final recovered = await avatarPicker.recover();
      // Native startup recovery has no verifiable RAM owner after restart.
      // Only an explicitly injected, account-scoped adapter can restore a draft.
      if (recovered != null && widget.avatarPicker != null) {
        preview = await validatedAvatar(recovered);
      }
    } catch (_) {
      if (mounted && store.isCurrentSession(session)) {
        avatarError =
            'Không khôi phục được ảnh đã chọn. Bạn có thể chọn lại ảnh.';
      }
    }
    store.requireSession(session);
    if (mounted) avatarBytes = preview;
    return profile;
  }

  Future<void> chooseAvatar() async {
    if (busy || pickingAvatar || !CustomerScope.of(context).signedIn) return;
    final store = CustomerScope.of(context);
    final actor = store.captureSession();
    setState(() {
      pickingAvatar = true;
      avatarError = null;
    });
    try {
      final bytes = await avatarPicker.pick();
      if (bytes == null) return;
      final checked = await validatedAvatar(bytes);
      if (!mounted || !store.isCurrentSession(actor)) return;
      setState(() => avatarBytes = checked);
    } catch (error) {
      if (!mounted || !store.isCurrentSession(actor)) return;
      setState(() {
        avatarError = error is RepositoryException
            ? error.message
            : error is PlatformException &&
                  (error.code == 'photo_access_denied' ||
                      error.code == 'photo_access_restricted')
            ? 'Không có quyền truy cập ảnh. Vui lòng kiểm tra quyền Ảnh của LENLAB trong cài đặt thiết bị.'
            : 'Không thể chọn ảnh. Vui lòng thử lại.';
      });
    } finally {
      if (mounted && store.isCurrentSession(actor)) {
        setState(() => pickingAvatar = false);
      }
    }
  }

  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    email.dispose();
    birthday.dispose();
    super.dispose();
  }

  void fill(ProfileDraft p) {
    loaded = p;
    name.text = p.name;
    phone.text = p.phone;
    email.text = p.email;
    birthday.text = p.birthday;
    gender = p.gender;
  }

  Future<void> save() async {
    final store = CustomerScope.of(context);
    final actor = store.captureSession();
    if (busy || pickingAvatar || !(form.currentState?.validate() ?? false)) {
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await source!.save(
        name: name.text,
        phone: phone.text,
        gender: gender,
        birthday: birthday.text,
        avatarBytes: avatarBytes,
      );
      if (!mounted || !store.isCurrentSession(actor)) return;
      Navigator.pop(context, true);
      toast(context, 'Đã lưu hồ sơ.');
    } catch (e) {
      if (mounted && store.isCurrentSession(actor)) {
        setState(() {
          error = e is RepositoryException
              ? e.message
              : 'Không thể lưu hồ sơ. Vui lòng thử lại.';
        });
      }
    } finally {
      if (mounted && store.isCurrentSession(actor)) {
        setState(() {
          busy = false;
        });
      }
    }
  }

  Future<void> chooseBirthday() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final parsed = parseBirthday(birthday.text);
    final date = await showDatePicker(
      context: context,
      initialDate: parsed == null || parsed.isAfter(today) ? today : parsed,
      firstDate: DateTime(1),
      lastDate: today,
      helpText: 'Chọn ngày sinh',
      cancelText: 'Hủy',
      confirmText: 'Chọn',
    );
    if (date != null && mounted) {
      birthday.text =
          '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year.toString().padLeft(4, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final signedIn = CustomerScope.of(context).signedIn;
    return PopScope(
      canPop: !busy,
      child: IgnorePointer(
        ignoring: busy,
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 64,
            automaticallyImplyLeading: false,
            leadingWidth: 64,
            leading: const Padding(
              padding: EdgeInsets.only(left: 14),
              child: HeaderBackButton(),
            ),
            title: const Text(
              'Chỉnh sửa hồ sơ',
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
            actions: [
              if (signedIn)
                TextButton(
                  onPressed: pickingAvatar ? null : save,
                  child: const Text(
                    'Lưu',
                    style: TextStyle(
                      color: P2.ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          body: SafeArea(
            top: false,
            child: !signedIn
                ? _message(
                    'Bạn chưa đăng nhập',
                    () => go(context, '/login'),
                    'Đăng nhập',
                  )
                : FutureBuilder<ProfileDraft>(
                    future: request,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Center(
                          child: CircularProgressIndicator(
                            semanticsLabel: 'Đang tải hồ sơ chỉnh sửa',
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return _message(
                          'Không thể tải hồ sơ',
                          () => setState(() {
                            request = loadProfile();
                          }),
                          'Thử lại',
                        );
                      }
                      final p = snapshot.data;
                      if (p == null) {
                        return _message(
                          'Chưa có dữ liệu hồ sơ',
                          () => setState(() {
                            request = loadProfile();
                          }),
                          'Thử lại',
                        );
                      }
                      if (loaded == null) fill(p);
                      return Form(
                        key: form,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (error != null) Notice(error!, error: true),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 24,
                                ),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: 128,
                                      height: 128,
                                      child: Stack(
                                        children: [
                                          ProfileAvatar(
                                            file: loaded!.avatar,
                                            bytes: avatarBytes,
                                            size: 128,
                                          ),
                                          Positioned(
                                            right: 0,
                                            bottom: 0,
                                            child: SizedBox(
                                              width: 48,
                                              height: 48,
                                              child: IconButton(
                                                tooltip: 'Đổi ảnh đại diện',
                                                onPressed: pickingAvatar
                                                    ? null
                                                    : chooseAvatar,
                                                style: IconButton.styleFrom(
                                                  backgroundColor: P2.brown,
                                                  side: const BorderSide(
                                                    color: Color(0xFFE8DDD0),
                                                    width: 3,
                                                  ),
                                                ),
                                                icon: P2Asset.node(
                                                  profileEditorNode,
                                                  'imgContainer1',
                                                  width: 16.667,
                                                  height: 15,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextButton(
                                      onPressed: pickingAvatar
                                          ? null
                                          : chooseAvatar,
                                      child: const Text(
                                        'Đổi ảnh đại diện',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: P2.brown,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (pickingAvatar)
                                const LinearProgressIndicator(
                                  semanticsLabel: 'Đang đọc ảnh đại diện',
                                ),
                              if (avatarError != null)
                                Notice(avatarError!, error: true),
                              const SizedBox(height: 8),
                              ProfileEditorField(
                                label: 'Họ và tên',
                                child: TextFormField(
                                  key: const ValueKey('profile-name'),
                                  controller: name,
                                  validator: requiredText,
                                  textInputAction: TextInputAction.next,
                                  decoration: profileEditorDecoration(
                                    icon: 'imgIcon',
                                    width: 13.333,
                                    height: 13.333,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              ProfileEditorField(
                                label: 'Số điện thoại',
                                child: TextFormField(
                                  key: const ValueKey('profile-phone'),
                                  controller: phone,
                                  validator: (v) => phoneValidator(
                                    normalizedProfilePhone(v ?? ''),
                                  ),
                                  keyboardType: TextInputType.phone,
                                  textInputAction: TextInputAction.next,
                                  decoration: profileEditorDecoration(
                                    icon: 'imgIcon1',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              ProfileEditorField(
                                label: 'Email',
                                child: TextFormField(
                                  key: const ValueKey('profile-email'),
                                  controller: email,
                                  readOnly: true,
                                  decoration: profileEditorDecoration(
                                    icon: 'imgIcon2',
                                    width: 13.333,
                                    height: 17.5,
                                    filled: true,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              const ProfilePasswordPlaceholder(),
                              const SizedBox(height: 20),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final g = ProfileEditorField(
                                    label: 'Giới tính',
                                    child: DropdownButtonFormField<String>(
                                      initialValue: gender,
                                      isExpanded: true,
                                      items: [
                                        for (final value in {
                                          '',
                                          'Nam',
                                          'Nữ',
                                          'Khác',
                                          gender,
                                        })
                                          DropdownMenuItem(
                                            value: value,
                                            child: Text(
                                              value.isEmpty
                                                  ? 'Chưa chọn'
                                                  : value,
                                            ),
                                          ),
                                      ],
                                      onChanged: (v) => setState(() {
                                        gender = v ?? '';
                                      }),
                                      icon: P2Asset.node(
                                        profileEditorNode,
                                        'imgImage',
                                        width: 24,
                                        height: 24,
                                      ),
                                      decoration: profileEditorDecoration(),
                                    ),
                                  );
                                  final b = ProfileEditorField(
                                    label: 'Ngày sinh',
                                    child: TextFormField(
                                      key: const ValueKey('profile-birthday'),
                                      controller: birthday,
                                      validator: birthdayError,
                                      keyboardType: TextInputType.datetime,
                                      decoration: profileEditorDecoration(
                                        hint: 'dd/MM/yyyy',
                                        suffix: IconButton(
                                          tooltip: 'Chọn ngày sinh',
                                          onPressed: chooseBirthday,
                                          icon: P2Asset.node(
                                            profileEditorNode,
                                            'imgImage1',
                                            width: 16,
                                            height: 15,
                                          ),
                                        ),
                                      ).copyWith(helperText: 'Ngày/tháng/năm'),
                                    ),
                                  );
                                  return MediaQuery.textScalerOf(context)
                                                  .scale(14) >
                                              14 ||
                                          constraints.maxWidth < 340
                                      ? Column(
                                          children: [
                                            g,
                                            const SizedBox(height: 20),
                                            b,
                                          ],
                                        )
                                      : Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(child: g),
                                            const SizedBox(width: 16),
                                            Expanded(child: b),
                                          ],
                                        );
                                },
                              ),
                              const SizedBox(height: 52),
                              ElevatedButton(
                                onPressed: pickingAvatar ? null : save,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: P2.authButton,
                                  foregroundColor: const Color(0xFF523A30),
                                  minimumSize: const Size.fromHeight(48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  elevation: 4,
                                  shadowColor: Colors.black26,
                                ),
                                child: busy
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('Lưu thay đổi'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }

  Widget _message(String title, VoidCallback action, String label) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: EmptyPanel(title, action: P2Button(label, onPressed: action)),
    ),
  );
}
