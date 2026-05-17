import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luqmah/app/theme/luqmah_theme.dart';
import 'package:luqmah/features/vendor/presentation/vendor_insights_page.dart';
import 'package:luqmah/features/vendor/vendor_data_controller.dart';
import 'package:luqmah/models/vendor.dart';

class _FakeVendorInsightsController extends VendorDataController {
  @override
  Future<VendorDataState> build() async {
    return VendorDataState(
      restaurants: const [
        VendorRestaurant(id: 'rest-1', title: 'Planet Donuts', categories: []),
        VendorRestaurant(id: 'rest-2', title: 'Campus Coffee', categories: []),
      ],
      menuItems: const [],
      orders: [
        VendorOrder(
          id: 'ord-1',
          restaurantId: 'rest-1',
          restaurantTitle: 'Planet Donuts',
          customerName: 'A',
          customerEmail: 'a@example.com',
          customerPhone: '1',
          dateTime: DateTime.now().subtract(const Duration(days: 2)).copyWith(hour: 13, minute: 10),
          paymentMethod: 'Luqmah',
          status: VendorOrderStatus.completed,
          items: const [VendorOrderItem(name: 'Glazed Donut', quantity: 2, price: 1)],
          subtotal: 2,
          coupon: 0,
          total: 2,
        ),
        VendorOrder(
          id: 'ord-2',
          restaurantId: 'rest-1',
          restaurantTitle: 'Planet Donuts',
          customerName: 'B',
          customerEmail: 'b@example.com',
          customerPhone: '2',
          dateTime: DateTime.now().subtract(const Duration(days: 1)).copyWith(hour: 13, minute: 20),
          paymentMethod: 'Luqmah',
          status: VendorOrderStatus.ready,
          items: const [VendorOrderItem(name: 'Iced Latte', quantity: 1, price: 2)],
          subtotal: 2,
          coupon: 0,
          total: 2,
        ),
        VendorOrder(
          id: 'ord-3',
          restaurantId: 'rest-1',
          restaurantTitle: 'Planet Donuts',
          customerName: 'C',
          customerEmail: 'c@example.com',
          customerPhone: '3',
          dateTime: DateTime.now().subtract(const Duration(days: 3)).copyWith(hour: 13, minute: 40),
          paymentMethod: 'Luqmah',
          status: VendorOrderStatus.completed,
          items: const [VendorOrderItem(name: 'Glazed Donut', quantity: 1, price: 1)],
          subtotal: 1,
          coupon: 0,
          total: 1,
        ),
        VendorOrder(
          id: 'ord-4',
          restaurantId: 'rest-1',
          restaurantTitle: 'Planet Donuts',
          customerName: 'D',
          customerEmail: 'd@example.com',
          customerPhone: '4',
          dateTime: DateTime.now().subtract(const Duration(days: 4)).copyWith(hour: 13, minute: 50),
          paymentMethod: 'Luqmah',
          status: VendorOrderStatus.completed,
          items: const [VendorOrderItem(name: 'Glazed Donut', quantity: 1, price: 1)],
          subtotal: 1,
          coupon: 0,
          total: 1,
        ),
        VendorOrder(
          id: 'ord-5',
          restaurantId: 'rest-1',
          restaurantTitle: 'Planet Donuts',
          customerName: 'E',
          customerEmail: 'e@example.com',
          customerPhone: '5',
          dateTime: DateTime.now().subtract(const Duration(days: 5)).copyWith(hour: 12, minute: 0),
          paymentMethod: 'Luqmah',
          status: VendorOrderStatus.completed,
          items: const [VendorOrderItem(name: 'Iced Latte', quantity: 1, price: 2)],
          subtotal: 2,
          coupon: 0,
          total: 2,
        ),
      ],
    );
  }
}

void main() {
  testWidgets('vendor insights page renders per-restaurant recommendation cards', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vendorDataControllerProvider.overrideWith(_FakeVendorInsightsController.new),
        ],
        child: MaterialApp(
          theme: buildLuqmahTheme(),
          home: const VendorInsightsPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Restaurant recommendations'), findsOneWidget);
    expect(find.text('Planet Donuts'), findsOneWidget);
    expect(find.textContaining('Expected rush:'), findsOneWidget);
    expect(find.text('Campus Coffee'), findsOneWidget);
    expect(find.textContaining('Not enough recent order history yet'), findsOneWidget);
  });
}
