import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  Future<void> addMenuItem({
    required String restaurantId,
    String? categoryId,
    String? newCategoryTitle,
    required String title,
    required String description,
    required double price,
    required String imageUrl,
    required List<String> ingredientNames,
    required List<Map<String, Object?>> customizations,
  }) async {
    final token = ref.read(sessionControllerProvider).snapshot.backendToken;
    if (token == null || token.isEmpty) {
      throw StateError('Vendor session is required');
    }

    var resolvedCategoryId = categoryId;
    final normalizedNewCategoryTitle = newCategoryTitle?.trim() ?? '';

    if (normalizedNewCategoryTitle.isNotEmpty) {
      final category = await _repository.createMenuCategory(
        token: token,
        restaurantId: restaurantId,
        title: normalizedNewCategoryTitle,
      );
      resolvedCategoryId = category.id;
    }

    if (resolvedCategoryId == null || resolvedCategoryId.isEmpty) {
      throw StateError('A category is required');
    }

    await _repository.createMenuItem(
      token: token,
      restaurantId: restaurantId,
      categoryId: resolvedCategoryId,
      title: title,
      description: description,
      price: price,
      imageUrl: imageUrl,
      ingredientNames: ingredientNames,
      customizations: customizations,
    );
    await refresh();
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
    required List<Map<String, Object?>> customizations,
  }) async {
    final token = ref.read(sessionControllerProvider).snapshot.backendToken;
    if (token == null || token.isEmpty) {
      throw StateError('Vendor session is required');
    }

    var resolvedCategoryId = categoryId;
    final normalizedNewCategoryTitle = newCategoryTitle?.trim() ?? '';

    if (normalizedNewCategoryTitle.isNotEmpty) {
      final category = await _repository.createMenuCategory(
        token: token,
        restaurantId: restaurantId,
        title: normalizedNewCategoryTitle,
      );
      resolvedCategoryId = category.id;
    }

    if (resolvedCategoryId == null || resolvedCategoryId.isEmpty) {
      throw StateError('A category is required');
    }

    await _repository.updateMenuItem(
      token: token,
      itemId: itemId,
      categoryId: resolvedCategoryId,
      title: title,
      description: description,
      price: price,
      imageUrl: imageUrl,
      ingredientNames: ingredientNames,
      customizations: customizations,
    );
    await refresh();
  }

  Future<void> toggleMenuItemAvailability(String itemId, bool isAvailable) async {
    final token = ref.read(sessionControllerProvider).snapshot.backendToken;
    if (token == null || token.isEmpty) {
      throw StateError('Vendor session is required');
    }

    await _repository.updateMenuItemAvailability(
      token: token,
      itemId: itemId,
      isAvailable: isAvailable,
    );
    await refresh();
  }

  Future<void> deleteMenuItem(String itemId) async {
    final token = ref.read(sessionControllerProvider).snapshot.backendToken;
    if (token == null || token.isEmpty) {
      throw StateError('Vendor session is required');
    }

    await _repository.deleteMenuItem(token: token, itemId: itemId);
    await refresh();
  }

  Future<void> updateOrderStatus(String orderId, VendorOrderStatus status) async {
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

  Future<void> updateRestaurantBusyState(String restaurantId, bool isBusy) async {
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
            .map((restaurant) => restaurant.id == restaurantId ? updatedRestaurant : restaurant)
            .toList(growable: false),
      ),
    );
  }
}

final vendorDataControllerProvider =
    AsyncNotifierProvider<VendorDataController, VendorDataState>(VendorDataController.new);

final vendorOrderByIdProvider = Provider.family<AsyncValue<VendorOrder?>, String>((ref, id) {
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
  final completedOrders = orders.where((order) => order.status.isPast).toList(growable: false);
  final activeOrders = orders.length - completedOrders.length;
  final revenueSource = completedOrders.isEmpty ? orders : completedOrders;
  final totalRevenue = revenueSource.fold<double>(0, (sum, order) => sum + order.total);
  final averageOrderValue = revenueSource.isEmpty ? 0.0 : totalRevenue / revenueSource.length;

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

final vendorInsightsProvider = Provider<AsyncValue<VendorInsightsSummary>>((ref) {
  final state = ref.watch(vendorDataControllerProvider);
  return state.whenData((value) => summarizeVendorInsights(value.orders));
});
