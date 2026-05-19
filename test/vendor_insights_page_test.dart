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
          customerId: 'cust-1',
          customerName: 'A',
          customerEmail: 'a@example.com',
          customerPhone: '1',
          dateTime: DateTime.now()
              .subtract(const Duration(days: 2))
              .copyWith(hour: 13, minute: 10),
          inProgressStartedAt: DateTime.now()
              .subtract(const Duration(days: 2))
              .copyWith(hour: 12, minute: 55),
          readyAt: DateTime.now()
              .subtract(const Duration(days: 2))
              .copyWith(hour: 13, minute: 8),
          paymentMethod: 'Luqmah',
          status: VendorOrderStatus.completed,
          items: const [
            VendorOrderItem(name: 'Glazed Donut', quantity: 2, price: 1),
          ],
          subtotal: 2,
          coupon: 0,
          total: 2,
        ),
        VendorOrder(
          id: 'ord-2',
          restaurantId: 'rest-1',
          restaurantTitle: 'Planet Donuts',
          customerId: 'cust-2',
          customerName: 'B',
          customerEmail: 'b@example.com',
          customerPhone: '2',
          dateTime: DateTime.now()
              .subtract(const Duration(days: 1))
              .copyWith(hour: 13, minute: 20),
          inProgressStartedAt: DateTime.now()
              .subtract(const Duration(days: 1))
              .copyWith(hour: 13, minute: 2),
          readyAt: DateTime.now()
              .subtract(const Duration(days: 1))
              .copyWith(hour: 13, minute: 18),
          paymentMethod: 'Luqmah',
          status: VendorOrderStatus.ready,
          items: const [
            VendorOrderItem(name: 'Iced Latte', quantity: 1, price: 2),
          ],
          subtotal: 2,
          coupon: 0,
          total: 2,
        ),
        VendorOrder(
          id: 'ord-3',
          restaurantId: 'rest-1',
          restaurantTitle: 'Planet Donuts',
          customerId: 'cust-3',
          customerName: 'C',
          customerEmail: 'c@example.com',
          customerPhone: '3',
          dateTime: DateTime.now()
              .subtract(const Duration(days: 3))
              .copyWith(hour: 13, minute: 40),
          inProgressStartedAt: DateTime.now()
              .subtract(const Duration(days: 3))
              .copyWith(hour: 13, minute: 24),
          readyAt: DateTime.now()
              .subtract(const Duration(days: 3))
              .copyWith(hour: 13, minute: 36),
          paymentMethod: 'Luqmah',
          status: VendorOrderStatus.completed,
          items: const [
            VendorOrderItem(name: 'Glazed Donut', quantity: 1, price: 1),
          ],
          subtotal: 1,
          coupon: 0,
          total: 1,
        ),
        VendorOrder(
          id: 'ord-4',
          restaurantId: 'rest-1',
          restaurantTitle: 'Planet Donuts',
          customerId: 'cust-4',
          customerName: 'D',
          customerEmail: 'd@example.com',
          customerPhone: '4',
          dateTime: DateTime.now()
              .subtract(const Duration(days: 4))
              .copyWith(hour: 13, minute: 50),
          inProgressStartedAt: DateTime.now()
              .subtract(const Duration(days: 4))
              .copyWith(hour: 13, minute: 33),
          readyAt: DateTime.now()
              .subtract(const Duration(days: 4))
              .copyWith(hour: 13, minute: 48),
          paymentMethod: 'Luqmah',
          status: VendorOrderStatus.completed,
          items: const [
            VendorOrderItem(name: 'Glazed Donut', quantity: 1, price: 1),
          ],
          subtotal: 1,
          coupon: 0,
          total: 1,
        ),
        VendorOrder(
          id: 'ord-5',
          restaurantId: 'rest-1',
          restaurantTitle: 'Planet Donuts',
          customerId: 'cust-5',
          customerName: 'E',
          customerEmail: 'e@example.com',
          customerPhone: '5',
          dateTime: DateTime.now()
              .subtract(const Duration(days: 5))
              .copyWith(hour: 12, minute: 0),
          inProgressStartedAt: DateTime.now()
              .subtract(const Duration(days: 5))
              .copyWith(hour: 11, minute: 47),
          readyAt: DateTime.now()
              .subtract(const Duration(days: 5))
              .copyWith(hour: 11, minute: 59),
          paymentMethod: 'Luqmah',
          status: VendorOrderStatus.completed,
          items: const [
            VendorOrderItem(name: 'Iced Latte', quantity: 1, price: 2),
          ],
          subtotal: 2,
          coupon: 0,
          total: 2,
        ),
      ],
    );
  }
}

void main() {
  testWidgets(
    'vendor insights page renders per-restaurant analytics cards',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            vendorDataControllerProvider.overrideWith(
              _FakeVendorInsightsController.new,
            ),
          ],
          child: MaterialApp(
            theme: buildLuqmahTheme(),
            home: const VendorInsightsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView).first, const Offset(0, -800));
      await tester.pumpAndSettle();

      expect(find.text('Recommendations'), findsOneWidget);
      expect(find.textContaining('Rush expected at'), findsOneWidget);
      expect(find.text('Restaurant analytics'), findsOneWidget);
      expect(find.text('Planet Donuts'), findsWidgets);
      expect(find.text('Busiest hour'), findsOneWidget);
      expect(find.text('Campus Coffee'), findsOneWidget);
      expect(
        find.textContaining('Not enough recent order history yet'),
        findsOneWidget,
      );
    },
  );
}
