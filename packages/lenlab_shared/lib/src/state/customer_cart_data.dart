import 'dart:collection';

import '../domain/models.dart';

/// RAM cart container. Account ownership is provided by the account map;
/// Guest carts are retained separately for the future explicit merge step.
class CustomerCartData {
  final lines = <CartLine>[];
  final unselectedKeys = <String>{};
  String coupon = '';
  bool promptDismissed = false;
}

/// Captures a cart and session. A retained view cannot mutate another session.
class SessionCartList extends ListBase<CartLine> {
  SessionCartList(this._items, this._read, this._write);
  final List<CartLine> _items;
  final void Function() _read, _write;
  @override
  int get length {
    _read();
    return _items.length;
  }

  @override
  set length(int value) {
    _write();
    if (value < 0 || value > _items.length) throw RangeError.value(value);
    _items.removeRange(value, _items.length);
  }

  @override
  CartLine operator [](int index) {
    _read();
    return _items[index];
  }

  @override
  void operator []=(int index, CartLine value) {
    _write();
    _items[index] = value;
  }

  @override
  void add(CartLine element) {
    _write();
    _items.add(element);
  }

  @override
  void addAll(Iterable<CartLine> iterable) {
    _write();
    _items.addAll(iterable);
  }

  @override
  void insert(int index, CartLine element) {
    _write();
    _items.insert(index, element);
  }

  @override
  CartLine removeAt(int index) {
    _write();
    return _items.removeAt(index);
  }

  @override
  void clear() {
    _write();
    _items.clear();
  }
}
