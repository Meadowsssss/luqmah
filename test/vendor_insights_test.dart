import 'package:flutter_test/flutter_test.dart';
import 'package:luqmah/features/vendor/vendor_data_controller.dart';
import 'package:luqmah/models/vendor.dart';

void main() {
  test('vendor insights summarizes orders and top items', () {
    final insights = summarizeVendorInsights([
      VendorOrder(
        id: 'ord-1',
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
    ]);

    expect(insights.activeOrders, greaterThan(0));
    expect(insights.totalRevenue, greaterThan(0));
    expect(insights.averageOrderValue, greaterThan(0));
    expect(insights.topItems, isNotEmpty);
    expect(insights.topItems.first.quantity, greaterThanOrEqualTo(1));
  });
}
