import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_shared/lenlab_shared.dart';
import 'package:lenlab_customer/app/customer_scope.dart';
import 'package:lenlab_customer/features/profile/data/avatar_picker_source.dart';
import 'package:lenlab_customer/features/profile/presentation/profile_editor_page.dart';
import 'package:lenlab_customer/features/address_book/presentation/address_book_page.dart';
import 'package:lenlab_customer/features/address_book/presentation/address_editor_page.dart';
import 'package:lenlab_customer/features/checkout/presentation/cod_success_page.dart';
import 'package:lenlab_customer/features/reviews/data/review_photo_picker.dart';
import 'package:lenlab_customer/features/reviews/presentation/post_purchase_review_page.dart';
import 'package:lenlab_customer/features/orders/presentation/order_detail_page.dart';

class WaitingAvatar implements AvatarPickerSource {
  final result = Completer<Uint8List?>();
  @override
  Future<Uint8List?> pick() => result.future;
  @override
  Future<Uint8List?> recover() async => null;
}

class WaitingPhotos implements ReviewPhotoPicker {
  final result = Completer<List<ReviewPhoto>>();
  @override
  Future<List<ReviewPhoto>> pick({required int remaining}) => result.future;
}

void main() {
  LenlabStore sample() =>
      LenlabStore(repository: MockLenlabRepository(latency: Duration.zero));
  Future<void> login(
    WidgetTester t,
    LenlabStore s,
    CustomerIdentity user, {
    bool logout = false,
  }) async {
    await t.runAsync(() async {
      if (logout) s.logout();
      await s.signIn(identity: user.email, password: 'mock');
    });
  }

  Future<void> host(WidgetTester t, LenlabStore s, Widget page) async {
    t.view.physicalSize = const Size(430, 1200);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.pumpWidget(
      CustomerScope(
        store: s,
        child: MaterialApp(theme: P2.theme(), home: page),
      ),
    );
    await t.pumpAndSettle();
  }

  Future<void> finishImages(WidgetTester t) async {
    await t.pump();
    await t.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await t.pumpAndSettle();
  }

  final png = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
  );

  testWidgets(
    'coalesced A logout B rebuilds profile controllers and ignores A picker',
    (t) async {
      final s = sample();
      addTearDown(s.dispose);
      await login(t, s, mockCustomerA);
      final a = s.profile;
      final picker = WaitingAvatar();
      await host(t, s, ProfileEditorPage(avatarPicker: picker));
      await t.enterText(
        find.byKey(const ValueKey('profile-name')),
        'Private A draft',
      );
      await t.tap(find.text('Đổi ảnh đại diện'));
      await t.pump();
      await login(
        t,
        s,
        mockCustomerB,
        logout: true,
      ); // No Guest frame in between.
      await t.pumpAndSettle();
      expect(
        t
            .widget<TextFormField>(find.byKey(const ValueKey('profile-name')))
            .controller!
            .text,
        mockCustomerB.name,
      );
      expect(find.text('Private A draft'), findsNothing);
      picker.result.complete(png);
      await finishImages(t);
      expect(s.profile.avatarBytes, isNull);
      expect(a.avatarBytes, isNull);
      expect(a.name, mockCustomerA.name);
      await login(t, s, mockCustomerA, logout: true);
      await t.pumpAndSettle();
      expect(
        t
            .widget<TextFormField>(find.byKey(const ValueKey('profile-name')))
            .controller!
            .text,
        mockCustomerA.name,
      );
      expect(t.takeException(), isNull);
    },
  );

  testWidgets('old address editor argument cannot populate B form', (t) async {
    final s = sample();
    addTearDown(s.dispose);
    await login(t, s, mockCustomerA);
    final address = s.addresses.single;
    await host(t, s, AddressEditorPage(address: address));
    expect(find.text(address.street), findsOneWidget);
    await login(t, s, mockCustomerB, logout: true);
    await t.pumpAndSettle();
    expect(find.text(address.street), findsNothing);
    expect(find.byType(TextFormField), findsNothing);
    expect(s.addresses, isEmpty);
  });

  testWidgets('private delete-address dialog closes when the session changes', (
    t,
  ) async {
    final s = sample();
    addTearDown(s.dispose);
    await login(t, s, mockCustomerA);
    s.addresses.add(
      const Address(
        ownerId: mockCustomerAId,
        name: 'A only recipient',
        isDefault: false,
      ),
    );
    await host(t, s, const AddressBookPage());
    final delete = find.text('Xóa');
    await t.ensureVisible(delete.last);
    await t.tap(delete.last);
    await t.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await login(t, s, mockCustomerB, logout: true);
    await t.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.textContaining('A only recipient'), findsNothing);
    expect(s.addresses, isEmpty);
  });

  testWidgets(
    'review photo result and comment draft from A never appear in B',
    (t) async {
      final s = sample();
      addTearDown(s.dispose);
      await login(t, s, mockCustomerA);
      final picker = WaitingPhotos();
      await host(
        t,
        s,
        PostPurchaseReviewPage(orderId: 'WOOL-8805', photoPicker: picker),
      );
      await t.enterText(find.byType(TextField), 'Private A review draft');
      FocusManager.instance.primaryFocus?.unfocus();
      final add = find.byKey(const ValueKey('review-add-photos'));
      await t.ensureVisible(add);
      await t.tap(add);
      await t.pump();
      await login(t, s, mockCustomerB, logout: true);
      await t.pumpAndSettle();
      picker.result.complete([ReviewPhoto(name: 'A.png', bytes: png)]);
      await finishImages(t);
      expect(find.text('Private A review draft'), findsNothing);
      expect(find.byKey(const ValueKey('review-add-photos')), findsNothing);
      expect(
        s.productReviews.where((r) => r.authorId == mockCustomerA.id),
        isEmpty,
      );
      await login(t, s, mockCustomerA, logout: true);
      await t.pumpAndSettle();
      expect(
        t.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
      expect(find.text('Thêm ảnh (0/5)'), findsOneWidget);
      expect(t.takeException(), isNull);
    },
  );

  testWidgets(
    'B cannot render A detail or receipt from retained route arguments',
    (t) async {
      final s = sample();
      addTearDown(s.dispose);
      await login(t, s, mockCustomerA);
      final order = s.orders.first;
      await login(t, s, mockCustomerB);
      await host(t, s, OrderDetailPage(orderId: order.id));
      expect(find.textContaining(order.id), findsNothing);
      await t.pumpWidget(const SizedBox());
      await t.pumpWidget(
        CustomerScope(
          store: s,
          child: MaterialApp(
            theme: P2.theme(),
            home: CodSuccessPage(order: order),
          ),
        ),
      );
      await t.pumpAndSettle();
      expect(find.text('Đặt hàng thành công!'), findsNothing);
      expect(find.textContaining(order.id), findsNothing);
    },
  );
}
