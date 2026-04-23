import 'package:flutter_test/flutter_test.dart';
import 'package:luqmah/features/customer/orders/customer_orders_repository.dart';
import 'package:luqmah/models/customer_order.dart';
import 'package:luqmah/models/vendor.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('customer order repository saves and loads order history', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = CustomerOrdersRepository();

    final order = CustomerOrder(
      id: 'ORD-1',
      restaurantName: 'Al-Salam Grill',
      placedAt: DateTime(2026, 4, 23, 12),
      status: VendorOrderStatus.accepted,
      items: [
        CustomerOrderItem(
          itemId: 'chicken_shawarma',
          name: 'Chicken Shawarma',
          quantity: 2,
          price: 2.5,
        ),
      ],
      total: 5,
    );

    await repository.saveOrders([order]);
    final loaded = await repository.loadOrders();

    expect(loaded, hasLength(1));
    expect(loaded.first.id, 'ORD-1');
    expect(loaded.first.restaurantName, 'Al-Salam Grill');
    expect(loaded.first.items.single.quantity, 2);
    expect(loaded.first.total, 5);
  });
}
