import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_customer/app/customer_app.dart';
import 'package:lenlab_customer/shared/layout/pending_page.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

void main() {
  for (final route in [
    '/blog',
    '/article',
    '/digital',
    '/library',
    '/digital-checkout',
  ]) {
    testWidgets('Removed route $route cannot open a purchase flow', (
      tester,
    ) async {
      final store = LenlabStore(
        repository: MockLenlabRepository(latency: Duration.zero),
      );
      await tester.pumpWidget(CustomerApp(store: store));
      await tester.pumpAndSettle();
      tester
          .state<NavigatorState>(find.byType(Navigator).first)
          .pushNamed(route);
      await tester.pumpAndSettle();
      expect(find.byType(PendingPage), findsOneWidget);
      expect(store.orders, isEmpty);
      expect(store.cartCount, 0);
      expect(tester.takeException(), isNull);
    });
  }
}
