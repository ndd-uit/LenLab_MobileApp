import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_customer/app/customer_app.dart';
import 'package:lenlab_customer/features/address_book/data/address_editor_source.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

void main() {
  testWidgets(
    'editor region load retries and keyboard keeps street editable; cancel preserves saved data',
    (tester) async {
      tester.view.physicalSize = const Size(360, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
      final repo = MockLenlabRepository(latency: Duration.zero)
        ..failNext('addressEditor');
      final store = LenlabStore(repository: repo)
        ..signedIn = true
        ..coupon = 'LEN50';
      await tester.pumpWidget(
        CustomerApp(store: store, initialRoute: '/addresses'),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Thêm địa chỉ mới'));
      await tester.pumpAndSettle();
      expect(find.text('Không thể tải dữ liệu địa chỉ'), findsOneWidget);
      await tester.tap(find.text('Thử lại'));
      await tester.pumpAndSettle();
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pumpAndSettle();
      final field = find.byKey(const ValueKey('editor-street'));
      await tester.ensureVisible(field);
      await tester.tap(field);
      await tester.enterText(field, 'Chưa lưu');
      await tester.pumpAndSettle();
      expect(tester.getBottomRight(field).dy, lessThanOrEqualTo(600));
      await tester.tap(find.byTooltip('Quay lại').last);
      await tester.pumpAndSettle();
      expect(store.addresses, hasLength(1));
      expect(store.addresses.single.street, isNot('Chưa lưu'));
      expect(tester.takeException(), isNull);
    },
  );
  for (final width in [360.0, 390.0, 430.0]) {
    testWidgets(
      'editor $width edit failure preserves input then saves once without changing draft',
      (tester) async {
        tester.view.physicalSize = Size(width, 1000);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 1.2;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final repo = MockLenlabRepository(
          latency: const Duration(milliseconds: 200),
        )..failNext('saveBookAddress');
        final store = LenlabStore(repository: repo)
          ..signedIn = true
          ..coupon = 'LEN50';
        final draft = store.addresses.first;
        store.deliveryAddress = draft;
        await tester.pumpWidget(
          CustomerApp(store: store, initialRoute: '/addresses'),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Sửa').first);
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const ValueKey('editor-name')),
          'Tên đã sửa',
        );
        await tester.tap(find.text('Lưu').first);
        await tester.pumpAndSettle();
        expect(find.textContaining('Không thể kết nối'), findsOneWidget);
        expect(store.addresses.first, same(draft));
        await tester.tap(find.text('Lưu').first);
        await tester.pump();
        await tester.binding.handlePopRoute();
        await tester.pump();
        expect(find.text('Sửa địa chỉ'), findsOneWidget);
        await tester.pumpAndSettle();
        expect(store.addresses.single.name, 'Tên đã sửa');
        expect(store.addresses.single.isDefault, isTrue);
        expect(store.deliveryAddress, same(draft));
        expect(find.text('Sổ địa chỉ'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets('add validates required fields and cascading selectors reset', (
    tester,
  ) async {
    final store =
        LenlabStore(repository: MockLenlabRepository(latency: Duration.zero))
          ..signedIn = true
          ..coupon = 'LEN50';
    await tester.pumpWidget(
      CustomerApp(store: store, initialRoute: '/addresses'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Thêm địa chỉ mới'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lưu').first);
    await tester.pumpAndSettle();
    expect(find.text('Vui lòng nhập thông tin.'), findsWidgets);
    expect(store.addresses, hasLength(1));
    await tester.enterText(
      find.byKey(const ValueKey('editor-name')),
      'Khách mới',
    );
    await tester.enterText(
      find.byKey(const ValueKey('editor-phone')),
      '0901234567',
    );
    Future<void> choose(int index, String text) async {
      final field = find.byType(DropdownButtonFormField<String>).at(index);
      await tester.ensureVisible(field);
      await tester.tap(field);
      await tester.pumpAndSettle();
      await tester.tap(find.text(text).last);
      await tester.pumpAndSettle();
    }

    await choose(0, 'TP. Hồ Chí Minh');
    await choose(1, 'Quận 1');
    await choose(2, 'Phường Bến Nghé');
    await choose(0, 'Hà Nội');
    expect(
      tester
          .widget<DropdownButtonFormField<String>>(
            find.byType(DropdownButtonFormField<String>).at(1),
          )
          .initialValue,
      isNull,
    );
    await choose(1, 'Quận Hoàn Kiếm');
    await choose(2, 'Phường Hàng Bạc');
    await tester.ensureVisible(find.byKey(const ValueKey('editor-street')));
    await tester.enterText(
      find.byKey(const ValueKey('editor-street')),
      '123 Phố Mới',
    );
    await tester.tap(find.text('Lưu').first);
    await tester.pumpAndSettle();
    expect(store.addresses, hasLength(2));
    expect(store.addresses.last.city, 'Hà Nội');
    expect(store.addresses.last.isDefault, isFalse);
    expect(store.deliveryAddress, isNull);
  });
  test(
    'source rejects stale edits and signed-out saves without mutation',
    () async {
      final store =
          LenlabStore(repository: MockLenlabRepository(latency: Duration.zero))
            ..signedIn = true
            ..coupon = 'LEN50';
      final source = MockAddressEditorSource(store);
      await expectLater(
        source.save(
          const Address(ownerId: mockCustomerAId),
          replacing: const Address(ownerId: mockCustomerAId, street: 'Missing'),
        ),
        throwsA(isA<RepositoryException>()),
      );
      expect(store.addresses, hasLength(1));
      store.signedIn = false;
      await expectLater(
        source.save(const Address(ownerId: mockCustomerAId)),
        throwsA(isA<RepositoryException>()),
      );
      expect(store.addresses, isEmpty);
      store.signedIn = true;
      store.coupon = 'LEN50';
      expect(store.addresses, hasLength(1));
    },
  );
}
