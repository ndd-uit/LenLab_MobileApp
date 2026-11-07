import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_customer/app/customer_app.dart';
import 'package:lenlab_customer/features/address_book/data/address_book_actions.dart';
import 'package:lenlab_customer/features/address_book/data/address_editor_source.dart';
import 'package:lenlab_customer/features/address_book/presentation/widgets/address_book_card.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

const other = Address(
  ownerId: mockCustomerAId,
  name: 'Trần Thị B',
  street: '456 Đường Mới',
  isDefault: false,
);
LenlabStore sample() =>
    LenlabStore(
        repository: MockLenlabRepository(
          latency: const Duration(milliseconds: 100),
        ),
      )
      ..signedIn = true
      ..addresses.add(other);
void viewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(360, 1000);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = 1.2;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

Finder card(String name) => find.byWidgetPredicate(
  (w) => w is AddressBookCard && w.address.name == name,
);
Finder action(String name, String label) =>
    find.descendant(of: card(name), matching: find.text(label));

void main() {
  test(
    'Set default is exclusive and never changes delivery/order snapshots',
    () async {
      final s = sample();
      final original = s.addresses.first;
      s.deliveryAddress = original;
      final orderAddress = s.orders.first.address;
      final result = await MockAddressBookActions(s).setDefault(other);
      expect(result.where((a) => a.isDefault).single.name, other.name);
      expect(s.addresses.first.isDefault, isFalse);
      expect(s.addresses.first.full, original.full);
      expect(s.deliveryAddress, same(original));
      expect(s.deliveryAddress!.isDefault, isTrue);
      expect(s.orders.first.address, same(orderAddress));
      expect(() => result.clear(), throwsUnsupportedError);
    },
  );

  test('Delete protects default, preserves active checkout, permits empty nondefault book', () async {
    final s = sample();
    final actions = MockAddressBookActions(s);
    s.deliveryAddress = other;
    await expectLater(
      actions.remove(s.addresses.first),
      throwsA(isA<RepositoryException>()),
    );
    final result = await actions.remove(other);
    expect(result.length, 1);
    expect(s.deliveryAddress, same(other));
    s.addresses
      ..clear()
      ..add(other);
    expect(await actions.remove(other), isEmpty);
    expect(s.deliveryAddress, same(other));
  });

  test(
    'Failed/stale/signed-out mutations leave saved data intact and can retry',
    () async {
      final s = sample();
      final original = List.of(s.addresses);
      final actions = MockAddressBookActions(s);
      final repo = s.repository as MockLenlabRepository;
      for (final operation in ['deleteBookAddress', 'setDefaultBookAddress']) {
        repo.failNext(operation);
        await expectLater(
          operation == 'deleteBookAddress'
              ? actions.remove(other)
              : actions.setDefault(other),
          throwsA(isA<RepositoryException>()),
        );
        expect(s.addresses, orderedEquals(original));
      }
      await expectLater(
        actions.setDefault(
          const Address(ownerId: mockCustomerAId, street: 'Missing'),
        ),
        throwsA(isA<RepositoryException>()),
      );
      final pending = actions.setDefault(other);
      s.signedIn = false;
      await expectLater(pending, throwsA(isA<RepositoryException>()));
      expect(s.addresses, isEmpty);
      s.signedIn = true;
      expect(s.addresses, orderedEquals(original));
      await actions.setDefault(other);
      expect(s.addresses.last.isDefault, isTrue);
    },
  );

  test('Editor default saves atomically, preserves existing default on false and supports new default', () async {
    final s = sample();
    final editor = MockAddressEditorSource(s);
    final original = s.addresses.first;
    final defaultCopy = Address(
      ownerId: mockCustomerAId,
      name: other.name,
      street: other.street,
      isDefault: true,
    );
    (s.repository as MockLenlabRepository).failNext('saveBookAddress');
    await expectLater(
      editor.save(defaultCopy, replacing: other),
      throwsA(isA<RepositoryException>()),
    );
    expect(s.addresses.first, same(original));
    final saved = await editor.save(defaultCopy, replacing: other);
    expect(saved.isDefault, isTrue);
    expect(s.addresses.where((a) => a.isDefault).length, 1);
    final retained = await editor.save(other, replacing: saved);
    expect(retained.isDefault, isTrue);
    await editor.save(
      const Address(
        ownerId: mockCustomerAId,
        name: 'Địa chỉ mới',
        street: 'New',
        isDefault: true,
      ),
    );
    expect(s.addresses.where((a) => a.isDefault).single.name, 'Địa chỉ mới');
    expect(s.deliveryAddress, isNull);
  });

  testWidgets(
    'Default selection loading/error/retry updates badge and locks Back without changing draft',
    (tester) async {
      viewport(tester);
      final s = sample()..deliveryAddress = other;
      await tester.pumpWidget(
        CustomerApp(store: s, initialRoute: '/addresses'),
      );
      await tester.pumpAndSettle();
      (s.repository as MockLenlabRepository).failNext('setDefaultBookAddress');
      await tester.tap(find.byTooltip('Đặt ${other.name} làm mặc định'));
      await tester.pump();
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Sổ địa chỉ'), findsOneWidget);
      expect(find.text('Thử lại'), findsOneWidget);
      expect(s.addresses.first.isDefault, isTrue);
      await tester.tap(find.text('Thử lại'));
      await tester.pumpAndSettle();
      expect(s.addresses.last.isDefault, isTrue);
      expect(action(other.name, 'Xóa'), findsNothing);
      expect(action('Nguyễn Văn A', 'Xóa'), findsOneWidget);
      expect(s.deliveryAddress, same(other));
      expect(find.text('MẶC ĐỊNH'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Delete cancel, confirm failure and retry; last nondefault deletion shows empty book',
    (tester) async {
      viewport(tester);
      final s = sample()..deliveryAddress = other;
      s.addresses.removeAt(0);
      await tester.pumpWidget(
        CustomerApp(store: s, initialRoute: '/addresses'),
      );
      await tester.pumpAndSettle();
      await tester.tap(action(other.name, 'Xóa'));
      await tester.pumpAndSettle();
      expect(find.text('Xóa địa chỉ?'), findsOneWidget);
      await tester.tap(find.text('Giữ lại'));
      await tester.pumpAndSettle();
      expect(s.addresses.single, same(other));
      await tester.tap(action(other.name, 'Xóa'));
      await tester.pumpAndSettle();
      (s.repository as MockLenlabRepository).failNext('deleteBookAddress');
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Xóa'),
        ),
      );
      await tester.pumpAndSettle();
      expect(s.addresses.single, same(other));
      expect(find.text('Thử lại'), findsOneWidget);
      await tester.tap(find.text('Thử lại'));
      await tester.pumpAndSettle();
      expect(find.text('Bạn chưa có địa chỉ đã lưu'), findsOneWidget);
      expect(s.addresses, isEmpty);
      expect(s.deliveryAddress, same(other));
      expect(find.text('Thêm địa chỉ mới'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Editor default is local until Save; cancel discards, failed Save retains toggle then commits',
    (tester) async {
      viewport(tester);
      final s = sample();
      await tester.pumpWidget(
        CustomerApp(store: s, initialRoute: '/addresses'),
      );
      await tester.pumpAndSettle();
      Future<void> toggleEditor() async {
        await tester.tap(action(other.name, 'Sửa'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byType(Switch));
        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();
      }

      await toggleEditor();
      expect(s.addresses.first.isDefault, isTrue);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(s.addresses.last.isDefault, isFalse);
      await toggleEditor();
      (s.repository as MockLenlabRepository).failNext('saveBookAddress');
      await tester.tap(find.text('Lưu').first);
      await tester.pumpAndSettle();
      expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
      expect(s.addresses.last.isDefault, isFalse);
      await tester.tap(find.text('Lưu').first);
      await tester.pumpAndSettle();
      expect(s.addresses.last.isDefault, isTrue);
      expect(s.addresses.first.isDefault, isFalse);
      expect(find.text('MẶC ĐỊNH'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
