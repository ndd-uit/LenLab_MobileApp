import '../../../app/session_bound_overlay.dart';
import '../../../app/customer_session_gate.dart';

import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';
import 'package:lenlab_customer/app/customer_scope.dart';
import 'package:lenlab_customer/app/navigation.dart';
import 'package:lenlab_customer/shared/widgets/header_widgets.dart';

import '../data/address_book_source.dart';
import '../data/address_book_actions.dart';
import 'widgets/address_book_card.dart';
import 'address_editor_page.dart';

class AddressBookPage extends StatelessWidget {
  const AddressBookPage({super.key, this.source, this.actions});
  final AddressBookSource? source;
  final AddressBookActions? actions;
  @override
  Widget build(BuildContext context) => CustomerSessionGate(
    route: '/addresses',
    builder: (_) => _AddressBookPageContent(source: source, actions: actions),
  );
}

class _AddressBookPageContent extends StatefulWidget {
  const _AddressBookPageContent({this.source, this.actions});
  final AddressBookSource? source;
  final AddressBookActions? actions;
  @override
  State<_AddressBookPageContent> createState() => _AddressBookPageState();
}

class _AddressBookPageState extends State<_AddressBookPageContent> {
  AddressBookSource? source;
  Future<List<Address>>? request;
  late AddressBookActions actions;
  bool busy = false, confirming = false;
  String? actionError;
  VoidCallback? retryAction;
  bool get locked => busy || confirming;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final store = CustomerScope.of(context);
    source ??= widget.source ?? MockAddressBookSource(store);
    actions = widget.actions ?? MockAddressBookActions(store);
    if (store.signedIn) request ??= source!.load();
  }

  void retry() => setState(() {
    request = source!.load();
  });
  Future<void> edit([Address? address]) async {
    if (locked) return;
    final store = CustomerScope.of(context);
    final actor = store.captureSession();
    final saved = await Navigator.push<Address>(
      context,
      MaterialPageRoute(builder: (_) => AddressEditorPage(address: address)),
    );
    if (mounted && store.isCurrentSession(actor) && saved != null) retry();
  }

  Future<void> perform(
    Future<List<Address>> Function() action,
    String success,
  ) async {
    final store = CustomerScope.of(context);
    final actor = store.captureSession();
    if (busy || !store.signedIn) return;
    setState(() {
      busy = true;
      actionError = null;
    });
    try {
      final result = await action();
      if (!mounted || !store.isCurrentSession(actor)) return;
      setState(() {
        request = Future.value(result);
        retryAction = null;
      });
      toast(context, success);
    } catch (error) {
      if (!mounted || !store.isCurrentSession(actor)) return;
      setState(() {
        actionError = error is RepositoryException
            ? error.message
            : 'Không thể cập nhật sổ địa chỉ. Vui lòng thử lại.';
        retryAction = () => perform(action, success);
      });
    } finally {
      if (mounted && store.isCurrentSession(actor)) {
        setState(() => busy = false);
      }
    }
  }

  Future<void> remove(Address address) async {
    if (locked) return;
    final store = CustomerScope.of(context);
    final actor = store.captureSession();
    if (address.ownerId != store.userId) return;
    setState(() => confirming = true);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => SessionBoundOverlay(
        session: actor,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: P2.cream,
          scrollable: true,
          title: const Text('Xóa địa chỉ?', style: TextStyle(color: P2.brown)),
          content: Text(
            '${address.name}\n${address.phone}\n${address.full}\n\nĐịa chỉ trong đơn hàng và thông tin giao hàng đang nhập sẽ được giữ nguyên.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Giữ lại'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(
                'Xóa',
                style: TextStyle(color: Color(0xFF7A2929)),
              ),
            ),
          ],
        ),
      ),
    );
    if (!mounted || !store.isCurrentSession(actor)) return;
    setState(() => confirming = false);
    if (confirmed == true) {
      await perform(() => actions.remove(address), 'Đã xóa địa chỉ.');
    }
  }

  void setDefault(Address address) {
    if (locked || address.isDefault) return;
    perform(() => actions.setDefault(address), 'Đã đổi địa chỉ mặc định.');
  }

  @override
  Widget build(BuildContext context) {
    final signedIn = CustomerScope.of(context).signedIn;
    return PopScope(
      canPop: !busy,
      child: IgnorePointer(
        ignoring: busy,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            toolbarHeight: 65,
            automaticallyImplyLeading: false,
            leadingWidth: 72,
            leading: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: HeaderBackButton(),
            ),
            title: const Text('Sổ địa chỉ'),
            actions: const [SizedBox(width: 72)],
          ),
          body: SafeArea(
            top: false,
            child: Column(
              children: [
                if (signedIn && busy)
                  const LinearProgressIndicator(
                    semanticsLabel: 'Đang cập nhật sổ địa chỉ',
                  ),
                if (signedIn && actionError != null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          actionError!,
                          style: const TextStyle(color: Color(0xFF7A2929)),
                        ),
                        TextButton(
                          onPressed: retryAction,
                          child: const Text('Thử lại'),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              actionError = null;
                              retryAction = null;
                            });
                            retry();
                          },
                          child: const Text('Tải lại sổ địa chỉ'),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: !signedIn
                      ? _message(
                          'Bạn chưa đăng nhập',
                          P2Button(
                            'Đăng nhập',
                            onPressed: () => go(context, '/login'),
                          ),
                        )
                      : FutureBuilder<List<Address>>(
                          future: request,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState !=
                                ConnectionState.done) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  semanticsLabel: 'Đang tải sổ địa chỉ',
                                ),
                              );
                            }
                            if (snapshot.hasError) {
                              return _message(
                                'Không thể tải sổ địa chỉ',
                                P2Button('Thử lại', onPressed: retry),
                              );
                            }
                            final addresses = snapshot.data ?? [];
                            if (addresses.isEmpty) {
                              return _message(
                                'Bạn chưa có địa chỉ đã lưu',
                                P2Button('Tải lại', onPressed: retry),
                              );
                            }
                            return ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: addresses.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 16),
                              itemBuilder: (_, index) => AddressBookCard(
                                address: addresses[index],
                                onEdit: () => edit(addresses[index]),
                                onDelete: locked
                                    ? null
                                    : () => remove(addresses[index]),
                                onSetDefault:
                                    locked || addresses[index].isDefault
                                    ? null
                                    : () => setDefault(addresses[index]),
                                alternateDeleteIcon: index.isEven,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: !signedIn
              ? null
              : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [P2.rose.withValues(alpha: 0), P2.rose],
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    minimum: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: ElevatedButton(
                      onPressed: edit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: P2.authButton,
                        foregroundColor: const Color(0xFF523A30),
                        minimumSize: const Size.fromHeight(56),
                        elevation: 4,
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          P2Asset.node(
                            '2026:4234',
                            'imgContainer7',
                            width: 14,
                            height: 14,
                          ),
                          const SizedBox(width: 8),
                          const Flexible(
                            child: Text(
                              'Thêm địa chỉ mới',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
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
