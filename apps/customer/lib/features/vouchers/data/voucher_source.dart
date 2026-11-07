import 'package:lenlab_shared/lenlab_shared.dart';

import 'voucher_models.dart';
import 'voucher_fixtures.dart';

export 'voucher_models.dart';
export 'voucher_fixtures.dart';

abstract interface class PublicCampaignSource {
  Future<List<PublicVoucherCampaign>> load();
}

abstract interface class CustomerVoucherUsageSource {
  Future<List<CustomerVoucherUsage>> load();
}

class MockPublicCampaignSource implements PublicCampaignSource {
  MockPublicCampaignSource(
    this.store, {
    List<PublicVoucherCampaign> campaigns = mockPublicVoucherCampaigns,
  }) : campaigns = List.unmodifiable(campaigns) {
    final ids = <String>{};
    for (final c in this.campaigns) {
      if (c.id.trim().isEmpty || !ids.add(c.id)) {
        throw ArgumentError('Campaign IDs must be nonempty and unique.');
      }
    }
  }
  final LenlabStore store;
  final List<PublicVoucherCampaign> campaigns;
  @override
  Future<List<PublicVoucherCampaign>> load() async {
    if (store.repository case final MockLenlabRepository mock) {
      await mock.operation('vouchers');
    } else {
      throw const RepositoryException('Chưa cấu hình nguồn voucher.');
    }
    return List.unmodifiable(
      campaigns.where((c) => c.publication == VoucherPublication.published),
    );
  }
}

class MockCustomerVoucherUsageSource implements CustomerVoucherUsageSource {
  MockCustomerVoucherUsageSource(
    this.store, {
    List<CustomerVoucherUsage> usage = mockCustomerVoucherUsage,
  }) : _usage = List.unmodifiable(usage);
  final LenlabStore store;
  final List<CustomerVoucherUsage> _usage;
  @override
  Future<List<CustomerVoucherUsage>> load() async {
    final user = store.requireCustomer().id;
    final stamp = store.captureSession();
    if (store.repository case final MockLenlabRepository mock) {
      await mock.operation('voucher-usage');
    } else {
      throw const RepositoryException('Chưa cấu hình usage voucher.');
    }
    store.requireSession(stamp);
    return List.unmodifiable(_usage.where((u) => u.userId == user));
  }
}

abstract interface class VoucherSource {
  Future<List<WalletVoucher>> load();
}

/// Presentation adapter: public metadata, optional private usage. Guest never
/// invokes the private source, even if it is injected by the caller.
class MockVoucherSource implements VoucherSource {
  MockVoucherSource(
    this.store, {
    List<PublicVoucherCampaign> campaigns = mockPublicVoucherCampaigns,
    List<CustomerVoucherUsage> usage = mockCustomerVoucherUsage,
    PublicCampaignSource? publicSource,
    CustomerVoucherUsageSource? usageSource,
  }) : publicSource =
           publicSource ??
           MockPublicCampaignSource(store, campaigns: campaigns),
       usageSource =
           usageSource ?? MockCustomerVoucherUsageSource(store, usage: usage);
  final LenlabStore store;
  final PublicCampaignSource publicSource;
  final CustomerVoucherUsageSource usageSource;
  @override
  Future<List<WalletVoucher>> load() async {
    final stamp = store.captureSession();
    final campaigns = await publicSource.load();
    if (!store.isCurrentSession(stamp)) {
      throw const RepositoryException('Phiên đọc voucher đã thay đổi.');
    }
    final usage = stamp.userId == null
        ? <CustomerVoucherUsage>[]
        : await usageSource.load();
    if (!store.isCurrentSession(stamp)) {
      throw const RepositoryException('Phiên đọc voucher đã thay đổi.');
    }
    if (usage.any((u) => u.userId != stamp.userId || u.usedCount < 0)) {
      throw const RepositoryException(
        'Dữ liệu usage voucher không đúng tài khoản.',
      );
    }
    return List.unmodifiable(
      campaigns.map((c) {
        final count = usage
            .where((u) => u.campaignId == c.id)
            .fold(0, (sum, u) => sum + u.usedCount);
        final limit = c.rules?.perCustomerLimit;
        // Legacy read-only badge remains a fixture. Typed campaigns may allow
        // repeated use; prior usage alone must not disable them.
        final exhausted = limit == null
            ? count > 0
            : limit.mode == VoucherLimitMode.limited &&
                  limit.valid &&
                  count >= limit.count!;
        return WalletVoucher.fromCampaign(c, usedByCurrentUser: exhausted);
      }),
    );
  }
}
