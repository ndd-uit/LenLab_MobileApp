import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lenlab_shared/lenlab_shared.dart';
import 'package:lenlab_customer/app/customer_scope.dart';
import 'package:lenlab_customer/shared/widgets/header_widgets.dart';

import '../data/voucher_source.dart';
import '../data/voucher_eligibility_source.dart';
import 'widgets/voucher_card.dart';
import 'widgets/voucher_button.dart';
import 'widgets/voucher_card_layout.dart';

class VoucherPage extends StatelessWidget {
  const VoucherPage({
    super.key,
    this.source,
    this.copyCode,
    this.eligibilitySource,
  });
  final VoucherSource? source;
  final Future<void> Function(String)? copyCode;
  final VoucherEligibilitySource? eligibilitySource;
  @override
  Widget build(BuildContext context) {
    final store = CustomerScope.of(context);
    return KeyedSubtree(
      key: ValueKey((store.userId, store.sessionGeneration)),
      child: _VoucherPageContent(
        source: source,
        copyCode: copyCode,
        eligibilitySource: eligibilitySource,
      ),
    );
  }
}

class _VoucherPageContent extends StatefulWidget {
  const _VoucherPageContent({
    this.source,
    this.copyCode,
    this.eligibilitySource,
  });
  final VoucherSource? source;
  final Future<void> Function(String)? copyCode;
  final VoucherEligibilitySource? eligibilitySource;
  @override
  State<_VoucherPageContent> createState() => _VoucherPageState();
}

class _VoucherPageState extends State<_VoucherPageContent> {
  final code = TextEditingController();
  VoucherSource? source;
  Future<List<WalletVoucher>>? request;
  String? inputError;
  CustomerSessionStamp? session;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final store = CustomerScope.of(context);
    session ??= store.captureSession();
    source ??= widget.source ?? MockVoucherSource(store);
    request ??= source!.load();
  }

  @override
  void dispose() {
    code.dispose();
    super.dispose();
  }

  void retry() {
    if (!canAct) return;
    setState(() {
      request = source!.load();
    });
  }

  Future<void> apply() async {
    if (!canAct) return;
    setState(() {
      inputError = code.text.trim().isEmpty
          ? 'Vui lòng nhập mã voucher.'
          : null;
    });
    if (inputError == null) {
      FocusScope.of(context).unfocus();
      await evaluate(code: code.text);
    }
  }

  bool get canAct =>
      mounted &&
      ModalRoute.of(context)?.isCurrent == true &&
      session != null &&
      CustomerScope.of(context).isCurrentSession(session!);

  Future<void> choose(WalletVoucher voucher) async {
    if (!canAct || voucher.status != WalletVoucherStatus.available) return;
    await evaluate(campaignId: voucher.id, returnToCart: true);
  }

  Future<void> evaluate({
    String? campaignId,
    String? code,
    bool returnToCart = false,
  }) async {
    if (!canAct) return;
    final store = CustomerScope.of(context);
    try {
      final result = await store.evaluateVoucher(
        widget.eligibilitySource ?? MockVoucherEligibilitySource(store),
        campaignId: campaignId,
        code: code,
        canApply: () => canAct,
      );
      if (!mounted || !canAct || result == null) return;
      toast(context, evaluationMessage(result));
      if (returnToCart) backToCart();
    } catch (_) {
      if (mounted && canAct) {
        toast(context, 'Không thể kiểm tra voucher. Vui lòng thử lại.');
      }
    }
  }

  String evaluationMessage(VoucherEvaluation result) {
    if (result.status == VoucherEligibilityStatus.eligible ||
        result.reason == 'AUTH_REQUIRED') {
      final preview =
          'Ưu đãi ước tính: giảm tiền hàng ${money(result.itemsDiscountVnd)}, '
          'giảm phí ship ${money(result.shippingDiscountVnd)}.';
      final remaining = result.remainingShippingVnd == null
          ? ''
          : ' Phí ship còn trả ${money(result.remainingShippingVnd!)}.';
      return '$preview$remaining ${result.reason == 'AUTH_REQUIRED' ? 'Đăng nhập để kiểm tra điều kiện cá nhân.' : 'Chưa đồng bộ tổng tiền đặt đơn (V04).'}';
    }
    return switch (result.reason) {
      'EMPTY_SELECTION' => 'Chọn sản phẩm trong giỏ để kiểm tra voucher.',
      'CONFIG_INCOMPLETE' => 'Voucher chưa có đủ cấu hình để áp dụng.',
      'TYPE_UNSUPPORTED' => 'Ưu đãi này chưa có quy tắc áp dụng.',
      'MINIMUM_NOT_MET' => 'Các dòng được chọn chưa đạt giá trị tối thiểu.',
      'SHIPPING_CONTEXT_REQUIRED' =>
        'Cần địa chỉ và phí vận chuyển để kiểm tra ưu đãi.',
      'LEGACY_COUPON_CONFLICT' =>
        'Giỏ đang có coupon khác. Không cộng dồn hoặc tự thay mã.',
      'CUSTOMER_LIMIT_REACHED' => 'Bạn đã hết lượt sử dụng voucher này.',
      'GLOBAL_QUOTA_EXHAUSTED' => 'Voucher đã hết lượt sử dụng.',
      'NOT_STARTED' => 'Voucher chưa đến thời gian sử dụng.',
      'EXPIRED' => 'Voucher đã hết hạn.',
      'PRICE_CHANGED' => 'Giá đã thay đổi. Vui lòng kiểm tra lại giỏ.',
      'PRODUCT_UNAVAILABLE' => 'Sản phẩm không còn khả dụng.',
      'QUANTITY_INVALID' => 'Số lượng mua hoặc tồn kho không hợp lệ.',
      _ => 'Voucher không khả dụng hoặc mã không đúng.',
    };
  }

  void backToCart() {
    // Reuse the Cart already in the stack. Profile/direct entry uses the
    // existing named Cart route instead; no CartLine or callback is retained.
    final navigator = Navigator.of(context);
    var foundCart = false;
    navigator.popUntil((route) {
      foundCart = route.settings.name == '/cart';
      return foundCart || route.isFirst;
    });
    if (!foundCart) navigator.pushNamed('/cart');
  }

  Future<void> copy(WalletVoucher voucher) async {
    if (!canAct) return;
    if (voucher.code == null || voucher.code!.trim().isEmpty) {
      toast(context, 'Voucher mẫu này chưa có mã để sao chép.');
      return;
    }
    try {
      await (widget.copyCode?.call(voucher.code!) ??
          Clipboard.setData(ClipboardData(text: voucher.code!)));
      if (mounted && canAct) toast(context, 'Đã sao chép mã voucher.');
    } catch (_) {
      if (mounted && canAct) {
        toast(context, 'Không thể sao chép. Vui lòng thử lại.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 65,
        automaticallyImplyLeading: false,
        leadingWidth: 72,
        leading: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: HeaderBackButton(),
        ),
        title: const Text('Voucher của tôi'),
        actions: const [SizedBox(width: 72)],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: P2.rose,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        P2Asset.node(
                          '2026:4081',
                          'imgContainer1',
                          width: 31.975,
                          height: 26,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: code,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => apply(),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF523A30),
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Nhập mã voucher',
                              filled: false,
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF523A30),
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        VoucherButton('Áp dụng', apply: true, onPressed: apply),
                      ],
                    ),
                  ),
                  if (inputError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        inputError!,
                        style: const TextStyle(color: Color(0xFF7A2929)),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<WalletVoucher>>(
                future: request,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(
                      child: CircularProgressIndicator(
                        semanticsLabel: 'Đang tải voucher',
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return _message(
                      'Không thể tải voucher',
                      P2Button('Thử lại', onPressed: retry),
                    );
                  }
                  final vouchers = snapshot.data ?? [];
                  if (vouchers.isEmpty) {
                    return _message(
                      'Bạn chưa có voucher nào',
                      P2Button('Tải lại', onPressed: retry),
                    );
                  }
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final layout = VoucherCardLayout.measure(
                        vouchers,
                        constraints.maxWidth - 32,
                        MediaQuery.textScalerOf(context),
                        Directionality.of(context),
                      );
                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 48),
                        itemCount: vouchers.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 16),
                        itemBuilder: (_, index) => VoucherCard(
                          voucher: vouchers[index],
                          layout: layout,
                          onUse: () => choose(vouchers[index]),
                          onCopy: () => copy(vouchers[index]),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
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
