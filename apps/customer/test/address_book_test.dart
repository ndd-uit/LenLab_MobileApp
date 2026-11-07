import 'package:lenlab_customer/features/auth/presentation/auth_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_customer/app/customer_app.dart';
import 'package:lenlab_customer/features/address_book/presentation/address_book_page.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

void main() {
  for (final width in [360.0, 390.0, 430.0]) {
    testWidgets(
      'address book $width scales, scrolls and never changes checkout',
      (tester) async {
        tester.view.physicalSize = Size(width, 900);
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
        store.addresses.add(
          const Address(
            ownerId: mockCustomerAId,
            name: 'Tên người nhận rất dài cần xuống dòng',
            isDefault: false,
          ),
        );
        const draft = Address(ownerId: mockCustomerAId, street: 'Draft riêng');
        store.deliveryAddress = draft;
        await tester.pumpWidget(
          CustomerApp(store: store, initialRoute: '/addresses'),
        );
        await tester.pumpAndSettle();
        expect(find.text('MẶC ĐỊNH'), findsOneWidget);
        await tester.tap(find.text('Thêm địa chỉ mới'));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('editor-name')), findsOneWidget);
        expect(store.addresses, hasLength(2));
        expect(store.deliveryAddress, same(draft));
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets('address book failure retries and empty saved list is explicit', (
    tester,
  ) async {
    final repo = MockLenlabRepository(
      latency: const Duration(milliseconds: 200),
    )..failNext('addressBook');
    final store = LenlabStore(repository: repo)
      ..signedIn = true
      ..coupon = 'LEN50';
    store.addresses.clear();
    await tester.pumpWidget(
      CustomerApp(store: store, initialRoute: '/addresses'),
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Thử lại'));
    await tester.pumpAndSettle();
    expect(find.text('Bạn chưa có địa chỉ đã lưu'), findsOneWidget);
    expect(store.deliveryAddress, isNull);
  });
  testWidgets(
    'profile opens address book and guest does not expose saved data',
    (tester) async {
      final store =
          LenlabStore(repository: MockLenlabRepository(latency: Duration.zero))
            ..signedIn = true
            ..coupon = 'LEN50';
      await tester.pumpWidget(
        CustomerApp(store: store, initialRoute: '/profile'),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sổ địa chỉ'));
      await tester.pumpAndSettle();
      expect(find.byType(AddressBookPage), findsOneWidget);
      expect(find.text(store.addresses.first.phone), findsOneWidget);
      store.signedIn = false;
      store.changed();
      await tester.pumpAndSettle();
      expect(find.byType(AuthPage), findsOneWidget);
      expect(find.text(mockCustomerA.phone), findsNothing);
      expect(store.addresses, isEmpty);
    },
  );
}
