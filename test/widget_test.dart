import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:luqmah/app/theme/luqmah_theme.dart';
import 'package:luqmah/features/customer/cart/cart_controller.dart';
import 'package:luqmah/features/customer/data/restaurant_repository.dart';
import 'package:luqmah/features/customer/orders/customer_orders_controller.dart';
import 'package:luqmah/features/customer/presentation/cart_page.dart';
import 'package:luqmah/features/customer/presentation/restaurants_page.dart';
import 'package:luqmah/models/customer_order.dart';
import 'package:luqmah/models/restaurant.dart';
import 'package:luqmah/models/vendor.dart';

class _FakeRestaurantRepository implements RestaurantRepository {
  const _FakeRestaurantRepository({this.isBusy = false});

  final bool isBusy;

  @override
  Future<Restaurant?> fetchRestaurantById(String id) async => Restaurant(
    id: 'r1',
    name: 'Campus Bites',
    description: 'Fresh meals',
    image: '',
    rating: 'Live',
    estimatedPrepMinutes: 14,
    time: 'Campus pickup',
    isBusy: isBusy,
    tags: const ['Donuts', 'Coffee', 'Pastries'],
    menu: const [
      MenuItem(
        id: 'm1',
        name: 'Iced Americano',
        description: 'Cold coffee',
        price: 1.5,
        image: '',
        category: 'Iced Coffee',
      ),
      MenuItem(
        id: 'm2',
        name: 'Iced Mocha',
        description: 'Chocolate coffee',
        price: 2.0,
        image: '',
        category: 'Iced Coffee',
      ),
      MenuItem(
        id: 'm3',
        name: 'Cheesecake',
        description: 'Dessert',
        price: 2.5,
        image: '',
        category: 'Desserts',
      ),
    ],
  );

  @override
  Future<List<Restaurant>> fetchRestaurants() async => [
    Restaurant(
      id: 'r1',
      name: 'Campus Bites',
      description: 'Fresh meals',
      image: '',
      rating: 'Live',
      estimatedPrepMinutes: 14,
      time: 'Campus pickup',
      isBusy: isBusy,
      tags: const ['Donuts', 'Coffee', 'Pastries'],
      menu: const [],
    ),
  ];

  @override
  Restaurant? findRestaurantForMenuItem(String itemId) => null;

  @override
  MenuItem? getMenuItemById(String id) => null;

  @override
  Restaurant? getRestaurantById(String id) => null;
}

class _FakeCustomerOrdersController extends CustomerOrdersController {
  _FakeCustomerOrdersController(this._orders);

  final List<CustomerOrder> _orders;

  @override
  Future<List<CustomerOrder>> build() async => _orders;
}

Future<ProviderContainer> _createHomeContainer({
  bool isBusy = false,
  List<CustomerOrder> orders = const [],
}) async {
  final container = ProviderContainer(
    overrides: [
      restaurantRepositoryProvider.overrideWithValue(
        _FakeRestaurantRepository(isBusy: isBusy),
      ),
      customerOrdersControllerProvider.overrideWith(
        () => _FakeCustomerOrdersController(orders),
      ),
    ],
  );
  await container.read(restaurantsProvider.future);
  await container.read(customerOrdersControllerProvider.future);
  return container;
}

void main() {
  testWidgets('restaurants screen shows hero copy', (WidgetTester tester) async {
    final container = await _createHomeContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildLuqmahTheme(),
          home: const RestaurantsPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Good food. Great mood. On campus.'), findsOneWidget);
  });

  testWidgets('restaurants screen swaps hero for active order card', (tester) async {
    final container = await _createHomeContainer(
      orders: [
        CustomerOrder(
          id: 'ord_1',
          restaurantName: 'Planet Donuts',
          placedAt: DateTime.parse('2026-05-17T17:46:00.000Z'),
          estimatedReadyAt: DateTime.parse('2026-05-17T18:00:00.000Z'),
          status: VendorOrderStatus.inProgress,
          items: const [
            CustomerOrderItem(
              itemId: 'item_1',
              name: 'Chocolate Bar',
              quantity: 1,
              price: 1,
            ),
          ],
          total: 1,
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildLuqmahTheme(),
          home: const RestaurantsPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Good food. Great mood. On campus.'), findsNothing);
    expect(find.text('Planet Donuts'), findsOneWidget);
    expect(find.text('Preparing'), findsOneWidget);
    expect(find.textContaining('Expected by'), findsOneWidget);
  });

  testWidgets('restaurants card shows compact meta and first two categories plus more', (
    WidgetTester tester,
  ) async {
    final container = await _createHomeContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildLuqmahTheme(),
          home: const RestaurantsPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Campus Bites'), findsOneWidget);
    expect(find.text('Campus pickup'), findsOneWidget);
    expect(find.text('14-24 min'), findsOneWidget);
    expect(find.text('Donuts'), findsOneWidget);
    expect(find.text('Coffee'), findsOneWidget);
    expect(find.text('+ more'), findsOneWidget);
  });

  testWidgets('restaurants screen keeps hero for completed orders', (tester) async {
    final container = await _createHomeContainer(
      orders: [
        CustomerOrder(
          id: 'ord_1',
          restaurantName: 'Planet Donuts',
          placedAt: DateTime.parse('2026-05-17T17:46:00.000Z'),
          status: VendorOrderStatus.completed,
          items: const [],
          total: 2,
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildLuqmahTheme(),
          home: const RestaurantsPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Good food. Great mood. On campus.'), findsOneWidget);
    expect(find.text('Planet Donuts'), findsNothing);
  });

  test('fake restaurant repository returns busy state for restaurant cards', () async {
    const repository = _FakeRestaurantRepository(isBusy: true);
    final restaurants = await repository.fetchRestaurants();

    expect(restaurants.single.isBusy, isTrue);
  });

  test('fake restaurant repository returns estimated prep minutes for restaurant cards', () async {
    const repository = _FakeRestaurantRepository();
    final restaurants = await repository.fetchRestaurants();

    expect(restaurants.single.estimatedPrepMinutes, 14);
  });

  testWidgets('cart page renders non-empty cart content', (
    WidgetTester tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        restaurantRepositoryProvider.overrideWithValue(const _FakeRestaurantRepository()),
      ],
    );
    addTearDown(container.dispose);

    container.read(cartControllerProvider.notifier).addItem(
          const MenuItem(
            id: 'm1',
            name: 'Chicken Shawarma',
            description: 'Freshly grilled chicken wrap',
            price: 2.5,
            image: '',
            category: 'Wraps',
          ),
          restaurantId: 'al_salam_grill',
          restaurantName: 'Al-Salam Grill',
        );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildLuqmahTheme(),
          home: const CartPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Chicken Shawarma'), findsOneWidget);
    expect(find.text('Al-Salam Grill'), findsOneWidget);
    expect(find.text('2.50 JD'), findsWidgets);
    expect(find.text('Place order'), findsOneWidget);
  });

  testWidgets('cart page blocks checkout for busy restaurants', (WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [
        restaurantRepositoryProvider.overrideWithValue(const _FakeRestaurantRepository(isBusy: true)),
      ],
    );
    addTearDown(container.dispose);

    container.read(cartControllerProvider.notifier).addItem(
          const MenuItem(
            id: 'm1',
            name: 'Chicken Shawarma',
            description: 'Freshly grilled chicken wrap',
            price: 2.5,
            image: '',
            category: 'Wraps',
          ),
          restaurantId: 'r1',
          restaurantName: 'Campus Bites',
        );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildLuqmahTheme(),
          home: const CartPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Place order'));
    await tester.pump();

    expect(
      find.text(
        'This restaurant is busy right now. You can browse the menu, but ordering is temporarily unavailable.',
      ),
      findsOneWidget,
    );
  });
}
