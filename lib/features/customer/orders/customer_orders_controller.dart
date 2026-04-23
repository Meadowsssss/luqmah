import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/customer_order.dart';
import '../../../models/vendor.dart';
import '../cart/cart_controller.dart';
import '../data/restaurant_repository.dart';
import 'customer_orders_repository.dart';
import '../../session/session_controller.dart';
import '../../vendor/vendor_data_controller.dart';

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
    final restaurantRepository = ref.read(restaurantRepositoryProvider);
    final session = ref.read(sessionControllerProvider).snapshot;
    final restaurantNames = <String>{};

    for (final line in lines) {
      final restaurant = restaurantRepository.findRestaurantForMenuItem(line.item.id);
      if (restaurant != null) {
        restaurantNames.add(restaurant.name);
      }
    }

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
              itemId: line.item.id,
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

    ref.read(vendorDataControllerProvider.notifier).appendIncomingOrder(
          customerName: _customerNameFromEmail(session.email),
          customerPhone: '+962 7 9000 1200',
          paymentMethod: 'Campus card',
          lines: lines,
          total: total,
        );

    return order;
  }

  String _customerNameFromEmail(String email) {
    if (email.isEmpty) {
      return 'Campus Customer';
    }

    final localPart = email.split('@').first.trim();
    if (localPart.isEmpty) {
      return 'Campus Customer';
    }

    final words = localPart
        .split(RegExp(r'[._-]+'))
        .where((word) => word.isNotEmpty)
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .toList(growable: false);

    return words.isEmpty ? 'Campus Customer' : words.join(' ');
  }
}

final customerOrdersControllerProvider =
    AsyncNotifierProvider<CustomerOrdersController, List<CustomerOrder>>(
      CustomerOrdersController.new,
    );
