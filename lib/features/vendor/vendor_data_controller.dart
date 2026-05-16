import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:typed_data';

import '../../core/realtime/realtime_event.dart';
import '../../models/vendor.dart';
import '../session/session_controller.dart';
import 'vendor_repository.dart';

class VendorDataState {
  const VendorDataState({
    required this.orders,
    required this.menuItems,
    required this.restaurants,
  });

  final List<VendorOrder> orders;
  final List<VendorMenuItem> menuItems;
  final List<VendorRestaurant> restaurants;
}

class VendorDataController extends AsyncNotifier<VendorDataState> {
  VendorRepository get _repository => ref.read(vendorRepositoryProvider);

  @override
  Future<VendorDataState> build() async {
    final token = ref.watch(sessionControllerProvider).snapshot.backendToken;
    if (token == null || token.isEmpty) {
      return const VendorDataState(orders: [], menuItems: [], restaurants: []);
    }

    final workspace = await _repository.loadWorkspace(token);
    return VendorDataState(
      orders: workspace.orders,
      menuItems: workspace.menuItems,
      restaurants: workspace.restaurants,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }

  void _replaceMenuItem(VendorMenuItem item) {
    final currentState = state.valueOrNull;
    if (currentState == null) {
      return;
    }

    final exists = currentState.menuItems.any(
      (menuItem) => menuItem.id == item.id,
    );
    final nextMenuItems = exists
        ? currentState.menuItems
              .map((menuItem) => menuItem.id == item.id ? item : menuItem)
              .toList(growable: false)
        : <VendorMenuItem>[item, ...currentState.menuItems];

    state = AsyncData(
      VendorDataState(
        orders: currentState.orders,
        menuItems: nextMenuItems,
        restaurants: currentState.restaurants,
      ),
    );
  }

  void _removeMenuItem(String itemId) {
    final currentState = state.valueOrNull;
    if (currentState == null) {
      return;
    }

    state = AsyncData(
      VendorDataState(
        orders: currentState.orders,
        menuItems: currentState.menuItems
            .where((menuItem) => menuItem.id != itemId)
            .toList(growable: false),
        restaurants: currentState.restaurants,
      ),
    );
  }

  void _replaceOrder(VendorOrder order) {
    final currentState = state.valueOrNull;
    if (currentState == null) {
      return;
    }

    final exists = currentState.orders.any((item) => item.id == order.id);
    final nextOrders = exists
        ? currentState.orders
              .map((item) => item.id == order.id ? order : item)
              .toList(growable: false)
        : <VendorOrder>[order, ...currentState.orders];

    state = AsyncData(
      VendorDataState(
        orders: nextOrders,
        menuItems: currentState.menuItems,
        restaurants: currentState.restaurants,
      ),
    );
  }

  void _patchOrderStatus(String orderId, VendorOrderStatus status) {
    final currentState = state.valueOrNull;
    if (currentState == null) {
      return;
    }

    state = AsyncData(
      VendorDataState(
        orders: currentState.orders
            .map(
              (order) =>
                  order.id == orderId ? order.copyWith(status: status) : order,
            )
            .toList(growable: false),
        menuItems: currentState.menuItems,
        restaurants: currentState.restaurants,
      ),
    );
  }

  void _patchRestaurantBusyState(String restaurantId, bool isBusy) {
    final currentState = state.valueOrNull;
    if (currentState == null) {
      return;
    }

    state = AsyncData(
      VendorDataState(
        orders: currentState.orders,
        menuItems: currentState.menuItems,
        restaurants: currentState.restaurants
            .map(
              (restaurant) => restaurant.id == restaurantId
                  ? restaurant.copyWith(isBusy: isBusy)
                  : restaurant,
            )
            .toList(growable: false),
      ),
    );
  }

  Future<void> applyRealtimeEvent(RealtimeEvent event) async {
    switch (event.type) {
      case RealtimeEventTypes.orderCreated:
      case RealtimeEventTypes.orderUpdated:
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
        return;
      case RealtimeEventTypes.restaurantUpdated:
        final restaurantId = event.restaurantId;
        final isBusy = event.isBusy;
        if (restaurantId != null && isBusy != null) {
          _patchRestaurantBusyState(restaurantId, isBusy);
          return;
        }
        await refreshSilently();
        return;
      case RealtimeEventTypes.menuUpdated:
        if (event.action == 'deleted' && event.menuItemId != null) {
          _removeMenuItem(event.menuItemId!);
          return;
        }

        final menuItemJson = event.menuItem;
        if (menuItemJson != null) {
          _replaceMenuItem(_repository.menuItemFromJson(menuItemJson));
          return;
        }
        await refreshSilently();
        return;
    }
  }

  Future<void> refreshSilently() async {
    final previous = state.valueOrNull;
    final next = await AsyncValue.guard(build);
    if (previous != null && next.hasError) {
      return;
    }
    state = next;
  }

  void _appendRestaurantCategory(
    String restaurantId,
    VendorRestaurantCategory category,
  ) {
    final currentState = state.valueOrNull;
    if (currentState == null) {
      return;
    }

    state = AsyncData(
      VendorDataState(
        orders: currentState.orders,
        menuItems: currentState.menuItems,
        restaurants: currentState.restaurants
            .map((restaurant) {
              if (restaurant.id != restaurantId ||
                  restaurant.categories.any((item) => item.id == category.id)) {
                return restaurant;
              }

              return VendorRestaurant(
                id: restaurant.id,
                title: restaurant.title,
                isBusy: restaurant.isBusy,
                categories: [...restaurant.categories, category],
              );
            })
            .toList(growable: false),
      ),
    );
  }

  Future<void> addMenuItem({
    required String restaurantId,
    String? categoryId,
    String? newCategoryTitle,
    required String title,
    required String description,
    required double price,
    required String imageUrl,
    required List<String> ingredientNames,
    required List<Map<String, Object?>> optionGroups,
  }) async {
    final token = ref.read(sessionControllerProvider).snapshot.backendToken;
    if (token == null || token.isEmpty) {
      throw StateError('Vendor session is required');
    }

    var resolvedCategoryId = categoryId;
    final normalizedNewCategoryTitle = newCategoryTitle?.trim() ?? '';
    VendorRestaurantCategory? createdCategory;

    if (normalizedNewCategoryTitle.isNotEmpty) {
      createdCategory = await _repository.createMenuCategory(
        token: token,
        restaurantId: restaurantId,
        title: normalizedNewCategoryTitle,
      );
      resolvedCategoryId = createdCategory.id;
    }

    if (resolvedCategoryId == null || resolvedCategoryId.isEmpty) {
      throw StateError('A category is required');
    }

    final menuItem = await _repository.createMenuItem(
      token: token,
      restaurantId: restaurantId,
      categoryId: resolvedCategoryId,
      title: title,
      description: description,
      price: price,
      imageUrl: imageUrl,
      ingredientNames: ingredientNames,
      optionGroups: optionGroups,
    );
    if (createdCategory != null) {
      _appendRestaurantCategory(restaurantId, createdCategory);
    }
    _replaceMenuItem(menuItem);
  }

  Future<String> uploadMenuItemImage({
    required Uint8List bytes,
    required String filename,
    String? contentType,
  }) async {
    final token = ref.read(sessionControllerProvider).snapshot.backendToken;
    if (token == null || token.isEmpty) {
      throw StateError('Vendor session is required');
    }

    return _repository.uploadMenuItemImage(
      token: token,
      bytes: bytes,
      filename: filename,
      contentType: contentType,
    );
  }

  Future<void> editMenuItem({
    required String itemId,
    required String restaurantId,
    String? categoryId,
    String? newCategoryTitle,
    required String title,
    required String description,
    required double price,
    required String imageUrl,
    required List<String> ingredientNames,
    required List<Map<String, Object?>> optionGroups,
  }) async {
    final token = ref.read(sessionControllerProvider).snapshot.backendToken;
    if (token == null || token.isEmpty) {
      throw StateError('Vendor session is required');
    }

    var resolvedCategoryId = categoryId;
    final normalizedNewCategoryTitle = newCategoryTitle?.trim() ?? '';
    VendorRestaurantCategory? createdCategory;

    if (normalizedNewCategoryTitle.isNotEmpty) {
      createdCategory = await _repository.createMenuCategory(
        token: token,
        restaurantId: restaurantId,
        title: normalizedNewCategoryTitle,
      );
      resolvedCategoryId = createdCategory.id;
    }

    if (resolvedCategoryId == null || resolvedCategoryId.isEmpty) {
      throw StateError('A category is required');
    }

    final menuItem = await _repository.updateMenuItem(
      token: token,
      itemId: itemId,
      categoryId: resolvedCategoryId,
      title: title,
      description: description,
      price: price,
      imageUrl: imageUrl,
      ingredientNames: ingredientNames,
      optionGroups: optionGroups,
    );
    if (createdCategory != null) {
      _appendRestaurantCategory(restaurantId, createdCategory);
    }
    _replaceMenuItem(menuItem);
  }

  Future<void> toggleMenuItemAvailability(
    String itemId,
    bool isAvailable,
  ) async {
    final token = ref.read(sessionControllerProvider).snapshot.backendToken;
    if (token == null || token.isEmpty) {
      throw StateError('Vendor session is required');
    }

    final menuItem = await _repository.updateMenuItemAvailability(
      token: token,
      itemId: itemId,
      isAvailable: isAvailable,
    );
    _replaceMenuItem(menuItem);
  }

  Future<void> deleteMenuItem(String itemId) async {
    final token = ref.read(sessionControllerProvider).snapshot.backendToken;
    if (token == null || token.isEmpty) {
      throw StateError('Vendor session is required');
    }

    final deletedItemId = await _repository.deleteMenuItem(
      token: token,
      itemId: itemId,
    );
    _removeMenuItem(deletedItemId);
  }

  Future<void> updateOrderStatus(
    String orderId,
    VendorOrderStatus status,
  ) async {
    final token = ref.read(sessionControllerProvider).snapshot.backendToken;
    if (token == null || token.isEmpty) {
      throw StateError('Vendor session is required');
    }

    final updatedOrder = await _repository.updateOrderStatus(
      token: token,
      orderId: orderId,
      status: status,
    );

    final currentState = state.valueOrNull;
    if (currentState == null) {
      await refresh();
      return;
    }

    state = AsyncData(
      VendorDataState(
        orders: currentState.orders
            .map((order) => order.id == orderId ? updatedOrder : order)
            .toList(growable: false),
        menuItems: currentState.menuItems,
        restaurants: currentState.restaurants,
      ),
    );
  }

  Future<void> updateRestaurantBusyState(
    String restaurantId,
    bool isBusy,
  ) async {
    final token = ref.read(sessionControllerProvider).snapshot.backendToken;
    if (token == null || token.isEmpty) {
      throw StateError('Vendor session is required');
    }

    final updatedRestaurant = await _repository.updateRestaurantBusyState(
      token: token,
      restaurantId: restaurantId,
      isBusy: isBusy,
    );

    final currentState = state.valueOrNull;
    if (currentState == null) {
      await refresh();
      return;
    }

    state = AsyncData(
      VendorDataState(
        orders: currentState.orders,
        menuItems: currentState.menuItems,
        restaurants: currentState.restaurants
            .map(
              (restaurant) => restaurant.id == restaurantId
                  ? updatedRestaurant
                  : restaurant,
            )
            .toList(growable: false),
      ),
    );
  }
}

final vendorDataControllerProvider =
    AsyncNotifierProvider<VendorDataController, VendorDataState>(
      VendorDataController.new,
    );

final vendorOrderByIdProvider =
    Provider.family<AsyncValue<VendorOrder?>, String>((ref, id) {
      final state = ref.watch(vendorDataControllerProvider);
      return state.whenData((value) {
        for (final order in value.orders) {
          if (order.id == id) {
            return order;
          }
        }
        return null;
      });
    });

class VendorInsightsSummary {
  const VendorInsightsSummary({
    required this.activeOrders,
    required this.completedOrders,
    required this.totalRevenue,
    required this.averageOrderValue,
    required this.topItems,
  });

  final int activeOrders;
  final int completedOrders;
  final double totalRevenue;
  final double averageOrderValue;
  final List<VendorTopItem> topItems;
}

class VendorTopItem {
  const VendorTopItem({
    required this.name,
    required this.quantity,
    required this.revenue,
  });

  final String name;
  final int quantity;
  final double revenue;
}

VendorInsightsSummary summarizeVendorInsights(List<VendorOrder> orders) {
  final completedOrders = orders
      .where((order) => order.status.isPast)
      .toList(growable: false);
  final activeOrders = orders.length - completedOrders.length;
  final revenueSource = completedOrders.isEmpty ? orders : completedOrders;
  final totalRevenue = revenueSource.fold<double>(
    0,
    (sum, order) => sum + order.total,
  );
  final averageOrderValue = revenueSource.isEmpty
      ? 0.0
      : totalRevenue / revenueSource.length;

  final totals = <String, VendorTopItem>{};
  for (final order in orders) {
    for (final item in order.items) {
      final existing = totals[item.name];
      totals[item.name] = VendorTopItem(
        name: item.name,
        quantity: (existing?.quantity ?? 0) + item.quantity,
        revenue: (existing?.revenue ?? 0) + item.lineTotal,
      );
    }
  }

  final topItems = totals.values.toList(growable: false)
    ..sort((a, b) => b.quantity.compareTo(a.quantity));

  return VendorInsightsSummary(
    activeOrders: activeOrders,
    completedOrders: completedOrders.length,
    totalRevenue: totalRevenue,
    averageOrderValue: averageOrderValue,
    topItems: topItems.take(4).toList(growable: false),
  );
}

final vendorInsightsProvider = Provider<AsyncValue<VendorInsightsSummary>>((
  ref,
) {
  final state = ref.watch(vendorDataControllerProvider);
  return state.whenData((value) => summarizeVendorInsights(value.orders));
});
