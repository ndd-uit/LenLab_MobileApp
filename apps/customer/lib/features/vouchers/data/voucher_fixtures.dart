import 'package:lenlab_shared/lenlab_shared.dart';

import 'voucher_models.dart';

/// Explicit published DEMO campaigns, not created by the current Admin UI.
/// Labels/dates are P2 copy; no numeric, expiry or eligibility rules are inferred.
const mockPublicVoucherCampaigns = <PublicVoucherCampaign>[
  PublicVoucherCampaign(
    publication: VoucherPublication.published,
    id: 'p2-len20',
    kind: WalletVoucherKind.discount,
    label: 'GIẢM 20%',
    title: 'LEN20',
    description: 'Giảm 20% giá trị đơn hàng. Đơn hàng tối thiểu 300.000đ.',
    expiry: '31/12/2026',
    isNew: true,
    code: 'LEN20',
  ),
  PublicVoucherCampaign(
    publication: VoucherPublication.published,
    id: 'p2-shipping',
    kind: WalletVoucherKind.shipping,
    label: 'FREESHIP',
    title: 'Miễn phí vận chuyển',
    description: 'Đơn tối thiểu 150k. Tối đa 30k.',
    expiry: '30/09/2026',
    display: VoucherCampaignDisplay.expired,
  ),
  PublicVoucherCampaign(
    publication: VoucherPublication.published,
    id: 'p2-first',
    kind: WalletVoucherKind.firstOrder,
    label: 'GIẢM 10%',
    title: 'Giảm 10% Đơn đầu tiên',
    description: 'Áp dụng cho sản phẩm len thủ công.',
    expiry: '31/12/2026',
  ),
  PublicVoucherCampaign(
    publication: VoucherPublication.published,
    id: 'p2-cash',
    kind: WalletVoucherKind.cash,
    label: '50K',
    title: 'Giảm 50K Tổng đơn',
    description: 'Đơn hàng từ 500k. Số lượng có hạn.',
    expiry: '23/10/2026',
  ),
  PublicVoucherCampaign(
    publication: VoucherPublication.published,
    id: 'p2-gift',
    kind: WalletVoucherKind.gift,
    label: 'QUÀ TẶNG',
    title: 'Tặng bộ kim đan',
    description: 'Khi mua 5 cuộn len lông cừu.',
    expiry: '31/12/2026',
  ),
];

/// Legacy used fixture belongs only to demo A; never copied to another user.
const mockCustomerVoucherUsage = <CustomerVoucherUsage>[
  CustomerVoucherUsage(userId: mockCustomerAId, campaignId: 'p2-first'),
];
