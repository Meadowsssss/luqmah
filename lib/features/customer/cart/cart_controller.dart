import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/restaurant.dart';
import '../data/restaurant_repository.dart';

class CartState {
  const CartState({required this.quantities});

  final Map<String, int> quantities;

  int get itemCount => quantities.values.fold(0, (sum, qty) => sum + qty);
}

class CartLine {
  const CartLine({required this.item, required this.quantity});

  final MenuItem item;
  final int quantity;

  double get lineTotal => item.price * quantity;
}

class CartController extends Notifier<CartState> {
  @override
  CartState build() => const CartState(quantities: <String, int>{});

  void addItem(MenuItem item) {
    final next = Map<String, int>.from(state.quantities);
    next.update(item.id, (qty) => qty + 1, ifAbsent: () => 1);
    state = CartState(quantities: next);
  }

  void removeItem(String itemId) {
    if (!state.quantities.containsKey(itemId)) {
      return;
    }

    final next = Map<String, int>.from(state.quantities);
    final updated = (next[itemId] ?? 0) - 1;
    if (updated <= 0) {
      next.remove(itemId);
    } else {
      next[itemId] = updated;
    }
    state = CartState(quantities: next);
  }

  void deleteItem(String itemId) {
    final next = Map<String, int>.from(state.quantities);
    next.remove(itemId);
    state = CartState(quantities: next);
  }

  void clear() {
    state = const CartState(quantities: <String, int>{});
  }
}

final cartControllerProvider = NotifierProvider<CartController, CartState>(
  CartController.new,
);

final cartLinesProvider = Provider<List<CartLine>>((ref) {
  final cart = ref.watch(cartControllerProvider);
  final repository = ref.watch(restaurantRepositoryProvider);
  final lines = <CartLine>[];

  for (final entry in cart.quantities.entries) {
    final item = repository.getMenuItemById(entry.key);
    if (item != null) {
      lines.add(CartLine(item: item, quantity: entry.value));
    }
  }

  return lines;
});

final cartTotalProvider = Provider<double>((ref) {
  return ref.watch(cartLinesProvider).fold(0.0, (sum, line) => sum + line.lineTotal);
});
