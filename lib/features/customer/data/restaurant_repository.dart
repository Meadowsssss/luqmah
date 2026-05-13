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
    return MenuItem(
      id: json['id'] as String,
      name: json['title'] as String,
      description:
          json['description'] as String? ?? 'Prepared fresh for this menu.',
      price: (json['price'] as num).toDouble(),
      image: json['imageUrl'] as String? ?? '',
      category: categoryTitle,
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

final restaurantsProvider = FutureProvider<List<Restaurant>>((ref) {
  return ref.watch(restaurantRepositoryProvider).fetchRestaurants();
});

final restaurantByIdProvider = FutureProvider.autoDispose
    .family<Restaurant?, String>((ref, id) {
      return ref.watch(restaurantRepositoryProvider).fetchRestaurantById(id);
    });

final menuItemByIdProvider = Provider.family<MenuItem?, String>((ref, id) {
  return ref.watch(restaurantRepositoryProvider).getMenuItemById(id);
});
