import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luqmah/features/customer/cart/cart_controller.dart';
import 'package:luqmah/models/restaurant.dart';

void main() {
  const item = MenuItem(
    id: 'burger_1',
    name: 'Classic Burger',
    description: 'Grilled beef patty with cheese',
    price: 3.5,
    image: 'https://example.com/burger.jpg',
    category: 'Burgers',
  );

  test('cart stores full snapshot and quantity changes work', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(cartControllerProvider.notifier);

    notifier.addItem(
      item,
      restaurantId: 'campus_burger',
      restaurantName: 'Campus Burger',
    );
    notifier.addItem(
      item,
      restaurantId: 'campus_burger',
      restaurantName: 'Campus Burger',
    );

    final state = container.read(cartControllerProvider);
    final lines = container.read(cartLinesProvider);
    final total = container.read(cartTotalProvider);

    expect(state.itemCount, 2);
    expect(state.activeRestaurantId, 'campus_burger');
    expect(lines, hasLength(1));
    expect(lines.first.item.name, 'Classic Burger');
    expect(lines.first.item.restaurantName, 'Campus Burger');
    expect(lines.first.quantity, 2);
    expect(total, 7.0);

    notifier.removeItem(item.id);
    expect(container.read(cartControllerProvider).itemCount, 1);

    notifier.deleteItem(item.id);
    expect(container.read(cartLinesProvider), isEmpty);
  });

  test('cart lines do not depend on repository lookup', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(cartControllerProvider.notifier)
        .addItem(
          item,
          restaurantId: 'campus_burger',
          restaurantName: 'Campus Burger',
        );

    final line = container.read(cartLinesProvider).single;
    expect(line.item.itemId, item.id);
    expect(line.item.restaurantId, 'campus_burger');
    expect(line.item.description, item.description);
    expect(line.item.image, item.image);
  });

  test('cart rejects items from another restaurant until replaced', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    const secondItem = MenuItem(
      id: 'wrap_1',
      name: 'Chicken Wrap',
      description: 'Fresh wrap',
      price: 4.0,
      image: 'https://example.com/wrap.jpg',
      category: 'Wraps',
    );

    final notifier = container.read(cartControllerProvider.notifier);
    notifier.addItem(
      item,
      restaurantId: 'campus_burger',
      restaurantName: 'Campus Burger',
    );

    final accepted = notifier.addItem(
      secondItem,
      restaurantId: 'blockna_express',
      restaurantName: 'Blockna Express',
    );

    expect(accepted, isFalse);
    expect(container.read(cartControllerProvider).activeRestaurantId, 'campus_burger');
    expect(container.read(cartLinesProvider), hasLength(1));

    notifier.replaceWithItem(
      secondItem,
      restaurantId: 'blockna_express',
      restaurantName: 'Blockna Express',
    );

    expect(container.read(cartControllerProvider).activeRestaurantId, 'blockna_express');
    expect(container.read(cartLinesProvider), hasLength(1));
    expect(container.read(cartLinesProvider).single.item.name, 'Chicken Wrap');
  });
}
