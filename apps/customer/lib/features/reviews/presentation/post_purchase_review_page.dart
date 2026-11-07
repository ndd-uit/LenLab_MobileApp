import '../../../app/customer_session_gate.dart';

import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

import '../../../app/customer_scope.dart';
import '../../../app/navigation.dart';
import '../../../shared/widgets/header_widgets.dart';
import '../data/review_order_source.dart';
import '../data/review_photo_picker.dart';
import '../data/review_photo_error.dart';
import '../../../shared/data/local_image_validation.dart';
import 'widgets/review_photo_input.dart';
import 'widgets/review_product_summary.dart';
import 'widgets/review_rating_input.dart';

class PostPurchaseReviewPage extends StatelessWidget {
  const PostPurchaseReviewPage({
    super.key,
    required this.orderId,
    this.photoPicker,
  });
  final String orderId;
  final ReviewPhotoPicker? photoPicker;
  @override
  Widget build(BuildContext context) => CustomerSessionGate(
    route: '/write-review',
    arguments: orderId,
    builder: (_) => _PostPurchaseReviewPageContent(
      orderId: orderId,
      photoPicker: photoPicker,
    ),
  );
}

class _PostPurchaseReviewPageContent extends StatefulWidget {
  const _PostPurchaseReviewPageContent({
    required this.orderId,
    this.photoPicker,
  });
  final String orderId;
  final ReviewPhotoPicker? photoPicker;
  @override
  State<_PostPurchaseReviewPageContent> createState() =>
      _PostPurchaseReviewPageState();
}

class _PostPurchaseReviewPageState
    extends State<_PostPurchaseReviewPageContent> {
  Future<Order>? request;
  late LenlabStore store;
  CustomerSessionStamp? actor;
  String? productId, error;
  int rating = 0;
  bool busy = false;
  bool pickingPhotos = false;
  final photos = <ReviewPhoto>[];
  String? photoError;
  int photoRequest = 0;
  late final photoPicker = widget.photoPicker ?? GalleryReviewPhotoPicker();
  ProductReview? saved;
  final comment = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    store = CustomerScope.of(context);
    if (request == null) load();
  }

  void load() {
    actor = store.captureSession();
    request = ReviewOrderSource(store).load(widget.orderId);
  }

  @override
  void didUpdateWidget(covariant _PostPurchaseReviewPageContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.orderId != widget.orderId) {
      productId = null;
      rating = 0;
      error = null;
      saved = null;
      comment.clear();
      photos.clear();
      photoError = null;
      photoRequest++;
      pickingPhotos = false;
      load();
    }
  }

  @override
  void dispose() {
    photoRequest++;
    comment.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (busy || pickingPhotos) return;
    if (productId == null || rating == 0) {
      setState(
        () => error = productId == null
            ? 'Vui lòng chọn sản phẩm đã mua.'
            : 'Vui lòng chọn từ 1 đến 5 sao.',
      );
      return;
    }
    if (actor == null || !store.isCurrentSession(actor!)) {
      setState(
        () => error = 'Phiên đăng nhập đã thay đổi. Vui lòng mở lại đánh giá.',
      );
      return;
    }
    final session = store.captureSession();
    FocusScope.of(context).unfocus();
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final result = await store.submitProductReview(
        orderId: widget.orderId,
        productId: productId!,
        rating: rating,
        text: comment.text,
        photos: photos,
      );
      if (mounted && store.isCurrentSession(session)) {
        setState(() => saved = result);
      }
    } catch (e) {
      if (mounted && store.isCurrentSession(session)) {
        setState(
          () => error = e is RepositoryException
              ? e.message
              : 'Không gửi được đánh giá. Vui lòng thử lại.',
        );
      }
    } finally {
      if (mounted && store.isCurrentSession(session)) {
        setState(() => busy = false);
      }
    }
  }

  Future<void> choosePhotos() async {
    if (busy ||
        pickingPhotos ||
        photos.length >= maxReviewPhotos ||
        productId == null) {
      return;
    }
    final selectedProduct = productId;
    final orderId = widget.orderId;
    final selectedActor = actor;
    final token = ++photoRequest;
    setState(() {
      pickingPhotos = true;
      photoError = null;
    });
    try {
      store.reviewOrder(orderId);
      final picked = await photoPicker.pick(
        remaining: maxReviewPhotos - photos.length,
      );
      validateReviewPhotos([...photos, ...picked]);
      // Codec checks run before replacing the draft; an invalid batch keeps it intact.
      for (final photo in picked) {
        await validatedLocalImage(photo.bytes);
      }
      if (!mounted ||
          token != photoRequest ||
          selectedProduct != productId ||
          orderId != widget.orderId ||
          selectedActor == null ||
          !store.isCurrentSession(selectedActor) ||
          !store.signedIn) {
        return;
      }
      store.reviewOrder(orderId);
      setState(() => photos.addAll(picked));
    } catch (error) {
      if (!mounted ||
          token != photoRequest ||
          selectedActor == null ||
          !store.isCurrentSession(selectedActor)) {
        return;
      }
      debugPrint('Review photo picker failed: $error');
      setState(() => photoError = reviewPhotoError(error));
    } finally {
      if (mounted &&
          token == photoRequest &&
          selectedActor != null &&
          store.isCurrentSession(selectedActor)) {
        setState(() => pickingPhotos = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !busy,
    child: Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.textScalerOf(context).scale(18) > 18
            ? 80
            : 64,
        automaticallyImplyLeading: false,
        leadingWidth: 64,
        leading: AbsorbPointer(
          absorbing: busy,
          child: const Padding(
            padding: EdgeInsets.only(left: 14, right: 6),
            child: HeaderBackButton(),
          ),
        ),
        title: const Text(
          'Đánh giá sản phẩm',
          maxLines: 2,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: const [SizedBox(width: 64)],
      ),
      body: SafeArea(
        child: FutureBuilder<Order>(
          future: request,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return SingleChildScrollView(
                child: EmptyPanel(
                  'Chưa thể đánh giá',
                  description: snapshot.error is RepositoryException
                      ? (snapshot.error as RepositoryException).message
                      : 'Không tải được đơn hàng.',
                  action: store.signedIn
                      ? P2Button('Thử lại', onPressed: () => setState(load))
                      : P2Button(
                          'Đăng nhập',
                          onPressed: () => go(context, '/login'),
                        ),
                ),
              );
            }
            Order order;
            try {
              order = store.reviewOrder(widget.orderId);
              if (actor == null || !store.isCurrentSession(actor!)) {
                throw const RepositoryException(
                  'Phiên đăng nhập đã thay đổi. Vui lòng mở lại đánh giá.',
                );
              }
            } on RepositoryException catch (e) {
              return SingleChildScrollView(
                child: EmptyPanel('Chưa thể đánh giá', description: e.message),
              );
            }
            final products = <String, Product>{
              for (final line in order.lines) line.product.id: line.product,
            };
            if (products.isEmpty) {
              return const EmptyPanel('Đơn hàng chưa có sản phẩm');
            }
            if (productId != null && !products.containsKey(productId)) {
              return const EmptyPanel('Sản phẩm không còn thuộc đơn hàng này');
            }
            if (productId == null && products.length == 1) {
              productId = products.keys.single;
            }
            final product = products[productId];
            final already =
                product != null && store.hasReviewed(order.id, product.id);
            if (saved != null) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: P2.green,
                      size: 56,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Đã gửi đánh giá',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: P2.green,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Đơn #${order.id}'),
                    Text(
                      products[saved!.productId]?.name ?? saved!.productId,
                      textAlign: TextAlign.center,
                    ),
                    Text('${saved!.rating}/5 sao'),
                    if (saved!.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(saved!.text),
                      ),
                    const SizedBox(height: 16),
                    const Text(
                      'Đánh giá đã được lưu trong bản mock trên phiên ứng dụng này.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    P2Button(
                      'Về đơn hàng',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    if (products.keys.any(
                      (id) => !store.hasReviewed(order.id, id),
                    ))
                      TextButton(
                        onPressed: () => setState(() {
                          saved = null;
                          productId = null;
                          rating = 0;
                          error = null;
                          comment.clear();
                          photos.clear();
                          photoError = null;
                          photoRequest++;
                        }),
                        child: const Text('Đánh giá sản phẩm khác'),
                      ),
                  ],
                ),
              );
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Đơn #${order.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: P2.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Đã giao', style: TextStyle(color: P2.green)),
                  const SizedBox(height: 20),
                  if (products.length > 1) ...[
                    DropdownButtonFormField<String>(
                      initialValue: productId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Sản phẩm đã mua',
                      ),
                      items: [
                        for (final p in products.values)
                          DropdownMenuItem(
                            value: p.id,
                            child: Text(
                              p.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: busy || pickingPhotos
                          ? null
                          : (id) => setState(() {
                              productId = id;
                              rating = 0;
                              error = null;
                              comment.clear();
                              photos.clear();
                              photoError = null;
                              photoRequest++;
                            }),
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (product != null)
                    ReviewProductSummary(order: order, product: product),
                  const SizedBox(height: 24),
                  if (already)
                    const Text(
                      'Bạn đã đánh giá sản phẩm này trong đơn hàng. Chưa hỗ trợ sửa đánh giá.',
                      style: TextStyle(color: P2.green),
                    )
                  else ...[
                    const Text(
                      'Đánh giá của bạn',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: P2.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ReviewRatingInput(
                      rating: rating,
                      busy: busy,
                      onChanged: (value) => setState(() {
                        rating = value;
                        error = null;
                      }),
                    ),
                    Text(
                      rating == 0
                          ? 'Chọn từ 1 đến 5 sao (bắt buộc)'
                          : 'Bạn đã chọn $rating/5 sao',
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: comment,
                      enabled: !busy,
                      minLines: 4,
                      maxLines: 8,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        alignLabelWithHint: true,
                        labelText: 'Nhận xét (không bắt buộc)',
                        hintText: 'Chia sẻ trải nghiệm về sản phẩm',
                      ),
                    ),
                    const SizedBox(height: 12),
                    ReviewPhotoInput(
                      photos: photos,
                      busy: busy,
                      picking: pickingPhotos,
                      onPick: choosePhotos,
                      error: photoError,
                      onRemove: (index) => setState(() {
                        photos.removeAt(index);
                        photoError = null;
                      }),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Mỗi sản phẩm trong một đơn được đánh giá một lần. Chưa hỗ trợ sửa đánh giá. Ảnh chỉ lưu mock trong phiên, chưa upload.',
                      style: TextStyle(fontSize: 12, color: P2.brown),
                    ),
                    if (error != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Semantics(
                          liveRegion: true,
                          child: Text(
                            error!,
                            style: const TextStyle(color: Color(0xFF7A2929)),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    P2Button(
                      'Gửi đánh giá',
                      busy: busy,
                      color: P2.productDetailButton,
                      onPressed: pickingPhotos ? null : submit,
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    ),
  );
}
