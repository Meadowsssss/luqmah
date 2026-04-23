import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/restaurants_data.dart';
import '../../../models/restaurant.dart';

abstract class RestaurantRepository {
  List<Restaurant> getRestaurants();
  Restaurant? getRestaurantById(String id);
  MenuItem? getMenuItemById(String id);
  Restaurant? findRestaurantForMenuItem(String itemId);
}

class LocalRestaurantRepository implements RestaurantRepository {
  @override
  Restaurant? getRestaurantById(String id) {
    for (final restaurant in restaurants) {
      if (restaurant.id == id) {
        return restaurant;
      }
    }
    return null;
  }

  @override
  List<Restaurant> getRestaurants() => restaurants;

  @override
  MenuItem? getMenuItemById(String id) {
    for (final restaurant in restaurants) {
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
    for (final restaurant in restaurants) {
      for (final item in restaurant.menu) {
        if (item.id == itemId) {
          return restaurant;
        }
      }
    }
    return null;
  }
}

final restaurantRepositoryProvider = Provider<RestaurantRepository>((ref) {
  return LocalRestaurantRepository();
});

final restaurantsProvider = Provider<List<Restaurant>>((ref) {
  return ref.watch(restaurantRepositoryProvider).getRestaurants();
});

final restaurantByIdProvider = Provider.family<Restaurant?, String>((ref, id) {
  return ref.watch(restaurantRepositoryProvider).getRestaurantById(id);
});

final menuItemByIdProvider = Provider.family<MenuItem?, String>((ref, id) {
  return ref.watch(restaurantRepositoryProvider).getMenuItemById(id);
});
