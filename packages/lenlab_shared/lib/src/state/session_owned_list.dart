import 'dart:collection';

import '../data/lenlab_repository.dart';

/// A view bound to one account generation. Retained views cannot write through
/// into the previous account, and unknown/foreign records cannot be inserted.
class SessionOwnedList<T> extends ListBase<T> {
  SessionOwnedList(this._items, this._check, this._ownerOf, this.ownerId);
  final List<T> _items;
  final void Function() _check;
  final String? Function(T) _ownerOf;
  final String ownerId;
  void _validate(T value) {
    if (_ownerOf(value) != ownerId) {
      throw const RepositoryException(
        'Dữ liệu chưa xác định owner hoặc thuộc tài khoản khác.',
      );
    }
  }

  @override
  int get length {
    _check();
    return _items.length;
  }

  @override
  set length(int value) {
    _check();
    if (value < 0 || value > _items.length) throw RangeError.value(value);
    _items.removeRange(value, _items.length);
  }

  @override
  T operator [](int index) {
    _check();
    return _items[index];
  }

  @override
  void operator []=(int index, T value) {
    _check();
    _validate(value);
    _items[index] = value;
  }

  @override
  void add(T element) {
    _check();
    _validate(element);
    _items.add(element);
  }

  @override
  void addAll(Iterable<T> iterable) {
    _check();
    final checked = List<T>.of(iterable);
    checked.forEach(_validate);
    _items.addAll(checked);
  }

  @override
  void insert(int index, T element) {
    _check();
    _validate(element);
    _items.insert(index, element);
  }

  @override
  T removeAt(int index) {
    _check();
    return _items.removeAt(index);
  }

  @override
  void clear() {
    _check();
    _items.clear();
  }
}

class SessionOwnedSet<T> extends SetBase<T> {
  SessionOwnedSet(this._items, this._check);
  final Set<T> _items;
  final void Function() _check;
  @override
  int get length {
    _check();
    return _items.length;
  }

  @override
  Iterator<T> get iterator {
    _check();
    return _items.where((_) {
      _check();
      return true;
    }).iterator;
  }

  @override
  bool contains(Object? element) {
    _check();
    return _items.contains(element);
  }

  @override
  T? lookup(Object? element) {
    _check();
    return _items.lookup(element);
  }

  @override
  bool add(T value) {
    _check();
    return _items.add(value);
  }

  @override
  bool remove(Object? value) {
    _check();
    return _items.remove(value);
  }

  @override
  void clear() {
    _check();
    _items.clear();
  }

  @override
  Set<T> toSet() {
    _check();
    return Set<T>.of(_items);
  }
}
