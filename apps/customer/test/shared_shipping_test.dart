import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_shared/lenlab_shared.dart';
import 'package:lenlab_customer/features/vouchers/data/voucher_source.dart';
import 'package:lenlab_customer/features/vouchers/data/voucher_eligibility_source.dart';
import 'package:lenlab_customer/features/checkout/data/mock_checkout_quote_source.dart';

import 'voucher_evaluation_test.dart' as v;
import 'checkout_quote_test.dart' as q;

void main() {
  for (final entry in [
    (VoucherRuleType.shippingDiscountCapped, 17000, 12000, 10000, 10000, 7000),
    (VoucherRuleType.shippingFreeFull, 17000, 12000, 10000, 12000, 5000),
    (VoucherRuleType.shippingFreeFull, 17000, 17000, 10000, 17000, 0),
    (VoucherRuleType.shippingDiscountCapped, 17000, 12000, 50000, 12000, 5000),
    (VoucherRuleType.shippingFreeFull, 0, 0, 10000, 0, 0),
    (VoucherRuleType.itemsFixed, 17000, 12000, 10000, 0, 17000),
  ]) {
    test(
      '${entry.$1} F=${entry.$2} E=${entry.$3}: evaluator and quote share fee input',
      () async {
        final s = v.sample();
        s.deliveryAddress = s.addresses.single;
        var calls = 0;
        final provider = MockShippingPreviewSource(
          s,
          clock: () => v.now,
          loader: (c) async {
            calls++;
            // A second uncached load would deliberately change F and reveal drift.
            return ShippingPreview.ready(
              contextKey: c.key,
              session: c.session,
              grossShippingFeeVnd: calls == 1 ? entry.$2 : 99000,
              eligibleShippingFeeVnd: entry.$3,
              sourceVersion: 9,
            );
          },
        );
        final campaign = q.campaign(v.rules(type: entry.$1, amount: entry.$4));
        final public = MockPublicCampaignSource(s, campaigns: [campaign]);
        final usage = MockCustomerVoucherUsageSource(s, usage: []);
        final evaluator = MockVoucherEligibilitySource(
          s,
          publicSource: public,
          usageSource: usage,
          shippingSource: provider,
          clock: () => v.now,
        );
        final result = await s.evaluateVoucher(
          evaluator,
          campaignId: campaign.id,
        );
        expect(result!.status, VoucherEligibilityStatus.eligible);
        expect(result.shippingDiscountVnd, entry.$5);
        if (entry.$1 != VoucherRuleType.itemsFixed) {
          expect(result.remainingShippingVnd, entry.$6);
          expect(result.shippingPreview, same(provider.currentPreview));
        }
        s.configureCheckoutQuoteSource(
          MockCheckoutQuoteSource(
            s,
            campaigns: public,
            usage: usage,
            shippingSource: provider,
            clock: () => v.now,
          ),
        );
        final quote = (await s.requestCheckoutQuote())!;
        expect(quote.status, CheckoutQuoteStatus.ready);
        expect(quote.shippingFeeVnd, entry.$2);
        expect(quote.shippingDiscountVnd, entry.$5);
        expect(quote.shippingPayableVnd, entry.$6);
        expect(quote.shippingPreview, same(provider.currentPreview));
        if (entry.$1 != VoucherRuleType.itemsFixed) {
          expect(quote.shippingPreview, same(result.shippingPreview));
        }
        expect(quote.grandTotalVnd, 45000 - quote.itemsDiscountVnd! + entry.$6);
        expect(quote.reviewTotals.total, quote.grandTotalVnd);
        expect(calls, 1);
        expect(s.coupon, isEmpty);
        expect(s.orders, hasLength(4));
        expect(s.hasUnquotedVoucherSelection, isTrue);
        await expectLater(
          s.submitCodOrder(totals: quote.reviewTotals),
          throwsA(isA<RepositoryException>()),
        );
      },
    );
  }

  test('no address returns NEEDS_CONTEXT in both consumers, no legacy fee or loader read', () async {
    final s = v.sample();
    var calls = 0;
    final provider = MockShippingPreviewSource(
      s,
      loader: (c) async {
        calls++;
        return ShippingPreview.ready(
          contextKey: c.key,
          session: c.session,
          grossShippingFeeVnd: 17000,
          eligibleShippingFeeVnd: 12000,
        );
      },
    );
    final campaign = q.campaign(
      v.rules(type: VoucherRuleType.shippingFreeFull),
    );
    final public = MockPublicCampaignSource(s, campaigns: [campaign]);
    final evaluator = MockVoucherEligibilitySource(
      s,
      publicSource: public,
      shippingSource: provider,
      clock: () => v.now,
    );
    final result = await s.evaluateVoucher(evaluator, campaignId: campaign.id);
    expect(result!.status, VoucherEligibilityStatus.needsContext);
    expect(result.shippingPreview!.grossShippingFeeVnd, isNull);
    final source = MockCheckoutQuoteSource(
      s,
      campaigns: public,
      shippingSource: provider,
      clock: () => v.now,
    );
    final quote = await source.load(q.request(s, campaign.id));
    expect(quote.status, CheckoutQuoteStatus.needsContext);
    expect(quote.shippingFeeVnd, isNull);
    expect(quote.grandTotalVnd, isNull);
    expect(calls, 0);
  });

  test('ERROR is propagated without fee fallback, retry uses the shared READY result', () async {
    final s = v.sample();
    s.deliveryAddress = s.addresses.single;
    var fail = true;
    final provider = MockShippingPreviewSource(
      s,
      loader: (c) async {
        if (fail) throw StateError('provider error');
        return ShippingPreview.ready(
          contextKey: c.key,
          session: c.session,
          grossShippingFeeVnd: 17000,
          eligibleShippingFeeVnd: 12000,
        );
      },
    );
    final campaign = q.campaign(
      v.rules(type: VoucherRuleType.shippingFreeFull),
    );
    final public = MockPublicCampaignSource(s, campaigns: [campaign]);
    final evaluator = MockVoucherEligibilitySource(
      s,
      publicSource: public,
      usageSource: MockCustomerVoucherUsageSource(s, usage: []),
      shippingSource: provider,
      clock: () => v.now,
    );
    expect(
      (await s.evaluateVoucher(evaluator, campaignId: campaign.id))!.reason,
      'SHIPPING_UNAVAILABLE',
    );
    final source = MockCheckoutQuoteSource(
      s,
      campaigns: public,
      usage: MockCustomerVoucherUsageSource(s, usage: []),
      shippingSource: provider,
      clock: () => v.now,
    );
    final error = await source.load(q.request(s, campaign.id));
    expect(error.status, CheckoutQuoteStatus.error);
    expect(error.shippingFeeVnd, isNull);
    fail = false;
    final result = await s.evaluateVoucher(evaluator, campaignId: campaign.id);
    final ready = await source.load(q.request(s, campaign.id));
    expect(ready.status, CheckoutQuoteStatus.ready);
    expect(ready.shippingPreview, same(result!.shippingPreview));
  });
}
