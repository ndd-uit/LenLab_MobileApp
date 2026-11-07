import '../../../app/customer_session_gate.dart';

import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';
import 'package:lenlab_customer/app/customer_scope.dart';
import 'package:lenlab_customer/app/navigation.dart';
import 'package:lenlab_customer/shared/widgets/header_widgets.dart';
import 'package:lenlab_customer/features/auth/presentation/auth_validators.dart';

import '../data/address_editor_source.dart';
import 'widgets/address_editor_fields.dart';

class AddressEditorPage extends StatelessWidget {
  const AddressEditorPage({super.key, this.address, this.source});
  final Address? address;
  final AddressEditorSource? source;
  @override
  Widget build(BuildContext context) => CustomerSessionGate(
    route: '/addresses',
    builder: (context) {
      final store = CustomerScope.of(context);
      if (address != null &&
          (address!.ownerId != store.userId ||
              !store.addresses.contains(address))) {
        return const Scaffold(
          body: Center(child: EmptyPanel('Không tìm thấy địa chỉ')),
        );
      }
      return _AddressEditorPageContent(address: address, source: source);
    },
  );
}

class _AddressEditorPageContent extends StatefulWidget {
  const _AddressEditorPageContent({this.address, this.source});
  final Address? address;
  final AddressEditorSource? source;
  @override
  State<_AddressEditorPageContent> createState() => _AddressEditorPageState();
}

class _AddressEditorPageState extends State<_AddressEditorPageContent> {
  final form = GlobalKey<FormState>();
  late final name = TextEditingController(text: widget.address?.name ?? '');
  late final phone = TextEditingController(text: widget.address?.phone ?? '');
  late final street = TextEditingController(text: widget.address?.street ?? '');
  late String? city = widget.address?.city,
      district = widget.address?.district,
      ward = widget.address?.ward;
  AddressEditorSource? source;
  Future<AddressRegions>? request;
  bool busy = false;
  late bool makeDefault = widget.address?.isDefault ?? false;
  String? error;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final store = CustomerScope.of(context);
    source ??= widget.source ?? MockAddressEditorSource(store);
    if (store.signedIn) request ??= source!.loadRegions();
  }

  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    street.dispose();
    super.dispose();
  }

  Future<void> save() async {
    final store = CustomerScope.of(context);
    final actor = store.captureSession();
    if (busy || !(form.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final saved = await source!.save(
        Address(
          name: name.text.trim(),
          phone: phone.text.trim(),
          street: street.text.trim(),
          city: city!,
          district: district!,
          ward: ward!,
          isDefault: makeDefault,
        ),
        replacing: widget.address,
      );
      if (!mounted || !store.isCurrentSession(actor)) return;
      Navigator.pop(context, saved);
      toast(context, 'Đã lưu địa chỉ.');
    } catch (e) {
      if (mounted && store.isCurrentSession(actor)) {
        setState(() {
          error = e is RepositoryException
              ? e.message
              : 'Không thể lưu địa chỉ. Vui lòng thử lại.';
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
            title: Text(
              widget.address == null ? 'Thêm địa chỉ mới' : 'Sửa địa chỉ',
            ),
            actions: [
              if (signedIn)
                TextButton(
                  onPressed: save,
                  child: const Text(
                    'Lưu',
                    style: TextStyle(
                      color: Color(0xFF0F0F0F),
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
                : FutureBuilder<AddressRegions>(
                    future: request,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Center(
                          child: CircularProgressIndicator(
                            semanticsLabel: 'Đang tải địa giới',
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return _message(
                          'Không thể tải dữ liệu địa chỉ',
                          () => setState(() {
                            request = source!.loadRegions();
                          }),
                          'Thử lại',
                        );
                      }
                      final regions = snapshot.data ?? {};
                      if (regions.isEmpty) {
                        return _message(
                          'Chưa có dữ liệu tỉnh/thành phố',
                          () => setState(() {
                            request = source!.loadRegions();
                          }),
                          'Thử lại',
                        );
                      }
                      return Form(
                        key: form,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (error != null) Notice(error!, error: true),
                              _heading('THÔNG TIN LIÊN HỆ'),
                              const SizedBox(height: 16),
                              EditorField(
                                label: 'Họ và tên *',
                                child: TextFormField(
                                  key: const ValueKey('editor-name'),
                                  controller: name,
                                  textInputAction: TextInputAction.next,
                                  validator: requiredText,
                                  decoration: editorDecoration(
                                    'Họ và tên',
                                    asset: 'imgIcon',
                                    iconSize: 13.333,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              EditorField(
                                label: 'Số điện thoại *',
                                child: TextFormField(
                                  key: const ValueKey('editor-phone'),
                                  controller: phone,
                                  keyboardType: TextInputType.phone,
                                  textInputAction: TextInputAction.next,
                                  validator: phoneValidator,
                                  decoration: editorDecoration(
                                    'Số điện thoại',
                                    asset: 'imgIcon1',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              _heading('ĐỊA CHỈ GIAO HÀNG'),
                              const SizedBox(height: 16),
                              EditorRegionSelect(
                                label: 'TỈNH / THÀNH PHỐ',
                                hint: 'Chọn tỉnh / thành phố',
                                value: city,
                                options: regions.keys.toList(),
                                onChanged: (v) => setState(() {
                                  city = v;
                                  district = null;
                                  ward = null;
                                }),
                              ),
                              const SizedBox(height: 16),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final d = EditorRegionSelect(
                                    label: 'QUẬN / HUYỆN',
                                    hint: 'Chọn quận / huyện',
                                    value: district,
                                    small: true,
                                    options: regions[city]?.keys.toList() ?? [],
                                    onChanged: city == null
                                        ? null
                                        : (v) => setState(() {
                                            district = v;
                                            ward = null;
                                          }),
                                  );
                                  final w = EditorRegionSelect(
                                    label: 'PHƯỜNG / XÃ',
                                    hint: 'Chọn phường / xã',
                                    value: ward,
                                    small: true,
                                    options: regions[city]?[district] ?? [],
                                    onChanged: district == null
                                        ? null
                                        : (v) => setState(() {
                                            ward = v;
                                          }),
                                  );
                                  return MediaQuery.textScalerOf(context)
                                                  .scale(14) >
                                              14 ||
                                          constraints.maxWidth < 340
                                      ? Column(
                                          children: [
                                            d,
                                            const SizedBox(height: 16),
                                            w,
                                          ],
                                        )
                                      : Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(child: d),
                                            const SizedBox(width: 12),
                                            Expanded(child: w),
                                          ],
                                        );
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                key: const ValueKey('editor-street'),
                                controller: street,
                                minLines: 3,
                                maxLines: 5,
                                validator: requiredText,
                                decoration: editorDecoration(
                                  'Số nhà, tên đường, tòa nhà, hướng dẫn chi tiết...',
                                ),
                              ),
                              const SizedBox(height: 30),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: P2.rose,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: P2.checkoutButton.withValues(
                                          alpha: .1,
                                        ),
                                      ),
                                      child: P2Asset.node(
                                        addressEditorNode,
                                        'imgContainer2',
                                        width: 16,
                                        height: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Đặt làm mặc định',
                                            style: TextStyle(
                                              fontSize: 16,
                                              height: 1.25,
                                              fontWeight: FontWeight.w700,
                                              color: P2.ink,
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            'Sử dụng địa chỉ này cho đơn hàng tới',
                                            style: TextStyle(
                                              fontSize: 12,
                                              height: 16 / 12,
                                              color: P2.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Switch(
                                      value: makeDefault,
                                      onChanged: (value) {
                                        if (!value &&
                                            widget.address?.isDefault == true) {
                                          toast(
                                            context,
                                            'Hãy chọn địa chỉ khác làm mặc định trong sổ địa chỉ.',
                                          );
                                          return;
                                        }
                                        setState(() => makeDefault = value);
                                      },
                                      inactiveTrackColor: const Color(
                                        0xFF3D342B,
                                      ),
                                      inactiveThumbColor: Colors.white,
                                      activeTrackColor: P2.brown,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: save,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: P2.authButton,
                                  foregroundColor: addressEditorText,
                                  minimumSize: const Size.fromHeight(56),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (busy)
                                      const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    else
                                      P2Asset.node(
                                        addressEditorNode,
                                        'imgContainer3',
                                        width: 20,
                                        height: 20,
                                      ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        busy ? 'Đang lưu…' : 'Lưu địa chỉ',
                                      ),
                                    ),
                                  ],
                                ),
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

  Widget _heading(String text) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w700,
        letterSpacing: .7,
        color: P2.green,
      ),
    ),
  );
  Widget _message(String title, VoidCallback action, String label) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: EmptyPanel(title, action: P2Button(label, onPressed: action)),
    ),
  );
}
