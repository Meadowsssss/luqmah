import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:luqmah/core/network/api_client.dart';
import 'package:luqmah/features/vendor/vendor_repository.dart';

void main() {
  test('vendor repository loads busy restaurant state', () async {
    final client = _FakeHttpClient({
      'GET /vendor/restaurants/me': http.Response(
        jsonEncode({
          'restaurants': [
            {
              'id': 'rest_1',
              'title': 'Campus Bites',
              'isBusy': true,
              'menuCategories': [],
            },
          ],
        }),
        200,
      ),
      'GET /vendor/menu-items': http.Response(
        jsonEncode({'menuItems': []}),
        200,
      ),
      'GET /vendor/orders?status=new': http.Response(
        jsonEncode({'orders': []}),
        200,
      ),
      'GET /vendor/orders?status=past': http.Response(
        jsonEncode({'orders': []}),
        200,
      ),
    });

    final repository = VendorRepository(ApiClient(client: client));
    final workspace = await repository.loadWorkspace('token');

    expect(workspace.restaurants.single.isBusy, isTrue);
  });

  test('vendor repository sends busy state updates', () async {
    final client = _FakeHttpClient({
      'PATCH /vendor/restaurants/busy': http.Response(
        jsonEncode({
          'restaurant': {
            'id': 'rest_1',
            'title': 'Campus Bites',
            'isBusy': true,
            'menuCategories': [],
          },
        }),
        200,
      ),
    });

    final repository = VendorRepository(ApiClient(client: client));
    final restaurant = await repository.updateRestaurantBusyState(
      token: 'token',
      restaurantId: 'rest_1',
      isBusy: true,
    );

    expect(client.lastRequestBody?['restaurantId'], 'rest_1');
    expect(client.lastRequestBody?['isBusy'], isTrue);
    expect(restaurant.isBusy, isTrue);
  });

  test('vendor repository updates restaurant details', () async {
    final client = _FakeHttpClient({
      'PATCH /vendor/restaurants/rest_1': http.Response(
        jsonEncode({
          'restaurant': {
            'id': 'rest_1',
            'title': 'Campus Bites Plus',
            'description': 'Fresh plates',
            'address': 'Main Street',
            'coverImage': 'https://example.com/cover.jpg',
            'isBusy': false,
            'menuCategories': [],
          },
        }),
        200,
      ),
    });

    final repository = VendorRepository(ApiClient(client: client));
    final restaurant = await repository.updateRestaurant(
      token: 'token',
      restaurantId: 'rest_1',
      title: 'Campus Bites Plus',
      description: 'Fresh plates',
      address: 'Main Street',
      coverImage: 'https://example.com/cover.jpg',
    );

    expect(client.lastRequestBody?['title'], 'Campus Bites Plus');
    expect(client.lastRequestBody?['description'], 'Fresh plates');
    expect(restaurant.title, 'Campus Bites Plus');
    expect(restaurant.description, 'Fresh plates');
    expect(restaurant.address, 'Main Street');
    expect(restaurant.coverImage, 'https://example.com/cover.jpg');
  });

  test(
    'vendor repository maps estimated ready times for in-progress orders',
    () async {
      final client = _FakeHttpClient({
        'GET /vendor/restaurants/me': http.Response(
          jsonEncode({'restaurants': []}),
          200,
        ),
        'GET /vendor/menu-items': http.Response(
          jsonEncode({'menuItems': []}),
          200,
        ),
        'GET /vendor/orders?status=new': http.Response(
          jsonEncode({
            'orders': [
              {
                'id': 'order_1',
                'createdAt': '2026-05-16T12:00:00.000Z',
                'estimatedReadyAt': '2026-05-16T12:15:00.000Z',
                'status': 'IN_PROGRESS',
                'totalAmount': 5,
                'customer': {'name': 'Sara', 'email': 'sara@example.com'},
                'orderItems': [],
              },
            ],
          }),
          200,
        ),
        'GET /vendor/orders?status=past': http.Response(
          jsonEncode({'orders': []}),
          200,
        ),
      });

      final repository = VendorRepository(ApiClient(client: client));
      final workspace = await repository.loadWorkspace('token');

      expect(
        workspace.orders.single.estimatedReadyAt,
        DateTime.parse('2026-05-16T12:15:00.000Z'),
      );
    },
  );
}

class _FakeHttpClient extends http.BaseClient {
  _FakeHttpClient(this._responses);

  final Map<String, http.Response> _responses;
  Map<String, dynamic>? lastRequestBody;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final body = request is http.Request ? request.body : null;
    if (body != null && body.isNotEmpty) {
      lastRequestBody = jsonDecode(body) as Map<String, dynamic>;
    }

    final query = request.url.hasQuery ? '?${request.url.query}' : '';
    final key = '${request.method} ${request.url.path}$query';
    final response = _responses[key];
    if (response == null) {
      throw StateError('No fake response configured for $key');
    }

    return http.StreamedResponse(
      Stream.value(utf8.encode(response.body)),
      response.statusCode,
      headers: response.headers,
      request: request,
    );
  }
}
