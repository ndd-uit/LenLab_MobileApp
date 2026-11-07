import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_customer/app/customer_app.dart';
import 'package:lenlab_customer/app/customer_scope.dart';
import 'package:lenlab_customer/features/checkout/presentation/bank_transfer_page.dart';
import 'package:lenlab_customer/features/checkout/presentation/widgets/bank_transfer_details.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

class _CustomTransferSource implements BankTransferSource {
  @override
  Future<BankTransferPreview> preview({
    required int subtotal,
    required int discount,
    required Address address,
    required String reference,
  }) async => BankTransferPreview(
    totals: OrderReviewTotals(
      subtotal: subtotal,
      discount: discount,
      shipping: 15000,
    ),
    reference: reference,
    bank: 'NGÂN HÀNG MẪU',
    holder: 'TÊN MẪU',
    account: '0000000000',
  );
}

void main() {
  for (final width in [360.0, 390.0, 430.0]) {
    testWidgets(
      'transfer $width text120 clipboard preserves checkout without proof UI',
      (tester) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 1.2;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        String? copied;
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          (call) async {
            if (call.method == 'Clipboard.setData') {
              copied = (call.arguments as Map)['text'] as String;
            }
            return null;
          },
        );
        addTearDown(
          () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            SystemChannels.platform,
            null,
          ),
        );
        final store =
            LenlabStore(
                repository: MockLenlabRepository(latency: Duration.zero),
              )
              ..signedIn = true
              ..coupon = 'LEN50'
              ..deliveryAddress = const Address(ownerId: mockCustomerAId)
              ..checkoutNote = 'Gói quà';
        await tester.pumpWidget(
          CustomerApp(initialRoute: '/bank-transfer', store: store),
        );
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<BankTransferDetails>(find.byType(BankTransferDetails))
              .preview
              .totals
              .total,
          1880000,
        );
        await tester.tap(find.text('Lưu mã QR'));
        await tester.pumpAndSettle();
        expect(find.text('QR minh họa'), findsOneWidget);
        await tester.tap(find.text('Đóng'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byTooltip('Sao chép số tài khoản'));
        await tester.tap(find.byTooltip('Sao chép số tài khoản'));
        await tester.pumpAndSettle();
        expect(copied, '1040614582');
        await tester.ensureVisible(find.byTooltip('Sao chép nội dung'));
        await tester.tap(find.byTooltip('Sao chép nội dung'));
        await tester.pumpAndSettle();
        expect(copied, store.bankTransferReference);
        expect(find.text('Tải ảnh minh chứng'), findsNothing);
        expect(find.text('Xác nhận chuyển khoản'), findsNothing);
        expect(find.text('Gửi xác nhận chuyển khoản'), findsNothing);
        expect(find.textContaining('Gửi minh chứng để shop'), findsNothing);
        expect(store.orders.length, 4);
        expect(store.cartCount, 3);
        expect(store.checkoutNote, 'Gói quà');
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'transfer load error retry and cart updates retain draft reference',
    (tester) async {
      final repo = MockLenlabRepository(
        latency: const Duration(milliseconds: 300),
      )..failNext('bankTransfer');
      final store = LenlabStore(repository: repo)
        ..signedIn = true
        ..coupon = 'LEN50'
        ..deliveryAddress = const Address(ownerId: mockCustomerAId)
        ..checkoutNote = 'Giao chiều';
      await tester.pumpWidget(
        CustomerApp(initialRoute: '/bank-transfer', store: store),
      );
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(BankTransferDetails), findsNothing);
      await tester.pumpAndSettle();
      expect(find.text('Không thể tải thông tin chuyển khoản'), findsOneWidget);
      await tester.tap(find.text('Thử lại'));
      await tester.pumpAndSettle();
      final reference = store.bankTransferReference;
      store.changeQuantity(store.cart.first, 1);
      await tester.pump();
      expect(find.byType(BankTransferDetails), findsNothing);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<BankTransferDetails>(find.byType(BankTransferDetails))
            .preview
            .totals
            .total,
        3080000,
      );
      expect(store.bankTransferReference, reference);
      expect(store.checkoutNote, 'Giao chiều');
      expect(store.orders.length, 4);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('transfer guards missing address and empty cart', (tester) async {
    final store =
        LenlabStore(repository: MockLenlabRepository(latency: Duration.zero))
          ..signedIn = true
          ..coupon = 'LEN50';
    await tester.pumpWidget(
      CustomerApp(initialRoute: '/bank-transfer', store: store),
    );
    await tester.pumpAndSettle();
    expect(find.text('Chưa có địa chỉ nhận hàng'), findsOneWidget);
    expect(find.byType(BankTransferDetails), findsNothing);
    expect(store.bankTransferReference, isNull);
    store.cart.clear();
    store.changed();
    await tester.pumpAndSettle();
    expect(find.text('Giỏ hàng đang trống'), findsOneWidget);
    expect(find.text('Lưu mã QR'), findsNothing);
  });

  testWidgets(
    'transfer uses injected data source for amounts and account details',
    (tester) async {
      final store =
          LenlabStore(repository: MockLenlabRepository(latency: Duration.zero))
            ..signedIn = true
            ..coupon = 'LEN50'
            ..deliveryAddress = const Address(ownerId: mockCustomerAId);
      await tester.pumpWidget(
        CustomerScope(
          store: store,
          child: MaterialApp(
            theme: P2.theme(),
            home: BankTransferPage(source: _CustomTransferSource()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final preview = tester
          .widget<BankTransferDetails>(find.byType(BankTransferDetails))
          .preview;
      expect(preview.totals.total, 1865000);
      expect(preview.account, '0000000000');
      expect(preview.holder, 'TÊN MẪU');
      expect(store.orders.length, 4);
    },
  );

  testWidgets('clipboard failure reports an error without changing payment', (
    tester,
  ) async {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          throw PlatformException(code: 'clipboard-failed');
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    final store =
        LenlabStore(repository: MockLenlabRepository(latency: Duration.zero))
          ..signedIn = true
          ..coupon = 'LEN50'
          ..deliveryAddress = const Address(ownerId: mockCustomerAId);
    await tester.pumpWidget(
      CustomerApp(initialRoute: '/bank-transfer', store: store),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byTooltip('Sao chép số tài khoản'));
    await tester.tap(find.byTooltip('Sao chép số tài khoản'));
    await tester.pumpAndSettle();
    expect(find.text('Không thể sao chép. Vui lòng thử lại.'), findsOneWidget);
    expect(store.cartCount, 3);
    expect(store.orders.length, 4);
    expect(tester.takeException(), isNull);
  });
}
