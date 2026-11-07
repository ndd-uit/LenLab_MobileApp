import 'package:lenlab_shared/lenlab_shared.dart';

enum WalletVoucherKind { discount, shipping, firstOrder, cash, gift }

/// Presentation only. Available does not mean Backend eligibility is verified.
enum WalletVoucherStatus { available, expired, used }

enum VoucherPublication { draft, published, hidden }

/// Explicit display fixture, never inferred from an expiry label/device clock.
enum VoucherCampaignDisplay { available, expired }

class PublicVoucherCampaign {
  const PublicVoucherCampaign({
    required this.id,
    required this.kind,
    required this.label,
    required this.title,
    required this.description,
    required this.expiry,
    this.publication = VoucherPublication.draft,
    this.display = VoucherCampaignDisplay.available,
    this.isNew = false,
    this.code,
    this.rules,
    this.version,
  });
  final String id, label, title, description, expiry;
  final WalletVoucherKind kind;
  final VoucherPublication publication;
  final VoucherCampaignDisplay display;
  final bool isNew;
  final String? code;
  final VoucherRules? rules;
  final int? version;
}

/// A personal read record, not a campaign assignment or a quota policy.
class CustomerVoucherUsage {
  const CustomerVoucherUsage({
    required this.userId,
    required this.campaignId,
    this.usedCount = 1,
  });
  final String userId, campaignId;
  final int usedCount;
}

/// Existing card view model; public metadata + current user's display state.
class WalletVoucher {
  const WalletVoucher({
    required this.id,
    required this.kind,
    required this.label,
    required this.title,
    required this.description,
    required this.expiry,
    this.status = WalletVoucherStatus.available,
    this.isNew = false,
    this.code,
  });
  factory WalletVoucher.fromCampaign(
    PublicVoucherCampaign campaign, {
    bool usedByCurrentUser = false,
  }) => WalletVoucher(
    id: campaign.id,
    kind: campaign.kind,
    label: campaign.label,
    title: campaign.title,
    description: campaign.description,
    expiry: campaign.expiry,
    code: campaign.code,
    isNew: campaign.isNew,
    status: campaign.display == VoucherCampaignDisplay.expired
        ? WalletVoucherStatus.expired
        : usedByCurrentUser
        ? WalletVoucherStatus.used
        : WalletVoucherStatus.available,
  );
  final String id, label, title, description, expiry;
  final WalletVoucherKind kind;
  final WalletVoucherStatus status;
  final bool isNew;
  final String? code;
}
