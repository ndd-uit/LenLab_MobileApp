import 'package:lenlab_customer/features/checkout/presentation/widgets/address_select.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_customer/app/customer_app.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

Future<void> chooseSaved(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Chọn'));
  await tester.tap(find.text('Chọn'));
  await tester.pumpAndSettle();
  await tester.tap(find.byType(ListTile).first);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('new address selects dependent regions and saves once', (
    tester,
  ) async {
    final store =
        LenlabStore(repository: MockLenlabRepository(latency: Duration.zero))
          ..signedIn = true
          ..coupon = 'LEN50'
          ..addresses.clear();
    await tester.pumpWidget(
      CustomerApp(initialRoute: '/checkout', store: store),
    );
    await tester.pumpAndSettle();
    for (final choice in [
      ('Tỉnh / Thành phố', 'TP. Hồ Chí Minh'),
      ('Quận / Huyện', 'Quận 1'),
      ('Phường / Xã', 'Phường Bến Nghé'),
    ]) {
      final field = find.descendant(
        of: find.byWidgetPredicate(
          (w) => w is AddressSelect && w.label == choice.$1,
        ),
        matching: find.byType(DropdownButtonFormField<String>),
      );
      await tester.ensureVisible(field);
      await tester.tap(field);
      await tester.pumpAndSettle();
      await tester.tap(find.text(choice.$2).last);
      await tester.pumpAndSettle();
    }
    final street = find.byKey(const ValueKey('address-street'));
    await tester.ensureVisible(street);
    await tester.enterText(street, '88 Đường mẫu');
    await tester.ensureVisible(find.byType(Switch));
    await tester.tap(find.byType(Switch));
    await tester.pump();
    await tester.tap(find.text('Xem lại đơn hàng'));
    await tester.pumpAndSettle();
    expect(store.addresses.single.street, '88 Đường mẫu');
    expect(store.deliveryAddress!.city, 'TP. Hồ Chí Minh');
    expect(store.orders.length, 4);
    expect(tester.takeException(), isNull);
  });
  for (final width in [360.0, 390.0, 430.0]) {
    testWidgets(
      'address $width keyboard and large text validate and retain checkout draft',
      (tester) async {
        tester.view.physicalSize = Size(width, 929);
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
          CustomerApp(initialRoute: '/checkout', store: store),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Xem lại đơn hàng'));
        await tester.pumpAndSettle();
        expect(find.text('Vui lòng nhập địa chỉ cụ thể.'), findsOneWidget);
        expect(store.deliveryAddress, isNull);
        await chooseSaved(tester);
        tester.view.viewInsets = const FakeViewPadding(bottom: 300);
        addTearDown(tester.view.resetViewInsets);
        final street = find.byKey(const ValueKey('address-street'));
        await tester.ensureVisible(street);
        await tester.enterText(street, '45 Đường mẫu');
        await tester.pumpAndSettle();
        await tester.tap(find.text('Xem lại đơn hàng'));
        await tester.pumpAndSettle();
        expect(store.deliveryAddress!.street, '45 Đường mẫu');
        expect(store.addresses.single.street, '123 Đường Nguyễn Huệ');
        expect(store.orders.length, 4);
        expect(find.text('Tổng quan đơn hàng'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'address load failure retries then save failure retains form and succeeds once',
    (tester) async {
      final repo = MockLenlabRepository(
        latency: const Duration(milliseconds: 300),
      )..failNext('addresses');
      final store = LenlabStore(repository: repo)
        ..signedIn = true
        ..coupon = 'LEN50';
      await tester.pumpWidget(
        CustomerApp(initialRoute: '/checkout', store: store),
      );
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('Không thể tải địa chỉ'), findsOneWidget);
      await tester.tap(find.text('Thử lại'));
      await tester.pumpAndSettle();
      await chooseSaved(tester);
      await tester.ensureVisible(find.byKey(const ValueKey('address-street')));
      await tester.enterText(
        find.byKey(const ValueKey('address-street')),
        '99 Đường mẫu',
      );
      await tester.ensureVisible(find.byType(Switch));
      await tester.tap(find.byType(Switch));
      await tester.pump();
      repo.failNext('saveAddress');
      await tester.tap(find.text('Xem lại đơn hàng'));
      await tester.pump();
      expect(find.text('Đang lưu địa chỉ…'), findsOneWidget);
      expect(
        tester
            .widget<ElevatedButton>(
              find.widgetWithText(ElevatedButton, 'Đang lưu địa chỉ…'),
            )
            .onPressed,
        isNull,
      );
      await tester.pumpAndSettle();
      expect(find.text('Không thể kết nối. Vui lòng thử lại.'), findsOneWidget);
      expect(store.deliveryAddress, isNull);
      expect(store.addresses.single.street, '123 Đường Nguyễn Huệ');
      await tester.tap(find.text('Xem lại đơn hàng'));
      await tester.pumpAndSettle();
      expect(store.addresses.length, 1);
      expect(store.deliveryAddress!.street, '99 Đường mẫu');
      expect(store.addresses.single.street, '99 Đường mẫu');
      expect(store.orders.length, 4);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'changing city clears dependent choices and invalid phone blocks submission',
    (tester) async {
      await tester.pumpWidget(
        CustomerApp(
          initialRoute: '/checkout',
          store:
              LenlabStore(
                  repository: MockLenlabRepository(latency: Duration.zero),
                )
                ..signedIn = true
                ..coupon = 'LEN50',
        ),
      );
      await tester.pumpAndSettle();
      await chooseSaved(tester);
      await tester.enterText(
        find.byKey(const ValueKey('address-phone')),
        '123',
      );
      final city = find.descendant(
        of: find.byWidgetPredicate(
          (w) => w is AddressSelect && w.label == 'Tỉnh / Thành phố',
        ),
        matching: find.byType(DropdownButtonFormField<String>),
      );
      await tester.ensureVisible(city);
      await tester.tap(city);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hà Nội').last);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<AddressSelect>(
              find.byWidgetPredicate(
                (w) => w is AddressSelect && w.label == 'Quận / Huyện',
              ),
            )
            .value,
        isNull,
      );
      expect(
        tester
            .widget<AddressSelect>(
              find.byWidgetPredicate(
                (w) => w is AddressSelect && w.label == 'Phường / Xã',
              ),
            )
            .value,
        isNull,
      );
      await tester.tap(find.text('Xem lại đơn hàng'));
      await tester.pumpAndSettle();
      expect(
        find.text('Số điện thoại gồm 10 chữ số, bắt đầu bằng 0.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('empty saved addresses and empty cart offer usable paths', (
    tester,
  ) async {
    final store =
        LenlabStore(repository: MockLenlabRepository(latency: Duration.zero))
          ..signedIn = true
          ..coupon = 'LEN50'
          ..addresses.clear();
    await tester.pumpWidget(
      CustomerApp(initialRoute: '/checkout', store: store),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chọn'));
    await tester.pumpAndSettle();
    expect(
      find.text('Chưa có địa chỉ đã lưu. Bạn có thể nhập địa chỉ bên dưới.'),
      findsOneWidget,
    );
    store.cart.clear();
    store.changed();
    Navigator.of(tester.element(find.text('Địa chỉ đã lưu'))).pop();
    await tester.pumpAndSettle();
    expect(find.text('Giỏ hàng đang trống'), findsOneWidget);
    expect(find.text('Xem lại đơn hàng'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
