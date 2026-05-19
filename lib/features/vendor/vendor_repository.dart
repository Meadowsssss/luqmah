import 'dart:typed_data';

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

  Future<String> uploadMenuItemImage({
    required String token,
    required Uint8List bytes,
    required String filename,
    String? contentType,
  }) async {
    final response = await _apiClient.uploadFile(
      '/vendor/uploads/menu-item-image',
      token: token,
      fieldName: 'image',
      bytes: bytes,
      filename: filename,
      contentType: contentType,
    );
    return response['imageUrl'] as String;
  }

  Future<String> uploadRestaurantCover({
    required String token,
    required Uint8List bytes,
    required String filename,
    String? contentType,
  }) async {
    final response = await _apiClient.uploadFile(
      '/vendor/uploads/restaurant-cover',
      token: token,
      fieldName: 'image',
      bytes: bytes,
      filename: filename,
      contentType: contentType,
    );
    return response['imageUrl'] as String;
  }

  Future<VendorWorkspaceData> loadWorkspace(String token) async {
    final restaurantsResponse = await _apiClient.get(
      '/vendor/restaurants/me',
      token: token,
    );
    final menuItemsResponse = await _apiClient.get(
      '/vendor/menu-items',
      token: token,
    );
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

    final restaurants =
        ((restaurantsResponse['restaurants'] as List<dynamic>?) ?? const [])
            .map(
              (json) => _vendorRestaurantFromJson(json as Map<String, dynamic>),
            )
            .toList(growable: false);
    final menuItems =
        ((menuItemsResponse['menuItems'] as List<dynamic>?) ?? const [])
            .map(
              (json) => _vendorMenuItemFromJson(json as Map<String, dynamic>),
            )
            .toList(growable: false);
    final orders =
        [
              ...((activeOrdersResponse['orders'] as List<dynamic>?) ??
                  const []),
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

  Future<List<VendorBlacklistEntry>> loadBlacklist(String token) async {
    final response = await _apiClient.get('/vendor/blacklist', token: token);
    final entries = (response['entries'] as List<dynamic>? ?? const []);
    return entries
        .map(
          (json) => _vendorBlacklistEntryFromJson(json as Map<String, dynamic>),
        )
        .toList(growable: false);
  }

  Future<VendorBlacklistEntry> blacklistCustomer({
    required String token,
    required String customerId,
    String? reason,
  }) async {
    final response = await _apiClient.post(
      '/vendor/blacklist',
      token: token,
      body: {
        'customerId': customerId,
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      },
    );
    return _vendorBlacklistEntryFromJson(
      response['entry'] as Map<String, dynamic>,
    );
  }

  Future<String> removeBlacklistCustomer({
    required String token,
    required String customerId,
  }) async {
    final response = await _apiClient.delete(
      '/vendor/blacklist/$customerId',
      token: token,
    );
    return response['removedCustomerId'] as String? ?? customerId;
  }

  Future<VendorMenuItem> createMenuItem({
    required String token,
    required String restaurantId,
    required String categoryId,
    required String title,
    required String description,
    required double price,
    required String imageUrl,
    required List<String> ingredientNames,
    required List<Map<String, Object?>> optionGroups,
  }) async {
    final response = await _apiClient.post(
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
        'optionGroups': optionGroups,
      },
    );

    return _vendorMenuItemFromJson(
      response['menuItem'] as Map<String, dynamic>,
    );
  }

  VendorMenuItem menuItemFromJson(Map<String, dynamic> json) {
    return _vendorMenuItemFromJson(json);
  }

  VendorOrder orderFromJson(Map<String, dynamic> json) {
    return _vendorOrderFromJson(json);
  }

  Future<VendorMenuItem> updateMenuItem({
    required String token,
    required String itemId,
    required String categoryId,
    required String title,
    required String description,
    required double price,
    required String imageUrl,
    required List<String> ingredientNames,
    required List<Map<String, Object?>> optionGroups,
  }) async {
    final response = await _apiClient.patch(
      '/vendor/menu-items/$itemId',
      token: token,
      body: {
        'categoryId': categoryId,
        'title': title,
        'description': description,
        'price': price,
        'imageUrl': imageUrl.isEmpty ? null : imageUrl,
        'ingredientNames': ingredientNames,
        'optionGroups': optionGroups,
      },
    );

    return _vendorMenuItemFromJson(
      response['menuItem'] as Map<String, dynamic>,
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
      body: {'restaurantId': restaurantId, 'title': title},
    );

    final category = response['category'] as Map<String, dynamic>;
    return VendorRestaurantCategory(
      id: category['id'] as String,
      title: category['title'] as String,
    );
  }

  Future<VendorOrder> updateOrderStatus({
    required String token,
    required String orderId,
    required VendorOrderStatus status,
  }) async {
    final response = await _apiClient.patch(
      '/vendor/orders/$orderId/status',
      token: token,
      body: {'status': status.apiValue},
    );
    return _vendorOrderFromJson(response['order'] as Map<String, dynamic>);
  }

  Future<VendorRestaurant> updateRestaurantBusyState({
    required String token,
    required String restaurantId,
    required bool isBusy,
  }) async {
    final response = await _apiClient.patch(
      '/vendor/restaurants/busy',
      token: token,
      body: {'restaurantId': restaurantId, 'isBusy': isBusy},
    );
    return _vendorRestaurantFromJson(
      response['restaurant'] as Map<String, dynamic>,
    );
  }

  Future<VendorRestaurant> updateRestaurant({
    required String token,
    required String restaurantId,
    required String title,
    required String description,
    required String address,
    required String coverImage,
  }) async {
    final response = await _apiClient.patch(
      '/vendor/restaurants/$restaurantId',
      token: token,
      body: {
        'title': title,
        'description': description.isEmpty ? null : description,
        'address': address.isEmpty ? null : address,
        'coverImage': coverImage.isEmpty ? null : coverImage,
      },
    );
    return _vendorRestaurantFromJson(
      response['restaurant'] as Map<String, dynamic>,
    );
  }

  Future<VendorMenuItem> updateMenuItemAvailability({
    required String token,
    required String itemId,
    required bool isAvailable,
  }) async {
    final response = await _apiClient.patch(
      '/vendor/menu-items/$itemId/availability',
      token: token,
      body: {'isAvailable': isAvailable},
    );
    return _vendorMenuItemFromJson(
      response['menuItem'] as Map<String, dynamic>,
    );
  }

  Future<String> deleteMenuItem({
    required String token,
    required String itemId,
  }) async {
    final response = await _apiClient.delete(
      '/vendor/menu-items/$itemId',
      token: token,
    );
    return response['deletedItemId'] as String? ?? itemId;
  }

  VendorRestaurant _vendorRestaurantFromJson(Map<String, dynamic> json) {
    return VendorRestaurant(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      address: json['address'] as String? ?? '',
      coverImage: json['coverImage'] as String? ?? '',
      isBusy: json['isBusy'] as bool? ?? false,
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
    final ingredients = ((json['ingredients'] as List<dynamic>?) ?? const [])
        .map((item) => (item as Map<String, dynamic>)['name'] as String)
        .toList(growable: false);
    final optionGroups = ((json['optionGroups'] as List<dynamic>?) ?? const [])
        .map((group) {
          final groupJson = group as Map<String, dynamic>;
          return VendorMenuItemOptionGroup(
            id: groupJson['id'] as String,
            title: groupJson['title'] as String,
            selectionType: (groupJson['selectionType'] as String) == 'SINGLE'
                ? VendorMenuItemOptionSelectionType.single
                : VendorMenuItemOptionSelectionType.multiple,
            isRequired: groupJson['isRequired'] as bool? ?? false,
            options: ((groupJson['options'] as List<dynamic>?) ?? const [])
                .map(
                  (item) => VendorMenuItemCustomization(
                    id: (item as Map<String, dynamic>)['id'] as String,
                    title: item['title'] as String,
                    priceDelta: ((item['priceDelta'] as num?) ?? 0).toDouble(),
                  ),
                )
                .toList(growable: false),
          );
        })
        .toList(growable: false);

    return VendorMenuItem(
      restaurantId:
          (json['restaurant'] as Map<String, dynamic>)['id'] as String,
      restaurantTitle:
          (json['restaurant'] as Map<String, dynamic>)['title'] as String,
      categoryId: (json['category'] as Map<String, dynamic>)['id'] as String,
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      category: (json['category'] as Map<String, dynamic>)['title'] as String,
      ingredients: ingredients,
      price: (json['price'] as num).toDouble(),
      image: json['imageUrl'] as String? ?? '',
      isAvailable: json['isAvailable'] as bool? ?? true,
      optionGroups: optionGroups,
    );
  }

  VendorOrder _vendorOrderFromJson(Map<String, dynamic> json) {
    final items = ((json['orderItems'] as List<dynamic>?) ?? const [])
        .map((item) {
          final itemJson = item as Map<String, dynamic>;
          final extras =
              ((itemJson['customizations'] as List<dynamic>?) ?? const [])
                  .map(
                    (customization) =>
                        (customization as Map<String, dynamic>)['title']
                            as String,
                  )
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
      restaurantId:
          ((json['restaurant'] as Map<String, dynamic>?)?['id'] as String?) ??
          '',
      restaurantTitle:
          ((json['restaurant'] as Map<String, dynamic>?)?['title']
              as String?) ??
          'Restaurant',
      customerId:
          ((json['customer'] as Map<String, dynamic>?)?['id'] as String?) ?? '',
      customerName:
          ((json['customer'] as Map<String, dynamic>?)?['name'] as String?) ??
          'Customer',
      customerEmail:
          ((json['customer'] as Map<String, dynamic>?)?['email'] as String?) ??
          '',
      customerPhone:
          ((json['customer'] as Map<String, dynamic>?)?['phoneNumber']
              as String?) ??
          '',
      dateTime: DateTime.parse(json['createdAt'] as String).toLocal(),
      estimatedReadyAt: json['estimatedReadyAt'] == null
          ? null
          : DateTime.parse(json['estimatedReadyAt'] as String).toLocal(),
      paymentMethod: 'Luqmah',
      status: vendorOrderStatusFromApi(json['status'] as String),
      items: items,
      subtotal: subtotal,
      coupon: subtotal - total,
      total: total,
    );
  }

  VendorBlacklistEntry _vendorBlacklistEntryFromJson(
    Map<String, dynamic> json,
  ) {
    final customer = json['customer'] as Map<String, dynamic>?;
    return VendorBlacklistEntry(
      customerId: customer?['id'] as String? ?? '',
      customerName: customer?['name'] as String? ?? 'Customer',
      customerEmail: customer?['email'] as String? ?? '',
      customerPhone: customer?['phoneNumber'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
    );
  }
}
