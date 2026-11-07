import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_customer/app/customer_app.dart';
import 'package:lenlab_customer/app/customer_scope.dart';
import 'package:lenlab_customer/features/vouchers/data/voucher_source.dart';
import 'package:lenlab_customer/features/vouchers/presentation/voucher_page.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

void main() {
  testWidgets(
    'B public wallet supports loading error retry without applying or changing checkout',
    (t) async {
      final repo = MockLenlabRepository(
        latency: const Duration(milliseconds: 100),
      )..failNext('vouchers');
      final s = LenlabStore(
        repository: repo,
        authSource: MockCustomerAuthSource(latency: Duration.zero),
      );
      addTearDown(s.dispose);
      await t.runAsync(
        () => s.signIn(identity: mockCustomerB.email, password: 'mock'),
      );
      s.addToCart(repo.catalog.firstWhere((p) => p.id == 'carrot'), 1, 'B');
      s.deliveryAddress = const Address(
        ownerId: 'customer-demo-b',
        name: 'B address',
      );
      s.checkoutNote = 'B draft';
      final line = s.cart.single, address = s.deliveryAddress;
      await t.pumpWidget(CustomerApp(store: s, initialRoute: '/vouchers'));
      await t.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await t.pumpAndSettle();
      expect(find.text('Không thể tải voucher'), findsOneWidget);
      await t.tap(find.text('Thử lại'));
      await t.pumpAndSettle();
      expect(find.text('LEN20'), findsOneWidget);
      await t.tap(find.text('Dùng ngay').first);
      await t.pumpAndSettle();
      expect(s.voucherCandidate?.campaignId, 'p2-len20');
      expect(find.byType(VoucherPage), findsNothing);
      expect(s.coupon, isEmpty);
      expect(s.cart.single, same(line));
      expect(s.deliveryAddress, same(address));
      expect(s.checkoutNote, 'B draft');
      expect(s.checkoutSubtotal, 45000);
      expect(s.checkoutDiscount, 0);
      expect(s.orders, isEmpty);
      expect(t.takeException(), isNull);
    },
  );

  testWidgets(
    'A used badge disappears when switching to B while public cards remain',
    (t) async {
      t.view.physicalSize = const Size(430, 1800);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      final s = LenlabStore(
        repository: MockLenlabRepository(latency: Duration.zero),
      );
      addTearDown(s.dispose);
      await t.runAsync(
        () => s.signIn(identity: mockCustomerA.email, password: 'mock'),
      );
      await t.pumpWidget(CustomerApp(store: s, initialRoute: '/vouchers'));
      await t.pumpAndSettle();
      expect(find.text('Đã dùng'), findsOneWidget);
      await t.runAsync(
        () => s.signIn(identity: mockCustomerB.email, password: 'mock'),
      );
      await t.pumpAndSettle();
      expect(find.text('Đã dùng'), findsNothing);
      expect(find.text('Giảm 10% Đơn đầu tiên'), findsOneWidget);
      expect(find.text('LEN20'), findsOneWidget);
      expect(s.coupon, isEmpty);
      expect(t.takeException(), isNull);
    },
  );

  testWidgets('unpublished-only source shows existing empty wallet state', (
    t,
  ) async {
    final s = LenlabStore(
      repository: MockLenlabRepository(latency: Duration.zero),
    )..signedIn = true;
    addTearDown(s.dispose);
    await t.pumpWidget(
      CustomerScope(
        store: s,
        child: MaterialApp(
          theme: P2.theme(),
          home: VoucherPage(
            source: MockVoucherSource(
              s,
              campaigns: const [
                PublicVoucherCampaign(
                  id: 'draft',
                  kind: WalletVoucherKind.cash,
                  label: 'Draft',
                  title: 'Not published',
                  description: '',
                  expiry: '',
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(find.text('Bạn chưa có voucher nào'), findsOneWidget);
    expect(find.text('Not published'), findsNothing);
    expect(s.coupon, isEmpty);
    expect(t.takeException(), isNull);
  });
}
