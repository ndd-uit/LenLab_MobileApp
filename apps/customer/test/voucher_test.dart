import 'package:lenlab_customer/features/auth/presentation/auth_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_customer/app/customer_app.dart';
import 'package:lenlab_customer/app/customer_scope.dart';
import 'package:lenlab_customer/features/vouchers/data/voucher_source.dart';
import 'package:lenlab_customer/features/vouchers/presentation/voucher_page.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

void main() {
  for (final width in [360.0, 390.0, 430.0]) {
    testWidgets(
      'vouchers $width text120 keeps display and selection never changes checkout',
      (tester) async {
        tester.view.physicalSize = Size(width, 1000);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 1.2;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final store =
            LenlabStore(
                repository: MockLenlabRepository(latency: Duration.zero),
              )
              ..signedIn = true
              ..coupon = 'LEN50';
        await tester.pumpWidget(
          CustomerApp(store: store, initialRoute: '/vouchers'),
        );
        await tester.pumpAndSettle();
        expect(find.text('LEN20'), findsOneWidget);
        await tester.scrollUntilVisible(
          find.text('Tặng bộ kim đan'),
          250,
          scrollable: find.descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          ),
        );
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.text('LEN20'),
          -250,
          scrollable: find.descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          ),
        );
        await tester.tap(find.text('Dùng ngay').first);
        await tester.pumpAndSettle();
        expect(store.voucherCandidate?.campaignId, 'p2-len20');
        expect(find.text('Áp dụng thành công'), findsNothing);
        expect(store.coupon, 'LEN50');
        expect(store.discount, 50000);
        expect(store.cartCount, 3);
        expect(store.orders, hasLength(4));
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'loading error retry and input validation do not claim voucher applied',
    (tester) async {
      final repo = MockLenlabRepository(
        latency: const Duration(milliseconds: 200),
      )..failNext('vouchers');
      final store = LenlabStore(repository: repo)
        ..signedIn = true
        ..coupon = 'LEN50';
      await tester.pumpWidget(
        CustomerApp(store: store, initialRoute: '/vouchers'),
      );
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('Không thể tải voucher'), findsOneWidget);
      await tester.tap(find.text('Thử lại'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Áp dụng'));
      await tester.pump();
      expect(find.text('Vui lòng nhập mã voucher.'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'LEN20');
      await tester.tap(find.text('Áp dụng'));
      await tester.pumpAndSettle();
      expect(
        find.text('Voucher chưa có đủ cấu hình để áp dụng.'),
        findsOneWidget,
      );
      expect(store.coupon, 'LEN50');
    },
  );
  testWidgets('profile wallet logout keeps public data without private usage', (
    tester,
  ) async {
    final store =
        LenlabStore(repository: MockLenlabRepository(latency: Duration.zero))
          ..signedIn = true
          ..coupon = 'LEN50';
    await tester.pumpWidget(
      CustomerApp(store: store, initialRoute: '/profile'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Voucher của tôi'));
    await tester.pumpAndSettle();
    expect(find.byType(VoucherPage), findsOneWidget);
    store.signedIn = false;
    store.changed();
    await tester.pumpAndSettle();
    expect(find.byType(AuthPage), findsNothing);
    expect(find.text('LEN20'), findsOneWidget);
    expect(find.text('Đã dùng'), findsNothing);
  });
  testWidgets('empty wallet has explicit empty state', (tester) async {
    final store = LenlabStore()
      ..signedIn = true
      ..coupon = 'LEN50';
    await tester.pumpWidget(
      CustomerScope(
        store: store,
        child: MaterialApp(
          theme: P2.theme(),
          home: VoucherPage(source: FixedVouchers(const [])),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Bạn chưa có voucher nào'), findsOneWidget);
  });
  testWidgets(
    'copy only real source code, failure retries without mutating wallet',
    (tester) async {
      final store = LenlabStore()
        ..signedIn = true
        ..coupon = 'LEN50';
      var calls = 0;
      final copied = <String>[];
      const voucher = WalletVoucher(
        id: 'with-code',
        kind: WalletVoucherKind.cash,
        label: '50K',
        title: 'Mã kiểm thử',
        description: 'Dữ liệu nguồn thử nghiệm',
        expiry: '31/12/2026',
        code: 'SOURCE-CODE',
      );
      await tester.pumpWidget(
        CustomerScope(
          store: store,
          child: MaterialApp(
            theme: P2.theme(),
            home: VoucherPage(
              source: FixedVouchers(const [voucher]),
              copyCode: (code) async {
                if (calls++ == 0) throw StateError('clipboard failure');
                copied.add(code);
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sao chép'));
      await tester.pump();
      expect(
        find.text('Không thể sao chép. Vui lòng thử lại.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Sao chép'));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      expect(copied, ['SOURCE-CODE']);
      expect(store.coupon, 'LEN50');
    },
  );
  testWidgets('P2 cash voucher with no code reports missing code', (
    tester,
  ) async {
    final store = LenlabStore()
      ..signedIn = true
      ..coupon = 'LEN50';
    var copied = false;
    await tester.pumpWidget(
      CustomerScope(
        store: store,
        child: MaterialApp(
          theme: P2.theme(),
          home: VoucherPage(
            source: FixedVouchers([
              WalletVoucher.fromCampaign(mockPublicVoucherCampaigns[3]),
            ]),
            copyCode: (_) async {
              copied = true;
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sao chép'));
    await tester.pump();
    expect(
      find.text('Voucher mẫu này chưa có mã để sao chép.'),
      findsOneWidget,
    );
    expect(copied, isFalse);
  });
}

class FixedVouchers implements VoucherSource {
  FixedVouchers(this.vouchers);
  final List<WalletVoucher> vouchers;
  @override
  Future<List<WalletVoucher>> load() async => vouchers;
}
