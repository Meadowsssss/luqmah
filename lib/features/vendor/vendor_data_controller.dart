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

  void _replaceRestaurant(VendorRestaurant updatedRestaurant) {
    final currentState = state.valueOrNull;
    if (currentState == null) {
      return;
    }

    state = AsyncData(
      VendorDataState(
        orders: currentState.orders,
        menuItems: currentState.menuItems
            .map(
              (item) => item.restaurantId == updatedRestaurant.id
                  ? VendorMenuItem(
                      restaurantId: item.restaurantId,
                      restaurantTitle: updatedRestaurant.title,
                      categoryId: item.categoryId,
                      id: item.id,
                      title: item.title,
                      description: item.description,
                      category: item.category,
                      ingredients: item.ingredients,
                      price: item.price,
                      image: item.image,
                      isAvailable: item.isAvailable,
                      optionGroups: item.optionGroups,
                    )
                  : item,
            )
            .toList(growable: false),
        restaurants: currentState.restaurants
            .map(
              (restaurant) => restaurant.id == updatedRestaurant.id
                  ? updatedRestaurant
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
                description: restaurant.description,
                address: restaurant.address,
                coverImage: restaurant.coverImage,
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

  Future<String> uploadRestaurantCover({
    required Uint8List bytes,
    required String filename,
    String? contentType,
  }) async {
    final token = ref.read(sessionControllerProvider).snapshot.backendToken;
    if (token == null || token.isEmpty) {
      throw StateError('Vendor session is required');
    }

    return _repository.uploadRestaurantCover(
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

  Future<void> updateRestaurant({
    required String restaurantId,
    required String title,
    required String description,
    required String address,
    required String coverImage,
  }) async {
    final token = ref.read(sessionControllerProvider).snapshot.backendToken;
    if (token == null || token.isEmpty) {
      throw StateError('Vendor session is required');
    }

    final updatedRestaurant = await _repository.updateRestaurant(
      token: token,
      restaurantId: restaurantId,
      title: title,
      description: description,
      address: address,
      coverImage: coverImage,
    );

    final currentState = state.valueOrNull;
    if (currentState == null) {
      await refresh();
      return;
    }

    _replaceRestaurant(updatedRestaurant);
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
    required this.restaurantRecommendations,
  });

  final int activeOrders;
  final int completedOrders;
  final double totalRevenue;
  final double averageOrderValue;
  final List<VendorTopItem> topItems;
  final List<VendorRestaurantRecommendation> restaurantRecommendations;
}

class VendorRestaurantRecommendation {
  const VendorRestaurantRecommendation({
    required this.restaurantId,
    required this.restaurantTitle,
    required this.hasEnoughHistory,
    this.peakHour,
    this.peakHourLabel,
    this.peakHourOrderCount = 0,
    this.peakHourTopItems = const [],
    required this.recommendationTitle,
    required this.recommendationMessage,
  });

  final String restaurantId;
  final String restaurantTitle;
  final int? peakHour;
  final String? peakHourLabel;
  final int peakHourOrderCount;
  final List<String> peakHourTopItems;
  final bool hasEnoughHistory;
  final String recommendationTitle;
  final String recommendationMessage;
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

VendorInsightsSummary summarizeVendorInsights(
  List<VendorOrder> orders,
  List<VendorRestaurant> restaurants,
) {
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

  final restaurantRecommendations = summarizeRestaurantRecommendations(
    orders,
    restaurants,
  );

  return VendorInsightsSummary(
    activeOrders: activeOrders,
    completedOrders: completedOrders.length,
    totalRevenue: totalRevenue,
    averageOrderValue: averageOrderValue,
    topItems: topItems.take(4).toList(growable: false),
    restaurantRecommendations: restaurantRecommendations,
  );
}

List<VendorRestaurantRecommendation> summarizeRestaurantRecommendations(
  List<VendorOrder> orders,
  List<VendorRestaurant> restaurants,
) {
  final now = DateTime.now();
  final cutoff = now.subtract(const Duration(days: 30));
  const minimumOrders = 5;

  return restaurants
      .map((restaurant) {
        final recentOrders = orders
            .where((order) {
              return order.restaurantId == restaurant.id &&
                  (order.status == VendorOrderStatus.ready ||
                      order.status == VendorOrderStatus.completed) &&
                  order.dateTime.isAfter(cutoff);
            })
            .toList(growable: false);

        if (recentOrders.length < minimumOrders) {
          return VendorRestaurantRecommendation(
            restaurantId: restaurant.id,
            restaurantTitle: restaurant.title,
            hasEnoughHistory: false,
            recommendationTitle: 'Not enough recent order history yet',
            recommendationMessage:
                'We need a few more recent orders before we can predict this restaurant\'s rush hour.',
          );
        }

        final orderCountByHour = <int, int>{};
        for (final order in recentOrders) {
          orderCountByHour.update(
            order.dateTime.hour,
            (count) => count + 1,
            ifAbsent: () => 1,
          );
        }

        final peakHourEntry = orderCountByHour.entries.reduce(
          (best, current) => current.value > best.value ? current : best,
        );
        final peakHourOrders = recentOrders
            .where((order) => order.dateTime.hour == peakHourEntry.key)
            .toList(growable: false);

        final topItemsByHour = <String, int>{};
        for (final order in peakHourOrders) {
          for (final item in order.items) {
            topItemsByHour.update(
              item.name,
              (count) => count + item.quantity,
              ifAbsent: () => item.quantity,
            );
          }
        }

        final topItems = topItemsByHour.entries.toList(growable: false)
          ..sort((a, b) => b.value.compareTo(a.value));

        final peakHourStart = DateTime(2026, 1, 1, peakHourEntry.key);
        final peakHourEnd = peakHourStart.add(const Duration(hours: 1));
        final prepReminder = peakHourStart.subtract(
          const Duration(minutes: 15),
        );
        final peakHourLabel =
            '${formatInsightHour(peakHourStart)} - ${formatInsightHour(peakHourEnd)}';
        final topItemNames = topItems
            .take(3)
            .map((entry) => entry.key)
            .toList(growable: false);

        return VendorRestaurantRecommendation(
          restaurantId: restaurant.id,
          restaurantTitle: restaurant.title,
          hasEnoughHistory: true,
          peakHour: peakHourEntry.key,
          peakHourLabel: peakHourLabel,
          peakHourOrderCount: peakHourEntry.value,
          peakHourTopItems: topItemNames,
          recommendationTitle: 'Expected rush: $peakHourLabel',
          recommendationMessage:
              'Prepare extra stock before ${formatInsightHour(prepReminder)}. Most ordered in this window: ${topItemNames.join(', ')}.',
        );
      })
      .toList(growable: false);
}

String formatInsightHour(DateTime dateTime) {
  final hour = dateTime.hour;
  final suffix = hour >= 12 ? 'PM' : 'AM';
  final normalizedHour = hour % 12 == 0 ? 12 : hour % 12;
  return '$normalizedHour $suffix';
}

final vendorInsightsProvider = Provider<AsyncValue<VendorInsightsSummary>>((
  ref,
) {
  final state = ref.watch(vendorDataControllerProvider);
  return state.whenData(
    (value) => summarizeVendorInsights(value.orders, value.restaurants),
  );
});
