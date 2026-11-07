import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../domain/models.dart';
import '../domain/customer_identity.dart';
import '../domain/customer_voucher_candidate.dart';
import '../data/customer_auth_source.dart';
import '../data/voucher_evaluation.dart';
import '../data/checkout_quote.dart';
import '../data/lenlab_repository.dart';
import '../data/mock_lenlab_repository.dart';
import '../data/cod_order_data.dart';
import '../data/cod_checkout_validation.dart';
import '../data/order_review_data.dart';
import '../data/product_review_data.dart';
import '../data/post_purchase_review_data.dart';
import '../data/review_photo.dart';
import 'customer_account_data.dart';
import 'customer_cart_data.dart';
import 'customer_checkout_draft.dart';
import 'session_owned_list.dart';

class LenlabStore extends ChangeNotifier {
  LenlabStore({
    LenlabRepository? repository,
    CustomerAuthSource? authSource,
    List<ProductReview>? productReviews,
    DateTime Function()? voucherClock,
  }) : _voucherClock = voucherClock ?? DateTime.now,
       _productReviews = List.of(productReviews ?? mockProductReviews),
       repository = repository ?? MockLenlabRepository() {
    this.authSource =
        authSource ??
        (this.repository is MockLenlabRepository
            ? MockCustomerAuthSource(
                operation: (name) =>
                    (this.repository as MockLenlabRepository).operation(name),
              )
            : const UnconfiguredCustomerAuthSource());
    final seed = (this.repository is MockLenlabRepository)
        ? (this.repository as MockLenlabRepository).catalog
        : <Product>[];
    if (seed.isEmpty) return;
    Product p(String id) => seed.firstWhere((p) => p.id == id);
    _accounts[fixtureOwnerId]!.cart.lines.addAll([
      CartLine(p('sweater'), variant: 'Xanh đậm · Size M'),
      CartLine(p('gloves'), quantity: 2, variant: 'Xám · Size S'),
    ]);
    _accounts[fixtureOwnerId]!.orders.addAll([
      Order(
        ownerId: fixtureOwnerId,
        id: 'WOOL-8823',
        lines: [
          CartLine(p('sweater'), variant: 'Xanh đậm · Size M'),
          CartLine(p('gloves'), quantity: 2, variant: 'Xám · Size S'),
        ],
        address: const Address(ownerId: fixtureOwnerId),
        discount: 50000,
        state: OrderState.shipping,
        deliveryEstimate: '24 - 26 Tháng 10',
        createdAt: DateTime(2023, 10, 20, 10),
      ),
      Order(
        ownerId: fixtureOwnerId,
        id: 'WOOL-8805',
        lines: [CartLine(p('sheep'))],
        address: const Address(ownerId: fixtureOwnerId),
        state: OrderState.delivered,
        shipping: 0,
      ),
      Order(
        ownerId: fixtureOwnerId,
        id: 'WOOL-8912',
        lines: [CartLine(p('carrot'))],
        address: const Address(ownerId: fixtureOwnerId),
        payment: PaymentState.pending,
      ),
      Order(
        ownerId: fixtureOwnerId,
        id: 'WOOL-8750',
        lines: [CartLine(p('tote'))],
        address: const Address(ownerId: fixtureOwnerId),
        state: OrderState.cancelled,
      ),
    ]);
    _accounts[fixtureOwnerId]!.customs.addAll([
      CustomRequest(
        'CUS-202510',
        'Áo cardigan theo mẫu riêng',
        '0824e.png',
        ownerId: fixtureOwnerId,
      ),
      CustomRequest(
        'CUS-202501',
        'Áo cardigan theo mẫu riêng',
        '30a3f.png',
        ownerId: fixtureOwnerId,
        state: QuoteState.quoted,
      ),
      CustomRequest(
        'CUS-202508',
        'Túi len thiết kế theo yêu cầu',
        '100ec.png',
        ownerId: fixtureOwnerId,
        state: QuoteState.accepted,
        price: 320000,
      ),
      CustomRequest(
        'CUS-202509',
        'Áo len thiết kế theo yêu cầu',
        'c2266.png',
        ownerId: fixtureOwnerId,
        state: QuoteState.rejected,
        price: 420000,
      ),
    ]);
  }
  final LenlabRepository repository;
  late final CustomerAuthSource authSource;
  // Legacy fixtures belong to this declared account, never the first login.
  static const fixtureOwnerId = mockCustomerAId;
  final _accounts = <String, CustomerAccountData>{
    fixtureOwnerId: CustomerAccountData.fixtureA(fixtureOwnerId),
  };
  CustomerAccountData get _account {
    final user = requireCustomer();
    return _accounts.putIfAbsent(user.id, () => CustomerAccountData(user));
  }

  List<T> _ownedList<T>(List<T> items, String? Function(T) ownerOf) {
    final session = captureSession();
    return SessionOwnedList(
      items,
      () => requireSession(session),
      ownerOf,
      requireCustomer().id,
    );
  }

  void requireAddressOwner(Address address, {bool saved = false}) {
    final owner = requireCustomer().id;
    if ((address.ownerId != null && address.ownerId != owner) ||
        (saved && (address.ownerId != owner || !addresses.contains(address)))) {
      throw const RepositoryException(
        'Không thể truy cập địa chỉ của tài khoản khác.',
      );
    }
  }

  Order? findOwnedOrder(String id) {
    final owner = requireCustomer().id;
    final matches = orders
        .where((o) => o.id == id && o.ownerId == owner)
        .toList();
    if (matches.length > 1) {
      throw const RepositoryException('Dữ liệu đơn hàng không hợp lệ.');
    }
    return matches.firstOrNull;
  }

  bool ownsOrder(Order order) =>
      signedIn && order.ownerId == userId && orders.contains(order);
  CustomerIdentity? _currentUser;
  int _sessionGeneration = 0;
  int _authRequestVersion = 0;
  bool _sessionDisposed = false;
  CustomerIdentity? get currentUser => _currentUser;
  String? get userId => _currentUser?.id;
  int get sessionGeneration => _sessionGeneration;
  bool get signedIn => _currentUser != null;

  CustomerVoucherCandidate? _voucherCandidate;
  int _voucherSelectionRevision = 0;
  int get voucherSelectionRevision => _voucherSelectionRevision;

  /// Includes stale applied state, so exit need not depend on quote readiness.
  /// An applied campaign takes precedence over an uncommitted candidate.
  String? get voucherExitCampaignId =>
      _appliedVoucher?.campaignId ??
      _voucherCandidate?.campaignId ??
      _voucherEvaluation?.campaignId ??
      _checkoutQuote?.campaignId;
  CustomerVoucherCandidate? get voucherCandidate =>
      _voucherCandidate != null && isCurrentSession(_voucherCandidate!.session)
      ? _voucherCandidate
      : null;

  /// Records an ID only. Does not evaluate eligibility, totals, or usage.
  void selectVoucherCandidate(
    String campaignId, {
    required CustomerSessionStamp session,
  }) {
    if (!isCurrentSession(session)) {
      throw const RepositoryException('Phiên chọn voucher đã thay đổi.');
    }
    if (campaignId.trim().isEmpty) {
      throw const RepositoryException('Thiếu định danh voucher.');
    }
    _voucherCandidate = CustomerVoucherCandidate(
      campaignId: campaignId,
      session: session,
    );
    _voucherSelectionRevision++;
    notifyListeners();
  }

  /// Removes only the exact promotion selection explicitly acknowledged by
  /// the caller. No pricing-mode change, requote, auth reset or order mutation.
  /// Returns false only for a matching, already-empty selection with no work.
  bool exitVoucher(VoucherExitIntent intent) {
    if (!isCurrentSession(intent.session)) {
      throw const RepositoryException('Phiên bỏ voucher đã thay đổi.');
    }
    if (intent.expectedSelectionRevision != _voucherSelectionRevision ||
        intent.expectedCampaignId != voucherExitCampaignId ||
        intent.expectedLegacyCouponCode != (coupon.isEmpty ? null : coupon)) {
      throw const RepositoryException(
        'Lựa chọn voucher đã thay đổi. Vui lòng kiểm tra lại mã cần bỏ.',
      );
    }
    if (isSubmittingCod) {
      throw const RepositoryException('Đang xử lý đơn. Chưa thể bỏ voucher.');
    }
    final hasWork =
        _voucherCandidate != null ||
        _voucherEvaluation != null ||
        _appliedVoucher != null ||
        coupon.isNotEmpty ||
        _voucherBusyContext != null ||
        _quotePending != null ||
        _checkoutQuote?.campaignId != null;
    if (!hasWork) return false;

    // All validation precedes mutation. Do not call the coupon setter, whose
    // legacy behavior silently ignores writes under an account COD lock.
    if (intent.expectedLegacyCouponCode != null) _cartData.coupon = '';
    _clearVoucherSession();
    _quoteSelectionRevision++;
    notifyListeners();
    return true;
  }

  int _voucherRequest = 0;
  final DateTime Function() _voucherClock;
  VoucherEvaluation? _voucherEvaluation, _appliedVoucher;
  String? _voucherBusyContext;
  bool get isEvaluatingVoucher => _voucherBusyContext == voucherContextKey;
  VoucherEvaluation? get voucherEvaluation =>
      _voucherIsCurrent(_voucherEvaluation) ? _voucherEvaluation : null;
  VoucherEvaluation? get appliedVoucher =>
      _voucherIsCurrent(_appliedVoucher) ? _appliedVoucher : null;
  bool _voucherIsCurrent(VoucherEvaluation? value) =>
      !_sessionDisposed &&
      value != null &&
      value.contextKey == voucherContextKey &&
      (value.validUntil == null || _voucherClock().isBefore(value.validUntil!));
  // A stale selection still needs explicit resolution; never silently buy
  // without the requested promotion. V04 will replace this safety gate.
  bool get hasUnquotedVoucherSelection => _appliedVoucher != null;

  CheckoutQuoteSource? _checkoutQuoteSource;
  CheckoutQuote? _checkoutQuote;
  Future<CheckoutQuote?>? _quotePending;
  String? _quotePendingKey;
  int _quoteRequest = 0;
  int _quoteSelectionRevision = 0;
  void configureCheckoutQuoteSource(CheckoutQuoteSource source) {
    _checkoutQuoteSource = source;
    _quoteRequest++;
    _quoteSelectionRevision++;
    _checkoutQuote = null;
    _quotePending = null;
    _quotePendingKey = null;
    notifyListeners();
  }

  String get checkoutQuoteKey => jsonEncode([
    voucherContextKey,
    _appliedVoucher?.campaignId,
    _quoteSelectionRevision,
  ]);
  CheckoutQuote? get checkoutQuote {
    final q = _checkoutQuote;
    if (_sessionDisposed || q == null) return null;
    if (!isCurrentSession(q.session) || q.contextKey != checkoutQuoteKey) {
      return q.asStale('CONTEXT_CHANGED');
    }
    if (q.expiresAt != null && !_voucherClock().isBefore(q.expiresAt!)) {
      return q.asStale('QUOTE_EXPIRED');
    }
    return q;
  }

  Future<CheckoutQuote?> requestCheckoutQuote({
    CheckoutQuoteSource? source,
    bool force = false,
  }) {
    if (_sessionDisposed) return Future.value(null);
    _checkoutQuoteSource ??= source;
    final context = captureVoucherContext();
    final key = checkoutQuoteKey;
    if (!force && _quotePending != null && key == _quotePendingKey) {
      return _quotePending!;
    }
    if (!force && checkoutQuote?.status == CheckoutQuoteStatus.ready) {
      return Future.value(checkoutQuote);
    }
    final request = ++_quoteRequest;
    _quotePendingKey = key;
    _quotePending = _loadCheckoutQuote(
      CheckoutQuoteRequest(
        context: context,
        key: key,
        campaignId: _appliedVoucher?.campaignId,
      ),
      request,
    );
    return _quotePending!;
  }

  Future<CheckoutQuote?> _loadCheckoutQuote(
    CheckoutQuoteRequest request,
    int sequence,
  ) async {
    CheckoutQuote state(CheckoutQuoteStatus status, String reason) =>
        CheckoutQuote(
          id: '',
          version: 0,
          session: request.context.session,
          contextKey: request.key,
          lines: request.context.lines,
          status: status,
          reason: reason,
          campaignId: request.campaignId,
          itemsSubtotalVnd: request.context.subtotal,
        );
    bool current() =>
        isCurrentSession(request.context.session) &&
        sequence == _quoteRequest &&
        request.key == checkoutQuoteKey;
    _checkoutQuote = state(CheckoutQuoteStatus.loading, 'LOADING');
    // The caller schedules this outside build; share one request across views.
    notifyListeners();
    try {
      if (_checkoutQuoteSource == null) {
        throw StateError('No mock quote source');
      }
      final q = await _checkoutQuoteSource!.load(request);
      if (!current()) return null;
      if (q.contextKey != request.key ||
          q.session.userId != userId ||
          q.session.generation != sessionGeneration ||
          q.campaignId != request.campaignId ||
          (q.status == CheckoutQuoteStatus.ready &&
              (!q.consistent ||
                  q.id.isEmpty ||
                  q.version < 1 ||
                  jsonEncode(
                        q.lines
                            .map(
                              (l) => [
                                l.productId,
                                l.variant,
                                l.quantity,
                                l.unitPriceVnd,
                              ],
                            )
                            .toList(),
                      ) !=
                      jsonEncode(
                        request.context.lines
                            .map(
                              (l) => [
                                l.productId,
                                l.variant,
                                l.quantity,
                                l.unitPriceVnd,
                              ],
                            )
                            .toList(),
                      )))) {
        throw StateError('Invalid quote response');
      }
      _checkoutQuote = q;
      return q;
    } catch (_) {
      if (!current()) return null;
      _checkoutQuote = state(CheckoutQuoteStatus.error, 'QUOTE_UNAVAILABLE');
      return _checkoutQuote;
    } finally {
      if (sequence == _quoteRequest && !_sessionDisposed) {
        _quotePending = null;
        _quotePendingKey = null;
        notifyListeners();
      }
    }
  }

  void requireVoucherCheckoutReady() {
    if (hasUnquotedVoucherSelection || isEvaluatingVoucher) {
      throw const RepositoryException(
        'Voucher mới chỉ được xem trước; chưa thể đặt đơn với lựa chọn này.',
      );
    }
  }

  int _voucherRevision = 0;
  String? _lastVoucherData;
  @override
  void notifyListeners() {
    if (!_sessionDisposed) voucherContextKey;
    super.notifyListeners();
  }

  String get voucherContextKey {
    final data = jsonEncode([
      userId,
      sessionGeneration,
      coupon,
      checkoutPaymentMethod.name,
      deliveryAddress?.ownerId,
      deliveryAddress?.full,
      deliveryAddress?.name,
      deliveryAddress?.phone,
      for (final l in cart)
        [
          l.product.id,
          l.variant,
          l.quantity,
          l.product.price,
          l.product.stock,
          l.product.published,
          isCartLineSelected(l),
        ],
      if (repository case final MockLenlabRepository mock)
        for (final p in mock.catalog) [p.id, p.price, p.stock, p.published],
    ]);
    if (data != _lastVoucherData) {
      _lastVoucherData = data;
      _voucherRevision++;
    }
    return jsonEncode([_voucherRevision, data]);
  }

  VoucherEvaluationContext captureVoucherContext() => VoucherEvaluationContext(
    session: captureSession(),
    key: voucherContextKey,
    lines: [
      for (final line in checkoutLines)
        VoucherEvaluationLine(
          productId: line.product.id,
          variant: line.variant,
          quantity: line.quantity,
          unitPriceVnd: line.product.price,
        ),
    ],
    hasAddress: deliveryAddress != null,
    legacyCoupon: coupon,
  );

  Future<VoucherEvaluation?> evaluateVoucher(
    VoucherEligibilitySource source, {
    String? campaignId,
    String? code,
    bool Function()? canApply,
  }) async {
    if (_sessionDisposed || isSubmittingCod || isEvaluatingVoucher) return null;
    if ((campaignId == null) == (code == null) || campaignId?.trim() == '') {
      return VoucherEvaluation(
        status: VoucherEligibilityStatus.ineligible,
        reason: 'INVALID_SELECTION',
        contextKey: voucherContextKey,
      );
    }
    final context = captureVoucherContext();
    final request = ++_voucherRequest;
    _voucherBusyContext = context.key;
    if (campaignId != null) {
      selectVoucherCandidate(campaignId, session: context.session);
    } else {
      // A manual-code request has no resolved ID yet, but is a new intent.
      _voucherSelectionRevision++;
    }
    notifyListeners();
    try {
      final result = await source.evaluate(
        context,
        campaignId: campaignId,
        code: code,
      );
      if (!isCurrentSession(context.session) ||
          request != _voucherRequest ||
          context.key != voucherContextKey ||
          !(canApply?.call() ?? true)) {
        return null;
      }
      if (result.contextKey != context.key) {
        throw const RepositoryException('Ngữ cảnh voucher không còn hợp lệ.');
      }
      _voucherEvaluation = result;
      _voucherSelectionRevision++;
      if (result.campaignId != null) {
        _voucherCandidate = CustomerVoucherCandidate(
          campaignId: result.campaignId!,
          session: context.session,
        );
      }
      if (result.status == VoucherEligibilityStatus.eligible &&
          signedIn &&
          coupon.isEmpty) {
        _appliedVoucher = result;
        _quoteSelectionRevision++;
      }
      return result;
    } catch (_) {
      if (!isCurrentSession(context.session) ||
          request != _voucherRequest ||
          context.key != voucherContextKey ||
          !(canApply?.call() ?? true)) {
        return null;
      }
      rethrow;
    } finally {
      if (request == _voucherRequest && !_sessionDisposed) {
        _voucherBusyContext = null;
        notifyListeners();
      }
    }
  }

  void _clearVoucherSession() {
    _voucherSelectionRevision++;
    _quoteRequest++;
    _checkoutQuote = null;
    _quotePending = null;
    _quotePendingKey = null;
    _voucherRequest++;
    _voucherCandidate = null;
    _voucherEvaluation = _appliedVoucher = null;
    _voucherBusyContext = null;
  }

  CustomerIdentity requireCustomer() {
    if (_sessionDisposed || _currentUser == null) {
      throw const RepositoryException('Vui lòng đăng nhập để tiếp tục.');
    }
    return _currentUser!;
  }

  void requireSession(CustomerSessionStamp stamp) {
    requireCustomer();
    if (!isCurrentSession(stamp)) {
      throw const RepositoryException(
        'Phiên đăng nhập đã thay đổi. Vui lòng mở lại thao tác.',
      );
    }
  }

  CustomerSessionStamp captureSession() =>
      CustomerSessionStamp(userId: userId, generation: _sessionGeneration);

  bool isCurrentSession(CustomerSessionStamp stamp) =>
      !_sessionDisposed &&
      stamp.userId == userId &&
      stamp.generation == _sessionGeneration;

  Future<bool> signIn({
    required String identity,
    required String password,
    bool Function()? canApply,
  }) => _authenticate(
    () => authSource.signIn(identity: identity, password: password),
    canApply,
  );

  Future<bool> register({
    required String name,
    required String identity,
    required String password,
    bool Function()? canApply,
  }) => _authenticate(
    () =>
        authSource.register(name: name, identity: identity, password: password),
    canApply,
  );

  Future<bool> _authenticate(
    Future<CustomerIdentity> Function() operation,
    bool Function()? canApply,
  ) async {
    if (_sessionDisposed) return false;
    final request = ++_authRequestVersion;
    final generation = _sessionGeneration;
    bool active() =>
        !_sessionDisposed &&
        request == _authRequestVersion &&
        generation == _sessionGeneration &&
        (canApply?.call() ?? true);
    try {
      final identity = await operation();
      if (!active()) return false;
      if (identity.id.trim().isEmpty) {
        throw const RepositoryException('Danh tính tài khoản không hợp lệ.');
      }
      _activateSession(identity);
      return true;
    } catch (_) {
      if (!active()) return false;
      rethrow;
    }
  }

  void _activateSession(CustomerIdentity identity) {
    if (!signedIn && _guestCart.lines.isNotEmpty) {
      // Preserve, but do not merge or expose as the account cart in batch 4A.
      (_pendingGuestCarts[identity.id] ??= []).add(_guestCart);
    }
    if (!signedIn) _guestCart = CustomerCartData();
    _authRequestVersion++;
    _sessionGeneration++;
    _currentUser = identity;
    _clearVoucherSession();
    _clearCheckoutDraft();
    _reconcileDetachedCod(identity.id);
    notifyListeners();
  }

  void logout() {
    if (_sessionDisposed) return;
    _authRequestVersion++;
    _sessionGeneration++;
    _currentUser = null;
    _clearVoucherSession();
    _guestCart = CustomerCartData();
    _clearCheckoutDraft();
    notifyListeners();
  }

  /// Temporary bridge for existing test fixtures. Application code must use
  /// signIn/register/logout, so a bool cannot act as an authenticated identity.
  @visibleForTesting
  set signedIn(bool value) {
    if (value == signedIn) return;
    if (value) {
      _activateSession(mockCustomerA);
    } else {
      logout();
    }
  }

  @override
  void dispose() {
    _sessionDisposed = true;
    _authRequestVersion++;
    super.dispose();
  }

  final List<ProductReview> _productReviews;
  List<ProductReview> get productReviews => List.unmodifiable(_productReviews);
  ReviewCollection reviewsFor(String productId) =>
      ReviewCollection(productId: productId, reviews: _productReviews);

  bool hasReviewed(String orderId, String productId) => _productReviews.any(
    (r) =>
        r.orderId == orderId &&
        r.productId == productId &&
        signedIn &&
        r.authorId == userId,
  );

  Order reviewOrder(String orderId) {
    if (!signedIn) {
      throw const RepositoryException(
        'Vui lòng đăng nhập để đánh giá sản phẩm đã mua.',
      );
    }
    final order = findOwnedOrder(orderId);
    if (order == null || order.state != OrderState.delivered) {
      throw const RepositoryException(
        'Chỉ có thể đánh giá sản phẩm trong đơn đã giao.',
      );
    }
    return order;
  }

  final _reviewSubmissions =
      <(String, int, String, String), Future<ProductReview>>{};
  Future<ProductReview> submitProductReview({
    required String orderId,
    required String productId,
    required int rating,
    String text = '',
    List<ReviewPhoto> photos = const [],
    PostPurchaseReviewSource? source,
  }) {
    try {
      requireCustomer();
    } catch (error) {
      return Future.error(error);
    }
    final authorId = requireCustomer().id;
    final key = (authorId, sessionGeneration, orderId, productId);
    final pending = _reviewSubmissions[key];
    if (pending != null) return pending;
    final request = _saveReview(
      orderId: orderId,
      productId: productId,
      authorId: authorId,
      rating: rating,
      text: text,
      photos: List<ReviewPhoto>.unmodifiable(photos),
      source: source,
    );
    _reviewSubmissions[key] = request;
    return request.whenComplete(() => _reviewSubmissions.remove(key));
  }

  Future<ProductReview> _saveReview({
    required String orderId,
    required String productId,
    required String authorId,
    required int rating,
    required String text,
    required List<ReviewPhoto> photos,
    PostPurchaseReviewSource? source,
  }) async {
    requireCustomer();
    final session = captureSession();
    CartLine validate() {
      requireSession(session);
      final order = reviewOrder(orderId);
      if (userId != authorId) {
        throw const RepositoryException(
          'Phiên đăng nhập đã thay đổi. Vui lòng mở lại đánh giá.',
        );
      }
      final lines = order.lines.where((l) => l.product.id == productId);
      if (lines.isEmpty) {
        throw const RepositoryException('Sản phẩm không thuộc đơn hàng này.');
      }
      if (rating < 1 || rating > 5) {
        throw const RepositoryException('Vui lòng chọn từ 1 đến 5 sao.');
      }
      if (hasReviewed(orderId, productId)) {
        throw const RepositoryException(
          'Bạn đã đánh giá sản phẩm này trong đơn hàng.',
        );
      }
      return lines.first;
    }

    validate();
    validateReviewPhotos(photos);
    final name = profile.name.trim().isEmpty
        ? 'Khách hàng'
        : profile.name.trim();
    await (source ?? MockPostPurchaseReviewSource(repository)).save(
      ReviewDraft(
        orderId: orderId,
        productId: productId,
        authorId: authorId,
        rating: rating,
        text: text.trim(),
        photos: photos,
      ),
    );
    final line = validate();
    final initials = name
        .split(RegExp(r'\s+'))
        .take(2)
        .map((s) => s.substring(0, 1))
        .join()
        .toUpperCase();
    final review = ProductReview(
      id: 'mock-review-${_productReviews.length + 1}',
      orderId: orderId,
      authorId: authorId,
      productId: productId,
      name: name,
      initials: initials,
      rating: rating,
      date: DateTime.now(),
      text: text.trim(),
      helpful: 0,
      localPhotos: photos,
      variant: line.variant.isEmpty ? null : line.variant,
      starAssets: List.generate(
        5,
        (i) => i < rating ? 'imgIcon4' : 'imgIcon11',
      ),
    );
    _productReviews.add(review);
    notifyListeners();
    return review;
  }

  CustomerProfile get profile => signedIn
      ? _account.profile
      : CustomerProfile(
          name: '',
          email: '',
          phone: '',
          gender: '',
          birthday: '',
        );
  CustomerCartData _guestCart = CustomerCartData();
  final _pendingGuestCarts = <String, List<CustomerCartData>>{};
  CustomerCartData get _cartData => signedIn ? _account.cart : _guestCart;
  @visibleForTesting
  List<List<CartLine>> get pendingGuestCarts => List.unmodifiable(
    (_pendingGuestCarts[requireCustomer().id] ?? []).map(
      (c) => List<CartLine>.unmodifiable(
        c.lines.map(
          (l) => CartLine(l.product, quantity: l.quantity, variant: l.variant),
        ),
      ),
    ),
  );
  List<CartLine> get cart {
    final stamp = captureSession();
    final data = _cartData;
    void read() {
      if (!isCurrentSession(stamp) || !identical(data, _cartData)) {
        throw const RepositoryException('Phiên giỏ hàng đã thay đổi.');
      }
    }

    return SessionCartList(data.lines, read, () {
      read();
      if (isSubmittingCod) {
        throw const RepositoryException('Giỏ hàng đang gửi đơn COD.');
      }
    });
  }

  bool get guestCartPromptDismissed => _guestCart.promptDismissed;
  void dismissGuestCartPrompt() {
    if (signedIn) return;
    _guestCart.promptDismissed = true;
    notifyListeners();
  }

  List<Order> get orders =>
      signedIn ? _ownedList(_account.orders, (o) => o.ownerId) : const [];
  List<CustomRequest> get customs =>
      signedIn ? _ownedList(_account.customs, (r) => r.ownerId) : const [];
  List<Address> get addresses =>
      signedIn ? _ownedList(_account.addresses, (a) => a.ownerId) : const [];
  CustomerCheckoutDraft _checkoutDraft = CustomerCheckoutDraft(
    ownerId: null,
    generation: 0,
  );
  void _clearCheckoutDraft() {
    _checkoutDraft = CustomerCheckoutDraft(
      ownerId: userId,
      generation: sessionGeneration,
    );
  }

  Address? get deliveryAddress => signedIn ? _checkoutDraft.address : null;
  set deliveryAddress(Address? address) {
    if (!signedIn && address == null) return;
    final owner = requireCustomer().id;
    if (address != null) requireAddressOwner(address);
    _checkoutDraft.address = address?.ownedBy(owner);
  }

  String get checkoutNote => signedIn ? _checkoutDraft.note : '';
  set checkoutNote(String note) {
    requireCustomer();
    _checkoutDraft.note = note;
  }

  String? get bankTransferReference =>
      signedIn ? _checkoutDraft.bankReference : null;
  set bankTransferReference(String? reference) {
    if (!signedIn && reference == null) return;
    requireCustomer();
    _checkoutDraft.bankReference = reference;
  }

  CheckoutPaymentMethod get checkoutPaymentMethod =>
      signedIn ? _checkoutDraft.payment : CheckoutPaymentMethod.cod;
  set checkoutPaymentMethod(CheckoutPaymentMethod method) {
    requireCustomer();
    _checkoutDraft.payment = method;
  }

  Set<String> get favorites {
    if (!signedIn) return const {};
    final actor = captureSession();
    return SessionOwnedSet(_account.favorites, () => requireSession(actor));
  }

  void toggleFavorite(String productId) {
    requireCustomer();
    if (!favorites.remove(productId)) favorites.add(productId);
    notifyListeners();
  }

  String get coupon => _cartData.coupon;
  set coupon(String value) {
    if (isSubmittingCod) return;
    if (_cartData.coupon != value) _voucherSelectionRevision++;
    _cartData.coupon = value;
  }

  int get subtotal => cart.fold(0, (a, b) => a + b.total);
  int get discount => coupon == 'LEN50' && subtotal >= 50000 ? 50000 : 0;
  int get cartCount => cart.fold(0, (a, b) => a + b.quantity);
  // Existing and newly added lines are selected by default, as in P2.
  Set<String> get _unselectedCartKeys => _cartData.unselectedKeys;
  bool isCartLineSelected(CartLine line) =>
      cart.contains(line) && !_unselectedCartKeys.contains(line.key);
  List<CartLine> get checkoutLines =>
      List.unmodifiable(cart.where(isCartLineSelected));
  int get checkoutSubtotal =>
      checkoutLines.fold(0, (sum, line) => sum + line.total);
  int get checkoutDiscount =>
      coupon == 'LEN50' && checkoutSubtotal >= 50000 ? 50000 : 0;

  void toggleCartLine(CartLine line) {
    if (isSubmittingCod || !cart.contains(line)) return;
    if (!_unselectedCartKeys.remove(line.key)) {
      _unselectedCartKeys.add(line.key);
    }
    notifyListeners();
  }

  Future<Order>? _codSubmission;
  CustomerSessionStamp? _codActor;
  int? _nextCodNumber;
  // Completed requests from old sessions await owner-scoped reconciliation in
  // batch 3. Logout never means cancel; these results never touch the new cart.
  final _detachedCodResults = <Order>[];
  void _reconcileDetachedCod(String owner) {
    if (!signedIn || userId != owner) return;
    final target = _account.orders;
    for (final order in _detachedCodResults.where((o) => o.ownerId == owner)) {
      if (!target.any((saved) => saved.id == order.id)) target.insert(0, order);
    }
    _detachedCodResults.removeWhere((o) => o.ownerId == owner);
  }

  Future<void>? _codReview;
  CustomerSessionStamp? _codReviewActor;
  bool get isSubmittingCod =>
      signedIn &&
      ((_codSubmission != null && _codActor?.userId == userId) ||
          (_codReview != null && _codReviewActor?.userId == userId));

  Future<Order> submitCodOrder({
    required OrderReviewTotals totals,
    CodOrderSource? source,
  }) {
    try {
      requireCustomer();
      requireVoucherCheckoutReady();
      if (_codSubmission != null && !isCurrentSession(_codActor!)) {
        throw const RepositoryException(
          'Đang xử lý đơn của phiên trước. Vui lòng chờ.',
        );
      }
    } catch (error) {
      return Future.error(error);
    }
    if (_codSubmission != null) return _codSubmission!;
    if (_codReview != null) {
      return Future.error(
        const RepositoryException('Đang cập nhật thông tin. Vui lòng chờ.'),
      );
    }
    final address = deliveryAddress;
    if (address == null || checkoutLines.isEmpty) {
      return Future.error(
        const RepositoryException(
          'Vui lòng kiểm tra giỏ hàng và địa chỉ nhận hàng.',
        ),
      );
    }
    final draft = CodOrderDraft(
      ownerId: userId!,
      sessionGeneration: sessionGeneration,
      id: 'WOOL-${_nextCodNumber ??= 9000 + orders.length}',
      lines: checkoutLines,
      address: address,
      shipping: totals.shipping,
      discount: totals.discount,
      note: checkoutNote,
      coupon: coupon,
    );
    final actor = captureSession();
    _codActor = actor;
    _codSubmission =
        _submitCod(
          actor,
          draft,
          totals,
          source ?? MockCodOrderSource(repository),
        ).whenComplete(() {
          _codSubmission = null;
          _codActor = null;
          if (!_sessionDisposed) notifyListeners();
        });
    notifyListeners();
    return _codSubmission!;
  }

  Future<Order> _submitCod(
    CustomerSessionStamp actor,
    CodOrderDraft draft,
    OrderReviewTotals totals,
    CodOrderSource source,
  ) async {
    final currentLines = validateCodLines(
      draft.lines,
      await repository.products(),
    );
    validateCodTotals(currentLines, draft.coupon, totals);
    final order = await source.submit(draft);
    if (order.ownerId != actor.userId) {
      throw const RepositoryException('Danh tính chủ đơn COD không hợp lệ.');
    }
    _nextCodNumber = _nextCodNumber! + 1;
    if (!isCurrentSession(actor)) {
      _detachedCodResults.add(order);
      if (signedIn && userId == actor.userId) {
        _reconcileDetachedCod(actor.userId!);
      }
      return order;
    }
    orders.insert(0, order);
    final purchasedKeys = draft.lines.map((line) => line.key).toSet();
    _cartData.lines.removeWhere((line) => purchasedKeys.contains(line.key));
    _unselectedCartKeys.removeAll(purchasedKeys);
    _cartData.coupon = '';
    checkoutNote = '';
    bankTransferReference = null;
    checkoutPaymentMethod = CheckoutPaymentMethod.cod;
    return order;
  }

  /// Only called by an explicit update-and-review action. Never edits quantities.
  Future<void> refreshCodCheckout() {
    try {
      requireCustomer();
    } catch (error) {
      return Future.error(error);
    }
    if (_codReview != null) {
      if (!isCurrentSession(_codReviewActor!)) {
        return Future.error(
          const RepositoryException('Đang xử lý yêu cầu của phiên trước.'),
        );
      }
      return _codReview!;
    }
    if (_codSubmission != null) {
      return Future.error(
        const RepositoryException('Đang đặt đơn COD. Vui lòng chờ.'),
      );
    }
    _codReviewActor = captureSession();
    _codReview = _refreshCodCheckout().whenComplete(() {
      _codReview = null;
      _codReviewActor = null;
      if (!_sessionDisposed) notifyListeners();
    });
    notifyListeners();
    return _codReview!;
  }

  String _codCartKey(List<CartLine> lines) => lines
      .map(
        (line) =>
            '${line.key}:${line.quantity}:${line.product.price}:${line.product.stock}',
      )
      .join(';');

  Future<void> _refreshCodCheckout() async {
    final actor = captureSession();
    final original = checkoutLines;
    final key = _codCartKey(original);
    final updated = validateCodLines(
      original,
      await repository.products(),
      acceptUpdatedInformation: true,
    );
    requireSession(actor);
    if (_codCartKey(checkoutLines) != key || !original.every(cart.contains)) {
      throw const CodValidationException(
        'Giỏ hàng đã thay đổi. Vui lòng xem lại giỏ hàng.',
        CodValidationReason.totalsChanged,
      );
    }
    final byKey = {for (final line in updated) line.key: line};
    for (var i = 0; i < cart.length; i++) {
      final replacement = byKey[cart[i].key];
      if (replacement != null && isCartLineSelected(cart[i])) {
        _cartData.lines[i] = replacement;
      }
    }
  }

  void changed() => notifyListeners();

  void addToCart(Product p, int count, String variant) {
    if (isSubmittingCod) return;
    final match = cart
        .where((l) => l.product.id == p.id && l.variant == variant)
        .firstOrNull;
    if (match == null) {
      final line = CartLine(p, quantity: count, variant: variant);
      _unselectedCartKeys.remove(line.key);
      cart.add(line);
    } else {
      match.quantity += count;
    }
    notifyListeners();
  }

  void changeQuantity(CartLine line, int delta) {
    if (isSubmittingCod || !cart.contains(line)) return;
    final next = line.quantity + delta;
    if (next < 1 || next > line.product.stock) return;
    line.quantity = next;
    notifyListeners();
  }

  void removeFromCart(CartLine line) {
    if (isSubmittingCod) return;
    if (cart.remove(line)) {
      _unselectedCartKeys.remove(line.key);
      notifyListeners();
    }
  }
}
