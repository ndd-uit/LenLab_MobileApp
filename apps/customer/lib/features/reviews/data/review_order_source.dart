import 'package:lenlab_shared/lenlab_shared.dart';

class ReviewOrderSource {
  ReviewOrderSource(this.store);
  final LenlabStore store;
  Future<Order> load(String orderId) async {
    store.requireCustomer();
    final actor = store.captureSession();
    // Guard before and after the simulated request; never load an arbitrary seed.
    store.reviewOrder(orderId);
    if (store.repository case final MockLenlabRepository mock) {
      await mock.operation('reviewEligibility');
    } else {
      throw const RepositoryException(
        'Chưa cấu hình nguồn đơn hàng để đánh giá.',
      );
    }
    store.requireSession(actor);
    return store.reviewOrder(orderId);
  }
}
