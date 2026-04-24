import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../models/vendor.dart';

final vendorRepositoryProvider = Provider<VendorRepository>((ref) {
  return VendorRepository(ref.watch(apiClientProvider));
});

class VendorWorkspaceData {
  const VendorWorkspaceData({
    required this.orders,
    required this.menuItems,
    required this.restaurants,
  });

  final List<VendorOrder> orders;
  final List<VendorMenuItem> menuItems;
  final List<VendorRestaurant> restaurants;
}

class VendorRepository {
  const VendorRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<VendorWorkspaceData> loadWorkspace(String token) async {
    final restaurantsResponse = await _apiClient.get('/vendor/restaurants/me', token: token);
    final menuItemsResponse = await _apiClient.get('/vendor/menu-items', token: token);
    final activeOrdersResponse = await _apiClient.get(
      '/vendor/orders',
      token: token,
      queryParameters: const {'status': 'new'},
    );
    final pastOrdersResponse = await _apiClient.get(
      '/vendor/orders',
      token: token,
      queryParameters: const {'status': 'past'},
    );

    final restaurants = ((restaurantsResponse['restaurants'] as List<dynamic>?) ?? const [])
        .map((json) => _vendorRestaurantFromJson(json as Map<String, dynamic>))
        .toList(growable: false);
    final menuItems = ((menuItemsResponse['menuItems'] as List<dynamic>?) ?? const [])
        .map((json) => _vendorMenuItemFromJson(json as Map<String, dynamic>))
        .toList(growable: false);
    final orders = [
      ...((activeOrdersResponse['orders'] as List<dynamic>?) ?? const []),
      ...((pastOrdersResponse['orders'] as List<dynamic>?) ?? const []),
    ]
        .map((json) => _vendorOrderFromJson(json as Map<String, dynamic>))
        .toList(growable: false)
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    return VendorWorkspaceData(
      orders: orders,
      menuItems: menuItems,
      restaurants: restaurants,
    );
  }

  Future<void> createMenuItem({
    required String token,
    required String restaurantId,
    required String categoryId,
    required String title,
    required String description,
    required double price,
    required String imageUrl,
    required List<String> ingredientNames,
    required List<Map<String, Object?>> customizations,
  }) async {
    await _apiClient.post(
      '/vendor/menu-items',
      token: token,
      body: {
        'restaurantId': restaurantId,
        'categoryId': categoryId,
        'title': title,
        if (description.isNotEmpty) 'description': description,
        'price': price,
        if (imageUrl.isNotEmpty) 'imageUrl': imageUrl,
        'ingredientNames': ingredientNames,
        'customizations': customizations,
      },
    );
  }

  Future<VendorRestaurantCategory> createMenuCategory({
    required String token,
    required String restaurantId,
    required String title,
  }) async {
    final response = await _apiClient.post(
      '/vendor/menu-categories',
      token: token,
      body: {
        'restaurantId': restaurantId,
        'title': title,
      },
    );

    final category = response['category'] as Map<String, dynamic>;
    return VendorRestaurantCategory(
      id: category['id'] as String,
      title: category['title'] as String,
    );
  }

  Future<void> updateOrderStatus({
    required String token,
    required String orderId,
    required VendorOrderStatus status,
  }) async {
    await _apiClient.patch(
      '/vendor/orders/$orderId/status',
      token: token,
      body: {'status': status.apiValue},
    );
  }

  VendorRestaurant _vendorRestaurantFromJson(Map<String, dynamic> json) {
    return VendorRestaurant(
      id: json['id'] as String,
      title: json['title'] as String,
      categories: ((json['menuCategories'] as List<dynamic>?) ?? const [])
          .map(
            (category) => VendorRestaurantCategory(
              id: (category as Map<String, dynamic>)['id'] as String,
              title: category['title'] as String,
            ),
          )
          .toList(growable: false),
    );
  }

  VendorMenuItem _vendorMenuItemFromJson(Map<String, dynamic> json) {
    final customizations = ((json['customizations'] as List<dynamic>?) ?? const [])
        .map((item) => (item as Map<String, dynamic>)['title'] as String)
        .toList(growable: false);
    final ingredients = ((json['ingredients'] as List<dynamic>?) ?? const [])
        .map((item) => (item as Map<String, dynamic>)['name'] as String)
        .toList(growable: false);

    return VendorMenuItem(
      restaurantId: (json['restaurant'] as Map<String, dynamic>)['id'] as String,
      restaurantTitle: (json['restaurant'] as Map<String, dynamic>)['title'] as String,
      categoryId: (json['category'] as Map<String, dynamic>)['id'] as String,
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      category: (json['category'] as Map<String, dynamic>)['title'] as String,
      ingredients: ingredients,
      price: (json['price'] as num).toDouble(),
      image: json['imageUrl'] as String? ?? '',
      isAvailable: json['isAvailable'] as bool? ?? true,
      customizations: customizations,
    );
  }

  VendorOrder _vendorOrderFromJson(Map<String, dynamic> json) {
    final items = ((json['orderItems'] as List<dynamic>?) ?? const [])
        .map((item) {
          final itemJson = item as Map<String, dynamic>;
          final extras = ((itemJson['customizations'] as List<dynamic>?) ?? const [])
              .map((customization) => (customization as Map<String, dynamic>)['title'] as String)
              .toList(growable: false);
          return VendorOrderItem(
            name: itemJson['itemTitle'] as String,
            quantity: (itemJson['quantity'] as num).toInt(),
            price: (itemJson['unitPrice'] as num).toDouble(),
            extras: extras,
          );
        })
        .toList(growable: false);

    final subtotal = items.fold<double>(0, (sum, item) => sum + item.lineTotal);
    final total = (json['totalAmount'] as num).toDouble();

    return VendorOrder(
      id: json['id'] as String,
      customerName: ((json['customer'] as Map<String, dynamic>?)?['name'] as String?) ?? 'Customer',
      customerPhone: ((json['customer'] as Map<String, dynamic>?)?['email'] as String?) ?? '',
      dateTime: DateTime.parse(json['createdAt'] as String),
      paymentMethod: 'Luqmah',
      status: vendorOrderStatusFromApi(json['status'] as String),
      items: items,
      subtotal: subtotal,
      coupon: subtotal - total,
      total: total,
    );
  }
}
