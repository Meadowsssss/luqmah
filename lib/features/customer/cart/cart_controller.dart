import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/restaurant.dart';

class CartItemSnapshot {
  const CartItemSnapshot({
    required this.lineId,
    required this.itemId,
    required this.restaurantId,
    required this.restaurantName,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    this.selectedOptions = const [],
  });

  final String lineId;
  final String itemId;
  final String restaurantId;
  final String restaurantName;
  final String name;
  final String description;
  final double price;
  final String image;
  final List<CartItemOptionSnapshot> selectedOptions;
}

class CartItemOptionSnapshot {
  const CartItemOptionSnapshot({
    required this.id,
    required this.groupTitle,
    required this.title,
    required this.priceDelta,
  });

  final String id;
  final String groupTitle;
  final String title;
  final double priceDelta;
}

class CartState {
  const CartState({required this.items});

  final Map<String, CartLine> items;

  int get itemCount => items.values.fold(0, (sum, line) => sum + line.quantity);

  String? get activeRestaurantId =>
      items.isEmpty ? null : items.values.first.item.restaurantId;

  String? get activeRestaurantName =>
      items.isEmpty ? null : items.values.first.item.restaurantName;

  bool canAddRestaurant(String restaurantId) {
    return activeRestaurantId == null || activeRestaurantId == restaurantId;
  }
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

  bool addItem(
    MenuItem item, {
    required String restaurantId,
    required String restaurantName,
    List<CartItemOptionSnapshot> selectedOptions = const [],
  }) {
    if (!state.canAddRestaurant(restaurantId)) {
      return false;
    }

    final next = Map<String, CartLine>.from(state.items);
    final lineId = _lineIdFor(item.id, selectedOptions);
    final existing = next[lineId];
    final unitPrice = item.price + selectedOptions.fold(0.0, (sum, option) => sum + option.priceDelta);

    if (existing != null) {
      next[lineId] = existing.copyWith(quantity: existing.quantity + 1);
    } else {
      next[lineId] = CartLine(
        item: CartItemSnapshot(
          lineId: lineId,
          itemId: item.id,
          restaurantId: restaurantId,
          restaurantName: restaurantName,
          name: item.name,
          description: item.description,
          price: unitPrice,
          image: item.image,
          selectedOptions: selectedOptions,
        ),
        quantity: 1,
      );
    }

    state = CartState(items: next);
    return true;
  }

  void replaceWithItem(
    MenuItem item, {
    required String restaurantId,
    required String restaurantName,
    List<CartItemOptionSnapshot> selectedOptions = const [],
  }) {
    state = const CartState(items: <String, CartLine>{});
    addItem(
      item,
      restaurantId: restaurantId,
      restaurantName: restaurantName,
      selectedOptions: selectedOptions,
    );
  }

  void incrementItem(String lineId) {
    final next = Map<String, CartLine>.from(state.items);
    final existing = next[lineId];
    if (existing == null) {
      return;
    }

    next[lineId] = existing.copyWith(quantity: existing.quantity + 1);
    state = CartState(items: next);
  }

  void removeItem(String lineId) {
    if (!state.items.containsKey(lineId)) {
      return;
    }

    final next = Map<String, CartLine>.from(state.items);
    final existing = next[lineId];
    if (existing == null) {
      return;
    }

    final updatedQuantity = existing.quantity - 1;
    if (updatedQuantity <= 0) {
      next.remove(lineId);
    } else {
      next[lineId] = existing.copyWith(quantity: updatedQuantity);
    }
    state = CartState(items: next);
  }

  void deleteItem(String lineId) {
    final next = Map<String, CartLine>.from(state.items);
    next.remove(lineId);
    state = CartState(items: next);
  }

  void clear() {
    state = const CartState(items: <String, CartLine>{});
  }

  int quantityForMenuItem(String itemId) {
    return state.items.values
        .where((line) => line.item.itemId == itemId)
        .fold(0, (sum, line) => sum + line.quantity);
  }

  String _lineIdFor(String itemId, List<CartItemOptionSnapshot> selectedOptions) {
    if (selectedOptions.isEmpty) {
      return itemId;
    }

    final sortedOptionIds = selectedOptions.map((option) => option.id).toList(growable: false)..sort();
    return '$itemId::${sortedOptionIds.join('|')}';
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
