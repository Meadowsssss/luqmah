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
  const _FakeRestaurantRepository({this.isBusy = false});

  final bool isBusy;

  @override
  Future<Restaurant?> fetchRestaurantById(String id) async => Restaurant(
    id: 'r1',
    name: 'Campus Bites',
    description: 'Fresh meals',
    image: '',
    rating: 'Live',
    time: 'Campus pickup',
    isBusy: isBusy,
    tags: const ['Open now'],
    menu: const [],
  );

  @override
  Future<List<Restaurant>> fetchRestaurants() async => [
    Restaurant(
      id: 'r1',
      name: 'Campus Bites',
      description: 'Fresh meals',
      image: '',
      rating: 'Live',
      time: 'Campus pickup',
      isBusy: isBusy,
      tags: const ['Open now'],
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

  testWidgets('restaurants screen shows busy badge', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          restaurantRepositoryProvider.overrideWithValue(
            const _FakeRestaurantRepository(isBusy: true),
          ),
        ],
        child: MaterialApp(
          theme: buildLuqmahTheme(),
          home: const RestaurantsPage(),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Busy'), findsOneWidget);
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

    await tester.pump();

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

    await tester.pump();
    await tester.pump();

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
