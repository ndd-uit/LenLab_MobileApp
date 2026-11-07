import '../../../app/session_bound_overlay.dart';
import '../../../app/customer_session_gate.dart';

import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';
import 'package:lenlab_customer/app/customer_scope.dart';
import 'package:lenlab_customer/app/navigation.dart';

import 'address_styles.dart';
import 'widgets/address_field.dart';
import 'widgets/address_select.dart';
import 'widgets/checkout_header.dart';

class AddressPage extends StatelessWidget {
  const AddressPage({super.key, this.source, this.returnToReview = false});
  final CheckoutAddressSource? source;
  final bool returnToReview;
  @override
  Widget build(BuildContext context) => CustomerSessionGate(
    route: '/checkout',
    builder: (_) =>
        _AddressPageContent(source: source, returnToReview: returnToReview),
  );
}

class _AddressPageContent extends StatefulWidget {
  const _AddressPageContent({this.source, this.returnToReview = false});
  final CheckoutAddressSource? source;
  final bool returnToReview;
  @override
  State<_AddressPageContent> createState() => _AddressPageState();
}

class _AddressPageState extends State<_AddressPageContent> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController();
  final phone = TextEditingController();
  final street = TextEditingController();
  CheckoutAddressSource? source;
  Future<AddressOptions>? request;
  AddressOptions? loaded;
  Address? selected;
  String? city, district, ward, error;
  bool save = false, busy = false, attempted = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (source != null || CustomerScope.of(context).checkoutLines.isEmpty) {
      return;
    }
    source =
        widget.source ?? MockCheckoutAddressSource(CustomerScope.of(context));
    name.text = CustomerScope.of(context).profile.name;
    phone.text = CustomerScope.of(context).profile.phone;
    request = source!.load();
    final draft = CustomerScope.of(context).deliveryAddress;
    if (draft != null) fill(draft);
  }

  void fill(Address address) {
    selected = address;
    name.text = address.name;
    phone.text = address.phone;
    street.text = address.street;
    city = address.city;
    district = address.district;
    ward = address.ward;
  }

  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    street.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (busy) return;
    setState(() {
      attempted = true;
      error = null;
    });
    if (!form.currentState!.validate()) return;
    final store = CustomerScope.of(context);
    final actor = store.captureSession();
    if (store.checkoutLines.isEmpty) return;
    FocusScope.of(context).unfocus();
    final address = Address(
      name: name.text.trim(),
      phone: phone.text.trim(),
      street: street.text.trim(),
      city: city!,
      district: district!,
      ward: ward!,
      isDefault: selected?.isDefault ?? false,
    );
    setState(() => busy = true);
    try {
      if (save) await source!.save(address, replacing: selected);
      if (!mounted || !store.isCurrentSession(actor)) return;
      store.deliveryAddress = address;
      if (save) {
        final saved = loaded!.saved;
        final index = selected == null ? -1 : saved.indexOf(selected!);
        if (index >= 0) {
          saved[index] = address;
        } else if (!saved.any(
          (a) =>
              a.name == address.name &&
              a.phone == address.phone &&
              a.full == address.full,
        )) {
          saved.add(address);
        }
        selected = address;
      }
      store.changed();
      if (widget.returnToReview) {
        Navigator.pop(context, address);
      } else {
        go(context, '/order-review', address);
      }
    } catch (e) {
      if (mounted && store.isCurrentSession(actor)) {
        setState(
          () => error = e is RepositoryException
              ? e.message
              : 'Không thể lưu địa chỉ. Vui lòng thử lại.',
        );
      }
    } finally {
      if (mounted && store.isCurrentSession(actor)) {
        setState(() => busy = false);
      }
    }
  }

  Future<void> chooseSaved(List<Address> addresses) async {
    final store = CustomerScope.of(context);
    final actor = store.captureSession();
    final result = await showModalBottomSheet<Address>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SessionBoundOverlay(
        session: actor,
        builder: (context) => SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Địa chỉ đã lưu',
                    style: addressSerif(22, weight: FontWeight.w700),
                  ),
                  if (addresses.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'Chưa có địa chỉ đã lưu. Bạn có thể nhập địa chỉ bên dưới.',
                      ),
                    ),
                  for (final address in addresses)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('${address.name} · ${address.phone}'),
                      subtitle: Text(address.full),
                      onTap: () => Navigator.pop(context, address),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    if (result != null && mounted && store.isCurrentSession(actor)) {
      setState(() {
        fill(result);
        error = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = CustomerScope.of(context);
    return Scaffold(
      appBar: const CheckoutHeader(),
      body: SafeArea(
        top: false,
        child: store.checkoutLines.isEmpty
            ? Center(
                child: EmptyPanel(
                  store.cart.isEmpty
                      ? 'Giỏ hàng đang trống'
                      : 'Chưa chọn sản phẩm thanh toán',
                  action: P2Button(
                    store.cart.isEmpty ? 'Tiếp tục mua sắm' : 'Chọn sản phẩm',
                    onPressed: () =>
                        go(context, store.cart.isEmpty ? '/products' : '/cart'),
                  ),
                ),
              )
            : FutureBuilder<AddressOptions>(
                future: request,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(
                      child: CircularProgressIndicator(
                        semanticsLabel: 'Đang tải địa chỉ',
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: EmptyPanel(
                        'Không thể tải địa chỉ',
                        description: 'Vui lòng kiểm tra kết nối và thử lại.',
                        action: P2Button(
                          'Thử lại',
                          onPressed: () => setState(() {
                            request = source!.load();
                          }),
                        ),
                      ),
                    );
                  }
                  final options = snapshot.data!;
                  loaded = options;
                  return Form(
                    key: form,
                    autovalidateMode: attempted
                        ? AutovalidateMode.onUserInteraction
                        : AutovalidateMode.disabled,
                    child: SingleChildScrollView(
                      key: const ValueKey('address-scroll'),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: P2.rose,
                              border: Border.all(color: P2.brown, width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sử dụng địa chỉ đã lưu',
                                  style: addressSerif(
                                    16,
                                    weight: FontWeight.w700,
                                    color: P2.ink,
                                  ).copyWith(height: 1.25),
                                ),
                                Text(
                                  'Chọn nhanh từ sổ địa chỉ của bạn',
                                  style: addressSerif(
                                    14,
                                    color: const Color(0xFF523A30),
                                  ).copyWith(height: 20 / 14),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 20,
                                  child: OverflowBox(
                                    maxHeight: 44,
                                    alignment: Alignment.centerLeft,
                                    child: TextButton(
                                      onPressed: busy
                                          ? null
                                          : () => chooseSaved(options.saved),
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        alignment: Alignment.centerLeft,
                                        foregroundColor: P2.brown,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            'Chọn',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          P2Asset.node(
                                            addressNode,
                                            'imgContainer1',
                                            width: 13.333,
                                            height: 13.333,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          AddressField(
                            label: 'Họ và tên',
                            child: TextFormField(
                              key: const ValueKey('address-name'),
                              controller: name,
                              enabled: !busy,
                              style: addressSerif(16),
                              decoration: addressDecoration('Họ và tên'),
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.name],
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Vui lòng nhập họ và tên.'
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 20),
                          AddressField(
                            label: 'Số điện thoại',
                            child: TextFormField(
                              key: const ValueKey('address-phone'),
                              controller: phone,
                              enabled: !busy,
                              style: addressSerif(16),
                              decoration: addressDecoration('Số điện thoại'),
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [
                                AutofillHints.telephoneNumberNational,
                              ],
                              validator: (v) =>
                                  RegExp(r'^0\d{9}$').hasMatch(v?.trim() ?? '')
                                  ? null
                                  : 'Số điện thoại gồm 10 chữ số, bắt đầu bằng 0.',
                            ),
                          ),
                          const SizedBox(height: 20),
                          AddressSelect(
                            label: 'Tỉnh / Thành phố',
                            hint: 'Chọn Tỉnh/Thành phố',
                            value: city,
                            options: options.regions.keys.toList(),
                            enabled: !busy,
                            onChanged: (v) => setState(() {
                              city = v;
                              district = null;
                              ward = null;
                            }),
                          ),
                          const SizedBox(height: 20),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final districtField = AddressSelect(
                                label: 'Quận / Huyện',
                                hint: 'Chọn Quận',
                                value: district,
                                options:
                                    options.regions[city]?.keys.toList() ?? [],
                                enabled: !busy && city != null,
                                onChanged: (v) => setState(() {
                                  district = v;
                                  ward = null;
                                }),
                              );
                              final wardField = AddressSelect(
                                label: 'Phường / Xã',
                                hint: 'Chọn Phường',
                                value: ward,
                                options: options.regions[city]?[district] ?? [],
                                enabled: !busy && district != null,
                                onChanged: (v) => setState(() => ward = v),
                              );
                              if (MediaQuery.textScalerOf(context).scale(16) >
                                  16) {
                                return Column(
                                  children: [
                                    districtField,
                                    const SizedBox(height: 20),
                                    wardField,
                                  ],
                                );
                              }
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: districtField),
                                  const SizedBox(width: 16),
                                  Expanded(child: wardField),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          AddressField(
                            label: 'Địa chỉ cụ thể',
                            child: TextFormField(
                              key: const ValueKey('address-street'),
                              controller: street,
                              enabled: !busy,
                              minLines: 2,
                              maxLines: 4,
                              style: addressSerif(16),
                              decoration: addressDecoration(
                                'Số nhà, tên đường, toà nhà...',
                              ),
                              autofillHints: const [
                                AutofillHints.streetAddressLine1,
                              ],
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Vui lòng nhập địa chỉ cụ thể.'
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 28),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Lưu địa chỉ này',
                                      style: addressSerif(16),
                                    ),
                                    const Text(
                                      'Lưu thông tin cho lần mua hàng sau',
                                      style: TextStyle(
                                        fontSize: 14,
                                        height: 20 / 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: save,
                                activeTrackColor: P2.brown,
                                onChanged: busy
                                    ? null
                                    : (v) => setState(() => save = v),
                              ),
                            ],
                          ),
                          if (error != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Text(
                                error!,
                                style: const TextStyle(
                                  color: Color(0xFF94291C),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      bottomNavigationBar: store.checkoutLines.isEmpty
          ? null
          : FutureBuilder<AddressOptions>(
              future: request,
              builder: (context, snapshot) => Material(
                color: P2.rose,
                child: SafeArea(
                  top: false,
                  minimum: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed:
                        busy ||
                            snapshot.connectionState != ConnectionState.done ||
                            !snapshot.hasData
                        ? null
                        : submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: P2.checkoutButton,
                      foregroundColor: const Color(0xFF523A30),
                      minimumSize: const Size(double.infinity, 56),
                    ),
                    child: Text(
                      busy ? 'Đang lưu địa chỉ…' : 'Xem lại đơn hàng',
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
