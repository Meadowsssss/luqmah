import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/realtime/realtime_event.dart';
import '../../../features/customer/data/restaurant_repository.dart';
import '../../../models/customer_order.dart';
import '../../../models/vendor.dart';
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

  void _replaceOrder(CustomerOrder order) {
    final currentOrders = state.valueOrNull;
    if (currentOrders == null) {
      return;
    }

    final exists = currentOrders.any((item) => item.id == order.id);
    state = AsyncData(
      exists
          ? currentOrders
              .map((item) => item.id == order.id ? order : item)
              .toList(growable: false)
          : <CustomerOrder>[order, ...currentOrders],
    );
  }

  void _patchOrderStatus(String orderId, VendorOrderStatus status) {
    final currentOrders = state.valueOrNull;
    if (currentOrders == null) {
      return;
    }

    state = AsyncData(
      currentOrders
          .map((order) => order.id == orderId ? order.copyWith(status: status) : order)
          .toList(growable: false),
    );
  }

  Future<void> applyRealtimeEvent(RealtimeEvent event) async {
    final orderJson = event.order;
    if (orderJson != null) {
      _replaceOrder(_repository.orderFromJson(orderJson));
      return;
    }

    final orderId = event.orderId;
    final status = event.status;
    if (orderId != null && status != null) {
      _patchOrderStatus(orderId, vendorOrderStatusFromApi(status));
      return;
    }

    await refreshSilently();
  }

  Future<CustomerOrder> placeOrder({
    required List<CartLine> lines,
    required double total,
  }) async {
    final token = ref.read(sessionControllerProvider).snapshot.backendToken;
    if (token == null || token.isEmpty) {
      throw ApiException(
        'Customer backend session is required. Please sign in again.',
      );
    }

    final restaurantId = lines.isEmpty ? null : lines.first.item.restaurantId;
    if (restaurantId == null || restaurantId.isEmpty) {
      throw ApiException('A restaurant is required to place an order.');
    }

    final invalidLine = lines.any(
      (line) => line.item.restaurantId != restaurantId,
    );
    if (invalidLine) {
      throw ApiException(
        'Your cart can only contain items from one restaurant.',
      );
    }

    final order = await _repository.createOrder(
      token: token,
      restaurantId: restaurantId,
      items: lines
          .map(
            (line) => CustomerCheckoutItemInput(
              menuItemId: line.item.itemId,
              quantity: line.quantity,
              optionIds: line.item.selectedOptions
                  .map((option) => option.id)
                  .toList(growable: false),
            ),
          )
          .toList(growable: false),
    );

    _replaceOrder(order);
    return order;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }

  Future<void> refreshSilently() async {
    final previous = state.valueOrNull;
    final next = await AsyncValue.guard(build);
    if (previous != null && next.hasError) {
      return;
    }
    state = next;
  }

  Future<void> rateOrder({
    required CustomerOrder order,
    required int score,
  }) async {
    final token = ref.read(sessionControllerProvider).snapshot.backendToken;
    if (token == null || token.isEmpty) {
      throw ApiException(
        'Customer backend session is required. Please sign in again.',
      );
    }

    await _repository.rateOrder(token: token, orderId: order.id, score: score);
    _replaceOrder(order.copyWith(ratingScore: score));
    await ref.read(restaurantsProvider.notifier).refreshSilently();
    if (order.restaurantId.isNotEmpty) {
      await ref.read(restaurantByIdProvider(order.restaurantId).notifier).refreshSilently();
    }
  }

  Future<void> dismissRatingPrompt(CustomerOrder order) async {
    final token = ref.read(sessionControllerProvider).snapshot.backendToken;
    if (token == null || token.isEmpty) {
      throw ApiException(
        'Customer backend session is required. Please sign in again.',
      );
    }

    final updatedOrder = await _repository.dismissRatingPrompt(token: token, orderId: order.id);
    _replaceOrder(updatedOrder ?? order.copyWith(ratingPromptDismissedAt: DateTime.now()));
  }
}

final customerOrdersControllerProvider =
    AsyncNotifierProvider<CustomerOrdersController, List<CustomerOrder>>(
      CustomerOrdersController.new,
    );
