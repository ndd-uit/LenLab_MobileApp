import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_customer/app/customer_app.dart';
import 'package:lenlab_customer/app/customer_scope.dart';
import 'package:lenlab_customer/features/help/data/faq_source.dart';
import 'package:lenlab_customer/features/help/presentation/faq_page.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

void main() {
  for (final width in [360.0, 390.0, 430.0]) {
    testWidgets(
      'FAQ $width text120 toggles answers and contact does not submit data',
      (tester) async {
        tester.view.physicalSize = Size(width, 1000);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 1.2;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final store = LenlabStore(
          repository: MockLenlabRepository(latency: Duration.zero),
        );
        await tester.pumpWidget(
          CustomerApp(store: store, initialRoute: '/faq'),
        );
        await tester.pumpAndSettle();
        expect(find.text(mockFaqItems.first.answer!), findsOneWidget);
        await tester.tap(find.text(mockFaqItems.first.question));
        await tester.pumpAndSettle();
        expect(find.text(mockFaqItems.first.answer!), findsNothing);
        await tester.tap(find.text('Hướng dẫn giặt ủi sản phẩm?'));
        await tester.pumpAndSettle();
        expect(
          find.text('Nội dung câu trả lời đang được cập nhật.'),
          findsOneWidget,
        );
        await tester.ensureVisible(find.text('Liên hệ hỗ trợ'));
        await tester.tap(find.text('Liên hệ hỗ trợ'));
        await tester.pumpAndSettle();
        expect(
          find.textContaining('chưa có yêu cầu nào được gửi'),
          findsOneWidget,
        );
        expect(store.signedIn, isFalse);
        expect(store.orders, isEmpty);
        expect(store.cartCount, 0);
        expect(store.coupon, isEmpty);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets('search, category filter and reset produce correct questions', (
    tester,
  ) async {
    final store = LenlabStore(
      repository: MockLenlabRepository(latency: Duration.zero),
    );
    await tester.pumpWidget(CustomerApp(store: store, initialRoute: '/faq'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Đơn hàng'));
    await tester.pumpAndSettle();
    expect(find.text('Chính sách đổi trả thế nào?'), findsOneWidget);
    expect(find.text('Len này có bị xù lông không?'), findsNothing);
    await tester.enterText(find.byType(TextField), 'không tồn tại');
    await tester.pumpAndSettle();
    expect(find.text('Không tìm thấy câu hỏi phù hợp'), findsOneWidget);
    await tester.tap(find.text('Xóa bộ lọc'));
    await tester.pumpAndSettle();
    expect(find.text('Len này có bị xù lông không?'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'giao hàng');
    await tester.pumpAndSettle();
    expect(find.text('Thời gian giao hàng bao lâu?'), findsOneWidget);
    expect(find.text('Len này có bị xù lông không?'), findsNothing);
  });
  testWidgets('loading and error retry keep public FAQ accessible', (
    tester,
  ) async {
    final repository = MockLenlabRepository(
      latency: const Duration(milliseconds: 200),
    )..failNext('faq');
    await tester.pumpWidget(
      CustomerApp(
        store: LenlabStore(repository: repository),
        initialRoute: '/faq',
      ),
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('Không thể tải câu hỏi'), findsOneWidget);
    await tester.tap(find.text('Thử lại'));
    await tester.pumpAndSettle();
    expect(find.text('Len này có bị xù lông không?'), findsOneWidget);
  });
  testWidgets('empty source is explicit and contact remains available', (
    tester,
  ) async {
    final store = LenlabStore();
    await tester.pumpWidget(
      CustomerScope(
        store: store,
        child: MaterialApp(
          theme: P2.theme(),
          home: FaqPage(source: EmptyFaq()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Chưa có câu hỏi thường gặp'), findsOneWidget);
    expect(find.text('Liên hệ hỗ trợ'), findsOneWidget);
  });
  testWidgets('profile help opens FAQ and back returns profile', (
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
    await tester.ensureVisible(find.text('Trung tâm trợ giúp'));
    await tester.tap(find.text('Trung tâm trợ giúp'));
    await tester.pumpAndSettle();
    expect(find.byType(FaqPage), findsOneWidget);
    await tester.tap(find.byTooltip('Quay lại').last);
    await tester.pumpAndSettle();
    expect(find.text('Hồ sơ của tôi'), findsOneWidget);
  });
  testWidgets(
    'order support carries exact order id without changing its state',
    (tester) async {
      final store =
          LenlabStore(repository: MockLenlabRepository(latency: Duration.zero))
            ..signedIn = true
            ..coupon = 'LEN50';
      await tester.pumpWidget(
        CustomerApp(store: store, initialRoute: '/orders'),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Chi tiết').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Liên hệ hỗ trợ'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<FaqPage>(find.byType(FaqPage)).orderId,
        store.orders.first.id,
      );
      await tester.ensureVisible(find.text('Liên hệ hỗ trợ'));
      await tester.tap(find.text('Liên hệ hỗ trợ'));
      await tester.pumpAndSettle();
      expect(find.textContaining('#WOOL-8823'), findsWidgets);
      expect(store.orders.first.state, OrderState.shipping);
      expect(store.orders.first.payment, PaymentState.cod);
    },
  );
}

class EmptyFaq implements FaqSource {
  @override
  Future<List<FaqItem>> load() async => [];
}
