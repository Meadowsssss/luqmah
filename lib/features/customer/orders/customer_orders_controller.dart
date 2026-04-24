import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/customer_order.dart';
import '../../../models/vendor.dart';
import '../cart/cart_controller.dart';
import 'customer_orders_repository.dart';

final customerOrdersRepositoryProvider = Provider<CustomerOrdersRepository>((ref) {
  return CustomerOrdersRepository();
});

class CustomerOrdersController extends AsyncNotifier<List<CustomerOrder>> {
  CustomerOrdersRepository get _repository =>
      ref.read(customerOrdersRepositoryProvider);

  @override
  Future<List<CustomerOrder>> build() {
    return _repository.loadOrders();
  }

  Future<CustomerOrder> placeOrder({
    required List<CartLine> lines,
    required double total,
  }) async {
    final current = state.valueOrNull ?? await _repository.loadOrders();
    final restaurantNames = lines.map((line) => line.item.restaurantName).toSet();

    final restaurantName = restaurantNames.isEmpty
        ? 'Campus order'
        : restaurantNames.length == 1
        ? restaurantNames.first
        : 'Multiple restaurants';

    final order = CustomerOrder(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
      restaurantName: restaurantName,
      placedAt: DateTime.now(),
      status: VendorOrderStatus.accepted,
      items: lines
          .map(
            (line) => CustomerOrderItem(
              itemId: line.item.itemId,
              name: line.item.name,
              quantity: line.quantity,
              price: line.item.price,
            ),
          )
          .toList(growable: false),
      total: total,
    );

    final updated = <CustomerOrder>[order, ...current];
    state = AsyncData(updated);
    await _repository.saveOrders(updated);

    return order;
  }
}

final customerOrdersControllerProvider =
    AsyncNotifierProvider<CustomerOrdersController, List<CustomerOrder>>(
      CustomerOrdersController.new,
    );
