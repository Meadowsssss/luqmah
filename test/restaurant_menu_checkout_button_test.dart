import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luqmah/app/theme/luqmah_theme.dart';
import 'package:luqmah/features/customer/cart/cart_controller.dart';
import 'package:luqmah/features/customer/data/restaurant_repository.dart';
import 'package:luqmah/features/customer/presentation/cart_page.dart';
import 'package:luqmah/features/customer/presentation/restaurant_menu_page.dart';
import 'package:luqmah/models/restaurant.dart';

void main() {
  testWidgets('checkout button is hidden when cart is empty', (tester) async {
    final container = _createContainer();
    addTearDown(container.dispose);

    await _pumpMenu(tester, container);

    expect(find.textContaining('Checkout'), findsNothing);
  });

  testWidgets('checkout button appears for this restaurant cart', (tester) async {
    final container = _createContainer();
    addTearDown(container.dispose);
    _addCartItem(container, restaurantId: 'r1');

    await _pumpMenu(tester, container);

    expect(find.text('Checkout • 2.50 JD'), findsOneWidget);
  });

  testWidgets('checkout button is hidden for another restaurant cart', (tester) async {
    final container = _createContainer();
    addTearDown(container.dispose);
    _addCartItem(container, restaurantId: 'r2');

    await _pumpMenu(tester, container);

    expect(find.textContaining('Checkout'), findsNothing);
  });

  testWidgets('checkout button opens the cart screen', (tester) async {
    final container = _createContainer();
    addTearDown(container.dispose);
    _addCartItem(container, restaurantId: 'r1');

    await _pumpMenu(tester, container);
    await tester.tap(find.text('Checkout • 2.50 JD'));
    await tester.pumpAndSettle();

    expect(find.text('Your cart'), findsWidgets);
    expect(find.text('Chicken Shawarma'), findsOneWidget);
  });
}

ProviderContainer _createContainer() {
  return ProviderContainer(
    overrides: [
      restaurantRepositoryProvider.overrideWithValue(
        const _FakeRestaurantRepository(),
      ),
    ],
  );
}

Future<void> _pumpMenu(WidgetTester tester, ProviderContainer container) async {
  final router = GoRouter(
    initialLocation: '/restaurants/r1',
    routes: [
      GoRoute(
        path: '/restaurants/:restaurantId',
        builder: (context, state) => RestaurantMenuPage(
          restaurantId: state.pathParameters['restaurantId']!,
        ),
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartPage(),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        theme: buildLuqmahTheme(),
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void _addCartItem(ProviderContainer container, {required String restaurantId}) {
  container.read(cartControllerProvider.notifier).addItem(
        const MenuItem(
          id: 'm1',
          name: 'Chicken Shawarma',
          description: 'Freshly grilled chicken wrap',
          price: 2.5,
          image: '',
          category: 'Wraps',
        ),
        restaurantId: restaurantId,
        restaurantName: restaurantId == 'r1' ? 'Campus Bites' : 'Other Cafe',
      );
}

class _FakeRestaurantRepository implements RestaurantRepository {
  const _FakeRestaurantRepository();

  @override
  Future<Restaurant?> fetchRestaurantById(String id) async {
    return Restaurant(
      id: id,
      name: id == 'r1' ? 'Campus Bites' : 'Other Cafe',
      description: 'Fresh meals',
      image: '',
      rating: 'Live',
      time: 'Campus pickup',
      tags: const ['Open now'],
      menu: const [
        MenuItem(
          id: 'm1',
          name: 'Chicken Shawarma',
          description: 'Freshly grilled chicken wrap',
          price: 2.5,
          image: '',
          category: 'Wraps',
        ),
      ],
    );
  }

  @override
  Future<List<Restaurant>> fetchRestaurants() async => const [];

  @override
  Restaurant? findRestaurantForMenuItem(String itemId) => null;

  @override
  MenuItem? getMenuItemById(String id) => null;

  @override
  Restaurant? getRestaurantById(String id) => null;
}
