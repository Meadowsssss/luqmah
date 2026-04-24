import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/restaurant.dart';

class CartItemSnapshot {
  const CartItemSnapshot({
    required this.itemId,
    required this.restaurantName,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
  });

  final String itemId;
  final String restaurantName;
  final String name;
  final String description;
  final double price;
  final String image;
}

class CartState {
  const CartState({required this.items});

  final Map<String, CartLine> items;

  int get itemCount => items.values.fold(0, (sum, line) => sum + line.quantity);
}

class CartLine {
  const CartLine({required this.item, required this.quantity});

  final CartItemSnapshot item;
  final int quantity;

  double get lineTotal => item.price * quantity;

  CartLine copyWith({CartItemSnapshot? item, int? quantity}) {
    return CartLine(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
    );
  }
}

class CartController extends Notifier<CartState> {
  @override
  CartState build() => const CartState(items: <String, CartLine>{});

  void addItem(MenuItem item, {required String restaurantName}) {
    final next = Map<String, CartLine>.from(state.items);
    final existing = next[item.id];

    if (existing != null) {
      next[item.id] = existing.copyWith(quantity: existing.quantity + 1);
    } else {
      next[item.id] = CartLine(
        item: CartItemSnapshot(
          itemId: item.id,
          restaurantName: restaurantName,
          name: item.name,
          description: item.description,
          price: item.price,
          image: item.image,
        ),
        quantity: 1,
      );
    }

    state = CartState(items: next);
  }

  void incrementItem(String itemId) {
    final next = Map<String, CartLine>.from(state.items);
    final existing = next[itemId];
    if (existing == null) {
      return;
    }

    next[itemId] = existing.copyWith(quantity: existing.quantity + 1);
    state = CartState(items: next);
  }

  void removeItem(String itemId) {
    if (!state.items.containsKey(itemId)) {
      return;
    }

    final next = Map<String, CartLine>.from(state.items);
    final existing = next[itemId];
    if (existing == null) {
      return;
    }

    final updatedQuantity = existing.quantity - 1;
    if (updatedQuantity <= 0) {
      next.remove(itemId);
    } else {
      next[itemId] = existing.copyWith(quantity: updatedQuantity);
    }
    state = CartState(items: next);
  }

  void deleteItem(String itemId) {
    final next = Map<String, CartLine>.from(state.items);
    next.remove(itemId);
    state = CartState(items: next);
  }

  void clear() {
    state = const CartState(items: <String, CartLine>{});
  }
}

final cartControllerProvider = NotifierProvider<CartController, CartState>(
  CartController.new,
);

final cartLinesProvider = Provider<List<CartLine>>((ref) {
  return ref.watch(cartControllerProvider).items.values.toList(growable: false);
});

final cartTotalProvider = Provider<double>((ref) {
  return ref.watch(cartLinesProvider).fold(0.0, (sum, line) => sum + line.lineTotal);
});
