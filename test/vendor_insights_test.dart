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
  });

  test(
    'vendor insights computes per-restaurant rush recommendations for last 30 days only',
    () {
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

      final recommendation = insights.restaurantRecommendations.single;
      expect(recommendation.hasEnoughHistory, isTrue);
      expect(recommendation.peakHour, 13);
      expect(recommendation.peakHourOrderCount, 4);
      expect(recommendation.peakHourTopItems, contains('Glazed Donut'));
      expect(recommendation.peakHourTopItems, isNot(contains('Old Item')));
    },
  );

  test(
    'vendor insights shows fallback when a restaurant lacks enough recent history',
    () {
      final insights = summarizeVendorInsights(const [], const [
        VendorRestaurant(id: 'rest-1', title: 'Planet Donuts', categories: []),
      ]);

      final recommendation = insights.restaurantRecommendations.single;
      expect(recommendation.hasEnoughHistory, isFalse);
      expect(
        recommendation.recommendationTitle,
        contains('Not enough recent order history yet'),
      );
    },
  );
}
