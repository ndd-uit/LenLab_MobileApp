import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

class WaitingCod implements CodOrderSource {
  final started = Completer<CodOrderDraft>();
  final result = Completer<Order>();
  @override
  Future<Order> submit(CodOrderDraft draft) {
    started.complete(draft);
    return result.future;
  }

  Future<Order> finish() async {
    final d = await started.future;
    final order = Order(
      ownerId: d.ownerId,
      id: d.id,
      lines: d.lines,
      address: d.address,
      note: d.note,
      discount: d.discount,
      shipping: d.shipping,
    );
    result.complete(order);
    return order;
  }
}

void main() {
  Future<void> login(LenlabStore s, CustomerIdentity user) async {
    await s.signIn(identity: user.email, password: 'mock');
  }

  for (final returnBeforeCompletion in [false, true]) {
    test(
      'detached COD restores once to A; A returns ${returnBeforeCompletion ? 'before' : 'after'} completion',
      () async {
        final s = LenlabStore(
          repository: MockLenlabRepository(latency: Duration.zero),
        );
        addTearDown(s.dispose);
        await login(s, mockCustomerA);
        final cart = List.of(s.cart);
        s.deliveryAddress = s.addresses.single;
        s.checkoutNote = 'A snapshot note';
        final source = WaitingCod();
        final pending = s.submitCodOrder(
          totals: OrderReviewTotals(
            subtotal: s.checkoutSubtotal,
            discount: s.checkoutDiscount,
            shipping: 30000,
          ),
          source: source,
        );
        final draft = await source.started.future;
        s.logout();
        await login(s, mockCustomerB);
        expect(s.orders, isEmpty);
        expect(s.deliveryAddress, isNull);
        expect(s.checkoutNote, isEmpty);
        if (returnBeforeCompletion) await login(s, mockCustomerA);
        final order = await source.finish();
        expect(await pending, same(order));
        expect(order.ownerId, mockCustomerA.id);
        expect(order.note, 'A snapshot note');
        expect(
          s.cart,
          returnBeforeCompletion ? orderedEquals(cart) : isEmpty,
        ); // Cart reconciliation belongs to batch 4.
        if (!returnBeforeCompletion) {
          expect(s.orders, isEmpty);
          await login(s, mockCustomerA);
        }
        expect(s.orders.where((o) => o.id == draft.id), [order]);
        expect(s.orders.length, 5);
        s.logout();
        await login(s, mockCustomerA);
        expect(s.orders.where((o) => o.id == draft.id), [order]);
        expect(s.checkoutNote, isEmpty);
        expect(s.deliveryAddress, isNull);
        await login(s, mockCustomerB);
        expect(s.findOwnedOrder(draft.id), isNull);
      },
    );
  }
}
