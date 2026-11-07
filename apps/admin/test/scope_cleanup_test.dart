import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_admin/app.dart';
import 'package:lenlab_admin/app/admin_destination.dart';
import 'package:lenlab_admin/shared/layout/admin_shell.dart';

import 'support/admin_test_session.dart';

void main() {
  for (final route in [
    '/marketing',
    '/marketing/articles/new',
    '/digital-products',
    '/digital-products/edit?id=ebook',
    '/marketing/abandoned-carts',
    '/reviews/statistics',
  ]) {
    testWidgets('Removed admin deep link $route is unavailable', (
      tester,
    ) async {
      await tester.pumpWidget(
        AdminApp(session: await createSession(), initialRoute: route),
      );
      await tester.pumpAndSettle();
      expect(
        tester.widget<AdminShell>(find.byType(AdminShell)).destination,
        AdminDestination.notFound,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
