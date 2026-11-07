import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_customer/app/customer_app.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

void main() {
  testWidgets('purchase-flow buttons preserve their individual P2 colors', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 929);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      CustomerApp(
        initialRoute: '/products',
        store: LenlabStore(
          repository: MockLenlabRepository(latency: Duration.zero),
        )..signedIn = true,
      ),
    );
    await tester.pumpAndSettle();
    final cardButton = tester.widget<IconButton>(
      find.byWidgetPredicate(
        (w) =>
            w is IconButton &&
            w.tooltip == 'Chọn biến thể Thú Bông Cừu Handmade Size L',
      ),
    );
    final cardBrown = cardButton.style!.backgroundColor!.resolve({});
    expect(cardBrown, const Color(0xFF383029));
    Color? primary(String label) => tester
        .widget<ElevatedButton>(find.widgetWithText(ElevatedButton, label))
        .style!
        .backgroundColor!
        .resolve({});
    await tester.ensureVisible(find.text('Thú Bông Cừu Handmade Size L'));
    await tester.tap(find.text('Thú Bông Cừu Handmade Size L'));
    await tester.pumpAndSettle();
    expect(primary('Thêm vào giỏ'), const Color(0xFFF09942));
    await tester.tap(find.byTooltip('Giỏ hàng'));
    await tester.pumpAndSettle();
    expect(primary('Thanh toán'), const Color(0xFFE9A663));
    await tester.tap(find.text('Thanh toán'));
    await tester.pumpAndSettle();
    expect(primary('Xem lại đơn hàng'), const Color(0xFFE9A663));
    expect(tester.takeException(), isNull);
  });
}
