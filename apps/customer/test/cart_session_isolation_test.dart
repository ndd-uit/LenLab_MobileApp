import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_customer/app/customer_app.dart';
import 'package:lenlab_customer/features/cart/presentation/widgets/cart_item_card.dart';
import 'package:lenlab_customer/features/cart/presentation/widgets/guest_cart_prompt.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

void main() {
  testWidgets('open cart switches A B A without leaking items or selection', (
    t,
  ) async {
    final repo = MockLenlabRepository(latency: Duration.zero);
    final s = LenlabStore(repository: repo)..signedIn = true;
    addTearDown(s.dispose);
    s.coupon = 'LEN50';
    s.toggleCartLine(s.cart.first);
    await t.pumpWidget(CustomerApp(store: s, initialRoute: '/cart'));
    await t.pumpAndSettle();
    expect(find.byType(CartItemCard), findsNWidgets(2));
    await t.runAsync(
      () => s.signIn(identity: mockCustomerB.email, password: 'mock'),
    );
    await t.pumpAndSettle();
    expect(find.byType(CartItemCard), findsNothing);
    expect(find.text('Giỏ hàng đang trống'), findsOneWidget);
    expect(find.textContaining('LEN50'), findsNothing);
    s.addToCart(repo.catalog.firstWhere((p) => p.id == 'sheep'), 1, 'B');
    await t.pumpAndSettle();
    expect(find.byType(CartItemCard), findsOneWidget);
    await t.runAsync(
      () => s.signIn(identity: mockCustomerA.email, password: 'mock'),
    );
    await t.pumpAndSettle();
    expect(find.byType(CartItemCard), findsNWidgets(2));
    expect(s.isCartLineSelected(s.cart.first), isFalse);
    expect(s.coupon, 'LEN50');
    expect(t.takeException(), isNull);
  });

  testWidgets(
    'Guest prompt once per Guest session; logout creates empty Guest',
    (t) async {
      final s = LenlabStore(
        repository: MockLenlabRepository(latency: Duration.zero),
      );
      addTearDown(s.dispose);
      await t.pumpWidget(CustomerApp(store: s, initialRoute: '/cart'));
      await t.pumpAndSettle();
      expect(find.byType(GuestCartPrompt), findsOneWidget);
      await t.tap(find.text('Để sau'));
      await t.pumpAndSettle();
      final nav = t.state<NavigatorState>(find.byType(Navigator));
      nav.pushNamed('/cart');
      await t.pumpAndSettle();
      expect(find.byType(GuestCartPrompt), findsNothing);
      await t.runAsync(
        () => s.signIn(identity: mockCustomerA.email, password: 'mock'),
      );
      await t.pumpAndSettle();
      s.logout();
      await t.pumpAndSettle();
      expect(find.byType(GuestCartPrompt).hitTestable(), findsOneWidget);
      await t.tap(find.text('Để sau').hitTestable());
      await t.pumpAndSettle();
      expect(find.byType(CartItemCard), findsNothing);
      expect(s.cart, isEmpty);
      expect(t.takeException(), isNull);
    },
  );
}
