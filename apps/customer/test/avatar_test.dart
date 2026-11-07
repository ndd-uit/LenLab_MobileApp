import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_customer/app/customer_app.dart';
import 'package:lenlab_customer/app/customer_scope.dart';
import 'package:lenlab_customer/features/profile/data/avatar_picker_source.dart';
import 'package:lenlab_customer/features/profile/data/profile_editor_source.dart';
import 'package:lenlab_customer/features/profile/data/profile_source.dart';
import 'package:lenlab_customer/features/profile/presentation/profile_editor_page.dart';
import 'package:lenlab_customer/features/profile/presentation/widgets/profile_avatar.dart';
import 'package:lenlab_shared/lenlab_shared.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lenlab_customer/shared/data/gallery_selection_context.dart';

Uint8List png() => base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
);

class LostReviewImage extends ImagePicker {
  @override
  Future<LostDataResponse> retrieveLostData() async => LostDataResponse(
    files: [XFile.fromData(png(), name: 'review.png')],
    type: RetrieveType.image,
  );
}

class FakeAvatarPicker implements AvatarPickerSource {
  Uint8List? next, recovered;
  Object? error;
  Completer<Uint8List?>? pending;
  int calls = 0;
  @override
  Future<Uint8List?> pick() async {
    calls++;
    if (error != null) throw error!;
    return pending?.future ?? next;
  }

  @override
  Future<Uint8List?> recover() async => recovered;
}

LenlabStore sample() =>
    LenlabStore(repository: MockLenlabRepository(latency: Duration.zero))
      ..signedIn = true
      ..coupon = 'LEN50';
Future<void> settleImage(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.runAsync(() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
  });
  await tester.pumpAndSettle();
}

Future<void> host(
  WidgetTester tester,
  LenlabStore s,
  FakeAvatarPicker picker,
) async {
  await tester.pumpWidget(
    CustomerScope(
      store: s,
      child: MaterialApp(
        theme: P2.theme(),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileEditorPage(avatarPicker: picker),
                ),
              ),
              child: const Text('Edit'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Edit'));
  await settleImage(tester);
}

Future<void> choose(WidgetTester tester) async {
  await tester.tap(find.text('Đổi ảnh đại diện'));
  await settleImage(tester);
}

void main() {
  test('Android lost review image cannot be recovered as an avatar', () async {
    await GallerySelectionContext.begin('review');
    final picker = GalleryAvatarPicker(picker: LostReviewImage());
    await picker.startRecovery();
    expect(await picker.recover(), isNull);
    expect(await GallerySelectionContext.take(), isNull);
  });
  test('Image data is validated and immutable; failed save does not commit profile/avatar', () async {
    final s = sample();
    final source = MockProfileEditorSource(s);
    final checked = await validatedAvatar(png());
    expect(() => checked[0] = 0, throwsUnsupportedError);
    await expectLater(
      validatedAvatar(Uint8List(0)),
      throwsA(isA<RepositoryException>()),
    );
    await expectLater(
      validatedAvatar(Uint8List.fromList([1, 2, 3])),
      throwsA(isA<RepositoryException>()),
    );
    (s.repository as MockLenlabRepository).failNext('saveProfile');
    await expectLater(
      source.save(
        name: 'Changed',
        phone: '0901234567',
        gender: 'Nam',
        birthday: '',
        avatarBytes: checked,
      ),
      throwsA(isA<RepositoryException>()),
    );
    expect(s.profile.avatarBytes, isNull);
    expect(s.profile.name, 'Nguyễn Văn A');
    await source.save(
      name: 'Changed',
      phone: '0901234567',
      gender: 'Nam',
      birthday: '',
      avatarBytes: checked,
    );
    expect(s.profile.avatarBytes, orderedEquals(checked));
    expect((await source.load()).avatarBytes, same(s.profile.avatarBytes));
    expect(
      (await MockProfileSource(s).load()).avatarBytes,
      same(s.profile.avatarBytes),
    );
    final saved = s.profile.avatarBytes;
    await source.save(
      name: 'Again',
      phone: '0901234567',
      gender: 'Nam',
      birthday: '',
    );
    expect(s.profile.avatarBytes, same(saved));
    s.signedIn = false;
    await expectLater(
      source.save(
        name: 'No',
        phone: '0901234567',
        gender: 'Nam',
        birthday: '',
        avatarBytes: checked,
      ),
      throwsA(isA<RepositoryException>()),
    );
    expect(s.profile.avatarBytes, isNull);
    s.signedIn = true;
    s.coupon = 'LEN50';
    expect(s.profile.avatarBytes, same(saved));
  });

  testWidgets(
    'Preview stays local; Back discards, failed save retains image then retry commits',
    (tester) async {
      tester.view.physicalSize = const Size(360, 1000);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final s = sample();
      final picker = FakeAvatarPicker()..next = png();
      await host(tester, s, picker);
      await choose(tester);
      expect(
        tester.widget<ProfileAvatar>(find.byType(ProfileAvatar)).bytes,
        isNotNull,
      );
      expect(s.profile.avatarBytes, isNull);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(s.profile.avatarBytes, isNull);
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      await choose(tester);
      (s.repository as MockLenlabRepository).failNext('saveProfile');
      await tester.tap(find.text('Lưu').first);
      await settleImage(tester);
      expect(s.profile.avatarBytes, isNull);
      expect(
        tester.widget<ProfileAvatar>(find.byType(ProfileAvatar)).bytes,
        isNotNull,
      );
      await tester.tap(find.text('Lưu').first);
      await settleImage(tester);
      expect(find.text('Edit'), findsOneWidget);
      expect(s.profile.avatarBytes, orderedEquals(png()));
      expect(s.orders.length, 4);
    },
  );

  testWidgets(
    'Picker cancel/error/corrupt file preserve previous preview and form; retry works',
    (tester) async {
      final s = sample();
      final picker = FakeAvatarPicker()..next = png();
      await host(tester, s, picker);
      await choose(tester);
      final initial = tester
          .widget<ProfileAvatar>(find.byType(ProfileAvatar))
          .bytes;
      picker.next = null;
      await choose(tester);
      expect(
        tester.widget<ProfileAvatar>(find.byType(ProfileAvatar)).bytes,
        same(initial),
      );
      picker.error = PlatformException(code: 'photo_access_denied');
      await choose(tester);
      expect(
        find.textContaining('Không có quyền truy cập ảnh.'),
        findsOneWidget,
      );
      picker.error = null;
      picker.next = Uint8List.fromList([1, 2, 3]);
      await choose(tester);
      expect(
        find.text('Không đọc được ảnh này. Vui lòng chọn ảnh khác.'),
        findsOneWidget,
      );
      expect(
        tester.widget<ProfileAvatar>(find.byType(ProfileAvatar)).bytes,
        same(initial),
      );
      picker.next = png();
      await choose(tester);
      expect(
        find.text('Không đọc được ảnh này. Vui lòng chọn ảnh khác.'),
        findsNothing,
      );
      expect(s.profile.avatarBytes, isNull);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Pending picker prevents duplicate selection/save; result after Back never commits',
    (tester) async {
      final s = sample();
      final picker = FakeAvatarPicker()..pending = Completer<Uint8List?>();
      await host(tester, s, picker);
      await tester.tap(find.text('Đổi ảnh đại diện'));
      await tester.pump();
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(
        tester
            .widget<TextButton>(find.widgetWithText(TextButton, 'Lưu').first)
            .onPressed,
        isNull,
      );
      await tester.tap(find.text('Đổi ảnh đại diện'));
      expect(picker.calls, 1);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      picker.pending!.complete(png());
      await settleImage(tester);
      expect(s.profile.avatarBytes, isNull);
      expect(find.text('Edit'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Recovered Android image is preview only until explicit Save', (
    tester,
  ) async {
    final s = sample();
    final picker = FakeAvatarPicker()..recovered = png();
    await host(tester, s, picker);
    expect(
      tester.widget<ProfileAvatar>(find.byType(ProfileAvatar)).bytes,
      isNotNull,
    );
    expect(s.profile.avatarBytes, isNull);
    expect(picker.calls, 0);
  });

  testWidgets('Saved memory avatar is visible on profile and Drawer', (
    tester,
  ) async {
    final s = sample()..profile.avatarBytes = png();
    await tester.pumpWidget(CustomerApp(store: s, initialRoute: '/profile'));
    await settleImage(tester);
    expect(
      tester.widget<ProfileAvatar>(find.byType(ProfileAvatar)).bytes,
      same(s.profile.avatarBytes),
    );
    tester.state<NavigatorState>(find.byType(Navigator)).pushNamed('/');
    await tester.pumpAndSettle();
    tester.state<ScaffoldState>(find.byType(Scaffold).last).openDrawer();
    await settleImage(tester);
    expect(
      tester.widget<ProfileAvatar>(find.byType(ProfileAvatar)).bytes,
      same(s.profile.avatarBytes),
    );
    expect(tester.takeException(), isNull);
  });
}
