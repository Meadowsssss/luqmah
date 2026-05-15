import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../models/restaurant.dart';

abstract class RestaurantRepository {
  Future<List<Restaurant>> fetchRestaurants();
  Future<Restaurant?> fetchRestaurantById(String id);
  Restaurant? getRestaurantById(String id);
  MenuItem? getMenuItemById(String id);
  Restaurant? findRestaurantForMenuItem(String itemId);
}

class ApiRestaurantRepository implements RestaurantRepository {
  ApiRestaurantRepository(this._apiClient);

  final ApiClient _apiClient;
  final Map<String, Restaurant> _restaurants = <String, Restaurant>{};
  final Map<String, String> _itemRestaurantIds = <String, String>{};

  @override
  Future<Restaurant?> fetchRestaurantById(String id) async {
    final response = await _apiClient.get('/restaurants/$id/menu');
    final restaurantJson = response['restaurant'] as Map<String, dynamic>;
    final categories = (response['categories'] as List<dynamic>? ?? const []);

    final menu = <MenuItem>[];
    final tags = <String>[];
    for (final category in categories) {
      final categoryJson = category as Map<String, dynamic>;
      tags.add(categoryJson['title'] as String);
      for (final item
          in (categoryJson['menuItems'] as List<dynamic>? ?? const [])) {
        final mapped = _menuItemFromJson(
          item as Map<String, dynamic>,
          categoryJson['title'] as String,
        );
        menu.add(mapped);
        _itemRestaurantIds[mapped.id] = id;
      }
    }

    final nextRestaurant = Restaurant(
      id: restaurantJson['id'] as String,
      name: restaurantJson['title'] as String,
      description:
          restaurantJson['description'] as String? ??
          'Freshly managed on Luqmah.',
      image: restaurantJson['coverImage'] as String? ?? '',
      rating: _ratingLabel(restaurantJson),
      averageRating: (restaurantJson['averageRating'] as num?)?.toDouble(),
      ratingCount: (restaurantJson['ratingCount'] as num?)?.toInt() ?? 0,
      time: 'See menu',
      isBusy: restaurantJson['isBusy'] as bool? ?? false,
      tags: tags.isEmpty ? <String>['Open now'] : tags,
      menu: menu,
    );

    _restaurants[id] = nextRestaurant;
    return nextRestaurant;
  }

  @override
  Future<List<Restaurant>> fetchRestaurants() async {
    final response = await _apiClient.get('/restaurants');
    final restaurants =
        ((response['restaurants'] as List<dynamic>?) ?? const [])
            .map(
              (json) =>
                  _restaurantSummaryFromJson(json as Map<String, dynamic>),
            )
            .toList(growable: false);

    for (final restaurant in restaurants) {
      _restaurants[restaurant.id] = restaurant;
    }

    return restaurants;
  }

  @override
  Restaurant? getRestaurantById(String id) => _restaurants[id];

  void cacheRestaurant(Restaurant restaurant) {
    _restaurants[restaurant.id] = restaurant;
  }

  void patchRestaurantBusyState(String id, bool isBusy) {
    final restaurant = _restaurants[id];
    if (restaurant == null) {
      return;
    }

    _restaurants[id] = restaurant.copyWith(isBusy: isBusy);
  }

  @override
  MenuItem? getMenuItemById(String id) {
    for (final restaurant in _restaurants.values) {
      for (final item in restaurant.menu) {
        if (item.id == id) {
          return item;
        }
      }
    }
    return null;
  }

  @override
  Restaurant? findRestaurantForMenuItem(String itemId) {
    final restaurantId = _itemRestaurantIds[itemId];
    if (restaurantId != null) {
      return _restaurants[restaurantId];
    }
    for (final restaurant in _restaurants.values) {
      for (final item in restaurant.menu) {
        if (item.id == itemId) {
          return restaurant;
        }
      }
    }
    return null;
  }

  Restaurant _restaurantSummaryFromJson(Map<String, dynamic> json) {
    final tags = <String>[];
    final vendor = json['vendor'] as Map<String, dynamic>?;
    final vendorName =
        (vendor?['user'] as Map<String, dynamic>?)?['name'] as String?;
    final menuCount = (json['_count'] as Map<String, dynamic>?)?['menuItems'];
    if (vendorName != null && vendorName.isNotEmpty) {
      tags.add(vendorName);
    }
    if (menuCount != null) {
      tags.add('$menuCount items');
    }

    return Restaurant(
      id: json['id'] as String,
      name: json['title'] as String,
      description:
          json['description'] as String? ?? 'Freshly managed on Luqmah.',
      image: json['coverImage'] as String? ?? '',
      rating: _ratingLabel(json),
      averageRating: (json['averageRating'] as num?)?.toDouble(),
      ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 0,
      time: (json['address'] as String?) ?? 'Campus pickup',
      isBusy: json['isBusy'] as bool? ?? false,
      tags: tags.isEmpty ? <String>['Open now'] : tags,
      menu: const [],
    );
  }

  MenuItem _menuItemFromJson(Map<String, dynamic> json, String categoryTitle) {
    final optionGroups =
        ((json['optionGroups'] as List<dynamic>?) ?? const []).map((group) {
          final groupJson = group as Map<String, dynamic>;
          return MenuItemOptionGroup(
            id: groupJson['id'] as String,
            title: groupJson['title'] as String,
            selectionType: (groupJson['selectionType'] as String) == 'SINGLE'
                ? MenuItemOptionSelectionType.single
                : MenuItemOptionSelectionType.multiple,
            isRequired: groupJson['isRequired'] as bool? ?? false,
            options: ((groupJson['options'] as List<dynamic>?) ?? const [])
                .map((option) {
                  final optionJson = option as Map<String, dynamic>;
                  return MenuItemOption(
                    id: optionJson['id'] as String,
                    title: optionJson['title'] as String,
                    priceDelta: (optionJson['priceDelta'] as num).toDouble(),
                  );
                })
                .toList(growable: false),
          );
        }).toList(growable: false);

    return MenuItem(
      id: json['id'] as String,
      name: json['title'] as String,
      description:
          json['description'] as String? ?? 'Prepared fresh for this menu.',
      price: (json['price'] as num).toDouble(),
      image: json['imageUrl'] as String? ?? '',
      category: categoryTitle,
      optionGroups: optionGroups,
    );
  }

  String _ratingLabel(Map<String, dynamic> json) {
    final average = (json['averageRating'] as num?)?.toDouble();
    final count = (json['ratingCount'] as num?)?.toInt() ?? 0;
    if (average == null || count == 0) {
      return 'New';
    }
    return average.toStringAsFixed(1);
  }
}

final restaurantRepositoryProvider = Provider<RestaurantRepository>((ref) {
  return ApiRestaurantRepository(ref.watch(apiClientProvider));
});

final restaurantsProvider = AsyncNotifierProvider<RestaurantsController, List<Restaurant>>(
  RestaurantsController.new,
);

class RestaurantsController extends AsyncNotifier<List<Restaurant>> {
  RestaurantRepository get _repository => ref.read(restaurantRepositoryProvider);

  @override
  Future<List<Restaurant>> build() {
    return _repository.fetchRestaurants();
  }

  Future<void> refreshSilently() async {
    final previous = state.valueOrNull;
    final next = await AsyncValue.guard(build);
    if (previous != null && next.hasError) {
      return;
    }
    state = next;
  }

  void patchBusyState(String restaurantId, bool isBusy) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    state = AsyncData(
      current
          .map((restaurant) => restaurant.id == restaurantId
              ? restaurant.copyWith(isBusy: isBusy)
              : restaurant)
          .toList(growable: false),
    );

    final repository = _repository;
    if (repository is ApiRestaurantRepository) {
      repository.patchRestaurantBusyState(restaurantId, isBusy);
    }
  }
}

final restaurantByIdProvider = AsyncNotifierProvider.autoDispose
    .family<RestaurantDetailController, Restaurant?, String>(
      RestaurantDetailController.new,
    );

class RestaurantDetailController extends AutoDisposeFamilyAsyncNotifier<Restaurant?, String> {
  RestaurantRepository get _repository => ref.read(restaurantRepositoryProvider);

  @override
  Future<Restaurant?> build(String id) {
    return _repository.fetchRestaurantById(id);
  }

  Future<void> refreshSilently() async {
    final previous = state.valueOrNull;
    final next = await AsyncValue.guard(() => build(arg));
    if (previous != null && next.hasError) {
      return;
    }
    state = next;
  }

  void patchBusyState(bool isBusy) {
    final restaurant = state.valueOrNull;
    if (restaurant == null) {
      return;
    }

    final nextRestaurant = restaurant.copyWith(isBusy: isBusy);
    state = AsyncData(nextRestaurant);

    final repository = _repository;
    if (repository is ApiRestaurantRepository) {
      repository.cacheRestaurant(nextRestaurant);
    }
  }
}

final menuItemByIdProvider = Provider.family<MenuItem?, String>((ref, id) {
  return ref.watch(restaurantRepositoryProvider).getMenuItemById(id);
});
