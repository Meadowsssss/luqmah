import 'package:flutter/foundation.dart';
import '../models/restaurant.dart';

class CartService {
  // MenuItem -> quantity
  static final Map<MenuItem, int> _items = {};
  static final ValueNotifier<int> itemCount = ValueNotifier<int>(0);

  static Map<MenuItem, int> get items => Map.unmodifiable(_items);

  static void _recalculateCount() {
    int total = 0;
    for (final qty in _items.values) {
      total += qty;
    }
    itemCount.value = total;
  }

  static void addItem(MenuItem item) {
    _items.update(item, (q) => q + 1, ifAbsent: () => 1);
    _recalculateCount();
  }

  static void removeItem(MenuItem item) {
    if (!_items.containsKey(item)) return;
    final newQty = _items[item]! - 1;
    if (newQty <= 0) {
      _items.remove(item);
    } else {
      _items[item] = newQty;
    }
    _recalculateCount();
  }

  static void deleteItem(MenuItem item) {
    if (_items.containsKey(item)) {
      _items.remove(item);
      _recalculateCount();
    }
  }

  static double totalPrice() {
    double sum = 0;
    _items.forEach((item, qty) {
      sum += item.price * qty;
    });
    return sum;
  }

  static void clear() {
    _items.clear();
    _recalculateCount();
  }
}
