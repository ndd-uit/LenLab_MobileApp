import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

class _QuoteSource implements OrderReviewSource {
  @override
  Future<OrderReviewTotals> preview({
    required int subtotal,
    required int discount,
    required Address address,
  }) async => OrderReviewTotals(
    subtotal: subtotal,
    discount: discount,
    shipping: 15000,
  );
}

void main() {
  test(
    'transfer preview uses quote source and does not create or pay an order',
    () async {
      final repository = MockLenlabRepository(latency: Duration.zero);
      final store = LenlabStore(repository: repository);
      store.addToCart(
        repository.catalog.firstWhere((p) => p.id == 'sweater'),
        1,
        'Xanh đậm · Size M',
      );
      store.addToCart(
        repository.catalog.firstWhere((p) => p.id == 'gloves'),
        2,
        'Xám · Size S',
      );
      store.coupon = 'LEN50';
      final source = MockBankTransferSource(
        repository,
        totalsSource: _QuoteSource(),
      );
      final preview = await source.preview(
        subtotal: store.subtotal,
        discount: store.discount,
        address: const Address(ownerId: mockCustomerAId),
        reference: 'WOOL9005',
      );
      expect(preview.totals.total, 1865000);
      expect(preview.reference, 'WOOL9005');
      expect(preview.bank, 'VIETCOMBANK');
      expect(store.orders.length, 0);
      expect(store.cartCount, 3);
    },
  );
  test(
    'transfer preview failure is retryable without order mutation',
    () async {
      final repository = MockLenlabRepository(latency: Duration.zero)
        ..failNext('bankTransfer');
      final source = MockBankTransferSource(repository);
      Future<BankTransferPreview> request() => source.preview(
        subtotal: 1900000,
        discount: 50000,
        address: const Address(ownerId: mockCustomerAId),
        reference: 'WOOL9005',
      );
      await expectLater(request(), throwsA(isA<RepositoryException>()));
      expect((await request()).totals.total, 1880000);
    },
  );
}
