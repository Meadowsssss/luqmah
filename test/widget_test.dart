import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:luqmah/app/theme/luqmah_theme.dart';
import 'package:luqmah/features/customer/data/restaurant_repository.dart';
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
}
