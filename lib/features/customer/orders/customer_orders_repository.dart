import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../models/customer_order.dart';
import '../../../models/vendor.dart';

final customerOrdersRepositoryProvider = Provider<CustomerOrdersRepository>((
  ref,
) {
  return CustomerOrdersRepository(ref.watch(apiClientProvider));
});

class CustomerCheckoutItemInput {
  const CustomerCheckoutItemInput({
    required this.menuItemId,
    required this.quantity,
    this.optionIds = const <String>[],
  });

  final String menuItemId;
  final int quantity;
  final List<String> optionIds;

  Map<String, Object?> toJson() {
    return {
      'menuItemId': menuItemId,
      'quantity': quantity,
      'optionIds': optionIds,
    };
  }
}

class CustomerOrdersRepository {
  const CustomerOrdersRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<CustomerOrder>> loadOrders(String token) async {
    final response = await _apiClient.get('/orders/me', token: token);
    final orders = (response['orders'] as List<dynamic>? ?? const []);
    return orders
        .map((json) => _customerOrderFromJson(json as Map<String, dynamic>))
        .toList(growable: false);
  }

  CustomerOrder orderFromJson(Map<String, dynamic> json) {
    return _customerOrderFromJson(json);
  }

  Future<CustomerOrder> createOrder({
    required String token,
    required String restaurantId,
    required List<CustomerCheckoutItemInput> items,
    String? notes,
  }) async {
    final response = await _apiClient.post(
      '/orders',
      token: token,
      body: {
        'restaurantId': restaurantId,
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
        'items': items.map((item) => item.toJson()).toList(growable: false),
      },
    );

    return _customerOrderFromJson(response['order'] as Map<String, dynamic>);
  }

  Future<void> rateOrder({
    required String token,
    required String orderId,
    required int score,
  }) async {
    await _apiClient.post(
      '/orders/$orderId/rating',
      token: token,
      body: {'score': score},
    );
  }

  Future<CustomerOrder?> dismissRatingPrompt({
    required String token,
    required String orderId,
  }) async {
    final response = await _apiClient.post('/orders/$orderId/rating-dismiss', token: token);
    final order = response['order'];
    if (order is! Map<String, dynamic> || order['id'] == null) {
      return null;
    }
    return _customerOrderFromJson(order);
  }

  CustomerOrder _customerOrderFromJson(Map<String, dynamic> json) {
    final items = (json['orderItems'] as List<dynamic>? ?? const [])
        .map((item) {
          final itemJson = item as Map<String, dynamic>;
          return CustomerOrderItem(
            itemId: itemJson['menuItemId'] as String? ?? '',
            name: itemJson['itemTitle'] as String? ?? 'Menu item',
            quantity: (itemJson['quantity'] as num).toInt(),
            price: (itemJson['unitPrice'] as num).toDouble(),
          );
        })
        .toList(growable: false);

    final restaurantJson = json['restaurant'] as Map<String, dynamic>?;
    final ratingJson = json['rating'] as Map<String, dynamic>?;

    return CustomerOrder(
      id: json['id'] as String,
      restaurantId: restaurantJson?['id'] as String? ?? '',
      restaurantName: restaurantJson?['title'] as String? ?? 'Campus order',
      placedAt: DateTime.parse(json['createdAt'] as String),
      estimatedReadyAt: json['estimatedReadyAt'] == null
          ? null
          : DateTime.parse(json['estimatedReadyAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      status: vendorOrderStatusFromApi(json['status'] as String),
      items: items,
      total: (json['totalAmount'] as num).toDouble(),
      ratingScore: (ratingJson?['score'] as num?)?.toInt(),
      ratingPromptDismissedAt: json['ratingPromptDismissedAt'] == null
          ? null
          : DateTime.parse(json['ratingPromptDismissedAt'] as String),
    );
  }
}
