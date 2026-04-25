import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../models/customer_order.dart';
import '../cart/cart_controller.dart';
import '../../session/session_controller.dart';
import 'customer_orders_repository.dart';

class CustomerOrdersController extends AsyncNotifier<List<CustomerOrder>> {
  CustomerOrdersRepository get _repository =>
      ref.read(customerOrdersRepositoryProvider);

  @override
  Future<List<CustomerOrder>> build() async {
    final token = ref.watch(sessionControllerProvider).snapshot.backendToken;
    if (token == null || token.isEmpty) {
      return const <CustomerOrder>[];
    }
    return _repository.loadOrders(token);
  }

  Future<CustomerOrder> placeOrder({
    required List<CartLine> lines,
    required double total,
  }) async {
    final token = ref.read(sessionControllerProvider).snapshot.backendToken;
    if (token == null || token.isEmpty) {
      throw ApiException('Customer backend session is required. Please sign in again.');
    }

    final restaurantId = lines.isEmpty ? null : lines.first.item.restaurantId;
    if (restaurantId == null || restaurantId.isEmpty) {
      throw ApiException('A restaurant is required to place an order.');
    }

    final invalidLine = lines.any((line) => line.item.restaurantId != restaurantId);
    if (invalidLine) {
      throw ApiException('Your cart can only contain items from one restaurant.');
    }

    final order = await _repository.createOrder(
      token: token,
      restaurantId: restaurantId,
      items: lines
          .map(
            (line) => CustomerCheckoutItemInput(
              menuItemId: line.item.itemId,
              quantity: line.quantity,
            ),
          )
          .toList(growable: false),
    );

    await refresh();
    return order;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }
}

final customerOrdersControllerProvider =
    AsyncNotifierProvider<CustomerOrdersController, List<CustomerOrder>>(
      CustomerOrdersController.new,
    );
