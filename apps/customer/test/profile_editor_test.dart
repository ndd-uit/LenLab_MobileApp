import 'package:lenlab_customer/features/auth/presentation/auth_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_customer/app/customer_app.dart';
import 'package:lenlab_customer/app/customer_scope.dart';
import 'package:lenlab_customer/features/profile/data/profile_editor_source.dart';
import 'package:lenlab_customer/features/profile/presentation/profile_editor_page.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

void main() {
  for (final width in [360.0, 390.0, 430.0]) {
    testWidgets(
      'profile editor $width retry keeps draft and successful save refreshes profile',
      (tester) async {
        tester.view.physicalSize = Size(width, 1000);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 1.2;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final repo = MockLenlabRepository(
          latency: const Duration(milliseconds: 200),
        )..failNext('saveProfile');
        final store = LenlabStore(repository: repo)
          ..signedIn = true
          ..coupon = 'LEN50';
        final oldName = store.profile.name, oldEmail = store.profile.email;
        await tester.pumpWidget(
          CustomerApp(store: store, initialRoute: '/profile'),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Sửa'));
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<TextField>(
                find.descendant(
                  of: find.byKey(const ValueKey('profile-email')),
                  matching: find.byType(TextField),
                ),
              )
              .readOnly,
          isTrue,
        );
        expect(find.byType(TextFormField), findsNWidgets(4));
        await tester.enterText(
          find.byKey(const ValueKey('profile-name')),
          'Khách đã cập nhật',
        );
        await tester.enterText(
          find.byKey(const ValueKey('profile-phone')),
          '0912 345 678',
        );
        await tester.tap(find.text('Lưu').first);
        await tester.pumpAndSettle();
        expect(find.textContaining('Không thể kết nối'), findsOneWidget);
        expect(store.profile.name, oldName);
        await tester.tap(find.text('Lưu').first);
        await tester.pump();
        await tester.binding.handlePopRoute();
        await tester.pump();
        expect(find.byType(ProfileEditorPage), findsOneWidget);
        await tester.pumpAndSettle();
        expect(find.text('Khách đã cập nhật'), findsOneWidget);
        expect(store.profile.phone, '0912345678');
        expect(store.profile.email, oldEmail);
        expect(store.deliveryAddress, isNull);
        expect(store.cartCount, 3);
        expect(tester.takeException(), isNull);
      },
    );
  }
  test('birthday validation checks calendar and leap days without imposing an age limit', () {
    expect(birthdayError('29/02/2024'), isNull);
    expect(birthdayError('31/04/1995'), isNotNull);
    expect(birthdayError('29/02/2023'), isNotNull);
    expect(birthdayError('10/24/1995'), isNotNull);
    expect(birthdayError('01/01/9999'), isNotNull);
    expect(birthdayError(''), isNull);
  });
  test('source saves allowed fields atomically and leaves email/avatar/order snapshots unchanged', () async {
    final repo = MockLenlabRepository(latency: Duration.zero)
      ..failNext('saveProfile');
    final store = LenlabStore(repository: repo)
      ..signedIn = true
      ..coupon = 'LEN50';
    store.profile.avatar = '00fc5.png';
    final source = MockProfileEditorSource(store);
    final old = await source.load();
    final address = store.orders.first.address;
    await expectLater(
      source.save(
        name: 'New',
        phone: '0901234567',
        gender: 'Nữ',
        birthday: '29/02/2024',
      ),
      throwsA(isA<RepositoryException>()),
    );
    expect(store.profile.name, old.name);
    await source.save(
      name: 'New',
      phone: '0901 234 567',
      gender: 'Nữ',
      birthday: '29/02/2024',
    );
    expect(store.profile.name, 'New');
    expect(store.profile.gender, 'Nữ');
    expect(store.profile.email, old.email);
    expect(store.profile.avatar, old.avatar);
    expect(store.orders.first.address, same(address));
    store.signedIn = false;
    await expectLater(
      source.save(name: 'No', phone: '0901234567', gender: 'Nam', birthday: ''),
      throwsA(isA<RepositoryException>()),
    );
    expect(store.profile.name, isEmpty);
    store.signedIn = true;
    store.coupon = 'LEN50';
    expect(store.profile.name, 'New');
  });
  testWidgets(
    'load retries, invalid data blocks save, keyboard scrolls date into view and cancel discards changes',
    (tester) async {
      tester.view.physicalSize = const Size(360, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
      final repo = MockLenlabRepository(latency: Duration.zero)
        ..failNext('profileEditor');
      final store = LenlabStore(repository: repo)
        ..signedIn = true
        ..coupon = 'LEN50';
      await tester.pumpWidget(
        CustomerApp(store: store, initialRoute: '/profile'),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sửa'));
      await tester.pumpAndSettle();
      expect(find.text('Không thể tải hồ sơ'), findsOneWidget);
      await tester.tap(find.text('Thử lại'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('profile-name')), '');
      await tester.enterText(
        find.byKey(const ValueKey('profile-phone')),
        '123',
      );
      await tester.tap(find.text('Lưu').first);
      await tester.pumpAndSettle();
      expect(find.text('Vui lòng nhập thông tin.'), findsOneWidget);
      expect(store.profile.name, 'Nguyễn Văn A');
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pumpAndSettle();
      final date = find.byKey(const ValueKey('profile-birthday'));
      await tester.ensureVisible(date);
      await tester.tap(date);
      await tester.enterText(date, '31/04/1995');
      await tester.pumpAndSettle();
      expect(tester.getBottomRight(date).dy, lessThanOrEqualTo(600));
      await tester.tap(find.byTooltip('Quay lại').last);
      await tester.pumpAndSettle();
      expect(store.profile.birthday, '01/01/1995');
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('guest cannot load or submit editor', (tester) async {
    final store = LenlabStore();
    await tester.pumpWidget(
      CustomerScope(
        store: store,
        child: MaterialApp(theme: P2.theme(), home: const ProfileEditorPage()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(AuthPage), findsOneWidget);
    expect(find.byKey(const ValueKey('profile-name')), findsNothing);
  });
}
