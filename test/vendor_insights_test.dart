import 'package:flutter_test/flutter_test.dart';
import 'package:luqmah/features/vendor/vendor_data_controller.dart';
import 'package:luqmah/models/vendor.dart';

void main() {
  test('vendor insights summarizes orders and top items', () {
    final insights = summarizeVendorInsights(
      [
        VendorOrder(
          id: 'ord-1',
          restaurantId: 'rest-1',
          restaurantTitle: 'Planet Donuts',
          customerId: 'cust-1',
          customerName: 'Customer A',
          customerEmail: 'a@example.com',
          customerPhone: '0790000001',
          dateTime: DateTime(2026, 4, 23, 12),
          inProgressStartedAt: DateTime(2026, 4, 23, 11, 50),
          readyAt: DateTime(2026, 4, 23, 12, 5),
          paymentMethod: 'Luqmah',
          status: VendorOrderStatus.completed,
          items: const [
            VendorOrderItem(name: 'Wrap', quantity: 2, price: 4),
            VendorOrderItem(name: 'Drink', quantity: 1, price: 2),
          ],
          subtotal: 10,
          coupon: 0,
          total: 10,
        ),
        VendorOrder(
          id: 'ord-2',
          restaurantId: 'rest-1',
          restaurantTitle: 'Planet Donuts',
          customerId: 'cust-2',
          customerName: 'Customer B',
          customerEmail: 'b@example.com',
          customerPhone: '0790000002',
          dateTime: DateTime(2026, 4, 23, 13),
          paymentMethod: 'Luqmah',
          status: VendorOrderStatus.accepted,
          items: const [VendorOrderItem(name: 'Wrap', quantity: 1, price: 4)],
          subtotal: 4,
          coupon: 0,
          total: 4,
        ),
      ],
      const [
        VendorRestaurant(id: 'rest-1', title: 'Planet Donuts', categories: []),
      ],
    );

    expect(insights.activeOrders, greaterThan(0));
      expect(insights.totalRevenue, greaterThan(0));
      expect(insights.averageOrderValue, greaterThan(0));
      expect(insights.topItems, isNotEmpty);
      expect(insights.topItems.first.quantity, greaterThanOrEqualTo(1));
      expect(insights.averagePrepMinutes, 15);
    });

  test('vendor insights computes per-restaurant analytics for last 30 days only', () {
      final now = DateTime.now();
      final insights = summarizeVendorInsights(
        [
          VendorOrder(
            id: 'recent-1',
            restaurantId: 'rest-1',
            restaurantTitle: 'Planet Donuts',
            customerId: 'cust-a',
            customerName: 'A',
            customerEmail: 'a@example.com',
            customerPhone: '1',
            dateTime: DateTime(now.year, now.month, now.day, 13, 5),
            inProgressStartedAt: DateTime(now.year, now.month, now.day, 12, 50),
            readyAt: DateTime(now.year, now.month, now.day, 13, 4),
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
            id: 'recent-2',
            restaurantId: 'rest-1',
            restaurantTitle: 'Planet Donuts',
            customerId: 'cust-b',
            customerName: 'B',
            customerEmail: 'b@example.com',
            customerPhone: '2',
            dateTime: DateTime(now.year, now.month, now.day, 13, 20),
            inProgressStartedAt: DateTime(now.year, now.month, now.day, 13, 0),
            readyAt: DateTime(now.year, now.month, now.day, 13, 18),
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
            id: 'recent-3',
            restaurantId: 'rest-1',
            restaurantTitle: 'Planet Donuts',
            customerId: 'cust-c',
            customerName: 'C',
            customerEmail: 'c@example.com',
            customerPhone: '3',
            dateTime: DateTime(now.year, now.month, now.day, 13, 40),
            inProgressStartedAt: DateTime(now.year, now.month, now.day, 13, 20),
            readyAt: DateTime(now.year, now.month, now.day, 13, 35),
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
            id: 'recent-4',
            restaurantId: 'rest-1',
            restaurantTitle: 'Planet Donuts',
            customerId: 'cust-d',
            customerName: 'D',
            customerEmail: 'd@example.com',
            customerPhone: '4',
            dateTime: DateTime(now.year, now.month, now.day, 13, 50),
            inProgressStartedAt: DateTime(now.year, now.month, now.day, 13, 30),
            readyAt: DateTime(now.year, now.month, now.day, 13, 46),
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
            id: 'recent-5',
            restaurantId: 'rest-1',
            restaurantTitle: 'Planet Donuts',
            customerId: 'cust-e',
            customerName: 'E',
            customerEmail: 'e@example.com',
            customerPhone: '5',
            dateTime: DateTime(now.year, now.month, now.day, 12, 10),
            inProgressStartedAt: DateTime(now.year, now.month, now.day, 11, 55),
            readyAt: DateTime(now.year, now.month, now.day, 12, 9),
            paymentMethod: 'Luqmah',
            status: VendorOrderStatus.completed,
            items: const [
              VendorOrderItem(name: 'Iced Latte', quantity: 1, price: 2),
            ],
            subtotal: 2,
            coupon: 0,
            total: 2,
          ),
          VendorOrder(
            id: 'old-order',
            restaurantId: 'rest-1',
            restaurantTitle: 'Planet Donuts',
            customerId: 'cust-old',
            customerName: 'Old',
            customerEmail: 'old@example.com',
            customerPhone: '6',
            dateTime: now.subtract(const Duration(days: 45)),
            inProgressStartedAt: now.subtract(const Duration(days: 45, minutes: 10)),
            readyAt: now.subtract(const Duration(days: 45)),
            paymentMethod: 'Luqmah',
            status: VendorOrderStatus.completed,
            items: const [
              VendorOrderItem(name: 'Old Item', quantity: 10, price: 1),
            ],
            subtotal: 10,
            coupon: 0,
            total: 10,
          ),
          VendorOrder(
            id: 'cancelled',
            restaurantId: 'rest-1',
            restaurantTitle: 'Planet Donuts',
            customerId: 'cust-cancelled',
            customerName: 'Cancelled',
            customerEmail: 'cancelled@example.com',
            customerPhone: '7',
            dateTime: DateTime(now.year, now.month, now.day, 13, 10),
            paymentMethod: 'Luqmah',
            status: VendorOrderStatus.cancelled,
            items: const [
              VendorOrderItem(name: 'Ignore', quantity: 20, price: 1),
            ],
            subtotal: 20,
            coupon: 0,
            total: 20,
          ),
        ],
        const [
          VendorRestaurant(
            id: 'rest-1',
            title: 'Planet Donuts',
            categories: [],
          ),
        ],
      );

      final analytics = insights.restaurantAnalytics.single;
      expect(analytics.hasEnoughHistory, isTrue);
      expect(analytics.busiestHourLabel, '1 PM - 2 PM');
      expect(analytics.busiestHourOrderCount, 4);
      expect(analytics.slowestHourLabel, '12 PM - 1 PM');
      expect(analytics.topItemsInBusiestHour, contains('Glazed Donut'));
      expect(analytics.topItemsInBusiestHour, isNot(contains('Old Item')));
      expect(analytics.averagePrepMinutes, 15);
      expect(analytics.peakHourPrepMinutes, 16);
      expect(
        analytics.recommendations.map((item) => item.type),
        containsAll(<VendorRestaurantRecommendationType>[
          VendorRestaurantRecommendationType.prepareStock,
          VendorRestaurantRecommendationType.slowHourOffer,
          VendorRestaurantRecommendationType.strongItem,
        ]),
      );
    });

  test('vendor insights recommends only one low-performing item when criteria are met', () {
    final now = DateTime.now();
    final insights = summarizeVendorInsights(
      [
        VendorOrder(
          id: 'ord-1',
          restaurantId: 'rest-1',
          restaurantTitle: 'Planet Donuts',
          customerId: 'cust-1',
          customerName: 'A',
          customerEmail: 'a@example.com',
          customerPhone: '1',
          dateTime: DateTime(now.year, now.month, now.day, 13, 5),
          inProgressStartedAt: DateTime(now.year, now.month, now.day, 12, 50),
          readyAt: DateTime(now.year, now.month, now.day, 13, 4),
          paymentMethod: 'Luqmah',
          status: VendorOrderStatus.completed,
          items: const [VendorOrderItem(name: 'Glazed Donut', quantity: 4, price: 1)],
          subtotal: 4,
          coupon: 0,
          total: 4,
        ),
        VendorOrder(
          id: 'ord-2',
          restaurantId: 'rest-1',
          restaurantTitle: 'Planet Donuts',
          customerId: 'cust-2',
          customerName: 'B',
          customerEmail: 'b@example.com',
          customerPhone: '2',
          dateTime: DateTime(now.year, now.month, now.day, 13, 20),
          inProgressStartedAt: DateTime(now.year, now.month, now.day, 13, 2),
          readyAt: DateTime(now.year, now.month, now.day, 13, 18),
          paymentMethod: 'Luqmah',
          status: VendorOrderStatus.ready,
          items: const [VendorOrderItem(name: 'Iced Latte', quantity: 3, price: 2)],
          subtotal: 6,
          coupon: 0,
          total: 6,
        ),
        VendorOrder(
          id: 'ord-3',
          restaurantId: 'rest-1',
          restaurantTitle: 'Planet Donuts',
          customerId: 'cust-3',
          customerName: 'C',
          customerEmail: 'c@example.com',
          customerPhone: '3',
          dateTime: DateTime(now.year, now.month, now.day, 13, 35),
          inProgressStartedAt: DateTime(now.year, now.month, now.day, 13, 20),
          readyAt: DateTime(now.year, now.month, now.day, 13, 34),
          paymentMethod: 'Luqmah',
          status: VendorOrderStatus.completed,
          items: const [VendorOrderItem(name: 'Boston Creme', quantity: 1, price: 1)],
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
          dateTime: DateTime(now.year, now.month, now.day, 13, 50),
          inProgressStartedAt: DateTime(now.year, now.month, now.day, 13, 30),
          readyAt: DateTime(now.year, now.month, now.day, 13, 46),
          paymentMethod: 'Luqmah',
          status: VendorOrderStatus.completed,
          items: const [VendorOrderItem(name: 'Glazed Donut', quantity: 3, price: 1)],
          subtotal: 3,
          coupon: 0,
          total: 3,
        ),
        VendorOrder(
          id: 'ord-5',
          restaurantId: 'rest-1',
          restaurantTitle: 'Planet Donuts',
          customerId: 'cust-5',
          customerName: 'E',
          customerEmail: 'e@example.com',
          customerPhone: '5',
          dateTime: DateTime(now.year, now.month, now.day, 12, 0),
          inProgressStartedAt: DateTime(now.year, now.month, now.day, 11, 47),
          readyAt: DateTime(now.year, now.month, now.day, 11, 59),
          paymentMethod: 'Luqmah',
          status: VendorOrderStatus.completed,
          items: const [VendorOrderItem(name: 'Iced Latte', quantity: 2, price: 2)],
          subtotal: 4,
          coupon: 0,
          total: 4,
        ),
      ],
      const [VendorRestaurant(id: 'rest-1', title: 'Planet Donuts', categories: [])],
    );

    final lowPerformerRecommendations = insights.restaurantAnalytics.single.recommendations
        .where((item) => item.type == VendorRestaurantRecommendationType.lowPerformingItem)
        .toList(growable: false);

    expect(lowPerformerRecommendations, hasLength(1));
    expect(lowPerformerRecommendations.single.title, contains('Boston Creme'));
  });

  test('vendor insights shows fallback when a restaurant lacks enough recent history', () {
      final insights = summarizeVendorInsights(const [], const [
        VendorRestaurant(id: 'rest-1', title: 'Planet Donuts', categories: []),
      ]);

      final analytics = insights.restaurantAnalytics.single;
      expect(analytics.hasEnoughHistory, isFalse);
      expect(
        analytics.fallbackTitle,
        contains('Not enough recent order history yet'),
      );
      expect(analytics.recommendations, isEmpty);
    });
}
