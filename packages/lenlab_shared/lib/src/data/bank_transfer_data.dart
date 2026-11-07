import '../domain/models.dart';
import 'lenlab_repository.dart';
import 'mock_lenlab_repository.dart';
import 'order_review_data.dart';

class BankTransferPreview {
  const BankTransferPreview({
    required this.totals,
    required this.reference,
    this.bank = 'VIETCOMBANK',
    this.holder = 'NGUYỄN THÀNH LONG',
    this.account = '1040614582',
  });
  final OrderReviewTotals totals;
  final String bank, holder, account, reference;
}

abstract interface class BankTransferSource {
  Future<BankTransferPreview> preview({
    required int subtotal,
    required int discount,
    required Address address,
    required String reference,
  });
}

/// P2 demonstration details only. This does not reserve/create an order or
/// generate a payable QR. Replace once the bank/order API is specified.
class MockBankTransferSource implements BankTransferSource {
  MockBankTransferSource(this.repository, {OrderReviewSource? totalsSource})
    : totalsSource = totalsSource ?? MockOrderReviewSource(repository);
  final LenlabRepository repository;
  final OrderReviewSource totalsSource;
  @override
  Future<BankTransferPreview> preview({
    required int subtotal,
    required int discount,
    required Address address,
    required String reference,
  }) async {
    if (repository case final MockLenlabRepository mock) {
      await mock.operation('bankTransfer');
    } else {
      throw const RepositoryException(
        'Chưa cấu hình nguồn thông tin chuyển khoản.',
      );
    }
    final totals = await totalsSource.preview(
      subtotal: subtotal,
      discount: discount,
      address: address,
    );
    return BankTransferPreview(totals: totals, reference: reference);
  }
}
