import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:luqmah/app/theme/luqmah_theme.dart';
import 'package:luqmah/features/customer/cart/cart_controller.dart';
import 'package:luqmah/features/customer/data/restaurant_repository.dart';
import 'package:luqmah/features/customer/presentation/cart_page.dart';
import 'package:luqmah/features/customer/presentation/restaurants_page.dart';
import 'package:luqmah/models/restaurant.dart';

class _FakeRestaurantRepository implements RestaurantRepository {
  const _FakeRestaurantRepository();

  @override
  Future<Restaurant?> fetchRestaurantById(String id) async => Restaurant(
    id: 'r1',
    name: 'Campus Bites',
    description: 'Fresh meals',
    image: '',
    rating: 'Live',
    time: 'Campus pickup',
    tags: const ['Open now'],
    menu: const [],
  );

  @override
  Future<List<Restaurant>> fetchRestaurants() async => const [
    Restaurant(
      id: 'r1',
      name: 'Campus Bites',
      description: 'Fresh meals',
      image: '',
      rating: 'Live',
      time: 'Campus pickup',
      tags: ['Open now'],
      menu: [],
    ),
  ];

  @override
  Restaurant? findRestaurantForMenuItem(String itemId) => null;

  @override
  MenuItem? getMenuItemById(String id) => null;

  @override
  Restaurant? getRestaurantById(String id) => null;
}

void main() {
  testWidgets('restaurants screen shows hero copy', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          restaurantRepositoryProvider.overrideWithValue(const _FakeRestaurantRepository()),
        ],
        child: MaterialApp(
          theme: buildLuqmahTheme(),
          home: const RestaurantsPage(),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Luqmah'), findsOneWidget);
    expect(find.text('Choose a restaurant'), findsOneWidget);
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

    await tester.pump();

    expect(find.text('Chicken Shawarma'), findsOneWidget);
    expect(find.text('Al-Salam Grill'), findsOneWidget);
    expect(find.text('2.50 JD'), findsWidgets);
    expect(find.text('Place order'), findsOneWidget);
  });
}
