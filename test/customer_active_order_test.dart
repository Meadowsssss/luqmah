import 'package:flutter_test/flutter_test.dart';
import 'package:luqmah/features/customer/orders/customer_orders_controller.dart';
import 'package:luqmah/models/customer_order.dart';
import 'package:luqmah/models/vendor.dart';

void main() {
  CustomerOrder buildOrder(VendorOrderStatus status) {
    return CustomerOrder(
      id: 'order_${status.name}',
      restaurantName: 'Campus Bites',
      placedAt: DateTime.parse('2026-05-18T12:00:00.000Z'),
      status: status,
      items: const [],
      total: 5,
    );
  }

  test('hasActiveCustomerOrder returns true for accepted orders', () {
    expect(
      hasActiveCustomerOrder([buildOrder(VendorOrderStatus.accepted)]),
      isTrue,
    );
  });

  test(
    'hasActiveCustomerOrder returns true for in progress and ready orders',
    () {
      expect(
        hasActiveCustomerOrder([
          buildOrder(VendorOrderStatus.inProgress),
          buildOrder(VendorOrderStatus.ready),
        ]),
        isTrue,
      );
    },
  );

  test(
    'hasActiveCustomerOrder returns false for completed and cancelled only',
    () {
      expect(
        hasActiveCustomerOrder([
          buildOrder(VendorOrderStatus.completed),
          buildOrder(VendorOrderStatus.cancelled),
        ]),
        isFalse,
      );
    },
  );
}
