import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(ref.watch(apiClientProvider));
});

class AdminVendorRecord {
  const AdminVendorRecord({
    required this.id,
    required this.name,
    required this.email,
    required this.restaurants,
  });

  final String id;
  final String name;
  final String email;
  final List<AdminRestaurantRecord> restaurants;
}

class AdminRestaurantRecord {
  const AdminRestaurantRecord({
    required this.id,
    required this.title,
    required this.categories,
  });

  final String id;
  final String title;
  final List<String> categories;
}

class AdminRepository {
  const AdminRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<AdminVendorRecord>> loadVendors(String token) async {
    final response = await _apiClient.get('/admin/vendors', token: token);
    return ((response['vendors'] as List<dynamic>?) ?? const [])
        .map((json) => _vendorFromJson(json as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<void> createVendor({
    required String token,
    required String name,
    required String email,
    required String password,
    required String restaurantTitle,
    required String restaurantDescription,
    required String restaurantAddress,
    required String coverImage,
    required List<String> categories,
  }) async {
    await _apiClient.post(
      '/admin/vendors',
      token: token,
      body: {
        'name': name,
        'email': email,
        'password': password,
        'restaurant': {
          'title': restaurantTitle,
          if (restaurantDescription.isNotEmpty) 'description': restaurantDescription,
          if (restaurantAddress.isNotEmpty) 'address': restaurantAddress,
          if (coverImage.isNotEmpty) 'coverImage': coverImage,
          'isActive': true,
        },
        'categories': categories
            .asMap()
            .entries
            .map((entry) => {'title': entry.value, 'sortOrder': entry.key})
            .toList(growable: false),
      },
    );
  }

  Future<String> deleteVendor({
    required String token,
    required String vendorId,
  }) async {
    final response = await _apiClient.delete('/admin/vendors/$vendorId', token: token);
    return response['message'] as String? ?? 'Vendor deleted successfully.';
  }

  AdminVendorRecord _vendorFromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    return AdminVendorRecord(
      id: json['id'] as String,
      name: user['name'] as String? ?? 'Vendor',
      email: user['email'] as String? ?? '',
      restaurants: ((json['restaurants'] as List<dynamic>?) ?? const [])
          .map((restaurant) {
            final restaurantJson = restaurant as Map<String, dynamic>;
            return AdminRestaurantRecord(
              id: restaurantJson['id'] as String,
              title: restaurantJson['title'] as String,
              categories: ((restaurantJson['menuCategories'] as List<dynamic>?) ?? const [])
                  .map((category) => (category as Map<String, dynamic>)['title'] as String)
                  .toList(growable: false),
            );
          })
          .toList(growable: false),
    );
  }
}
