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
            {'id': 'rest_1', 'title': 'Campus Bites', 'isBusy': true, 'menuCategories': []},
          ],
        }),
        200,
      ),
      'GET /vendor/menu-items': http.Response(jsonEncode({'menuItems': []}), 200),
      'GET /vendor/orders?status=new': http.Response(jsonEncode({'orders': []}), 200),
      'GET /vendor/orders?status=past': http.Response(jsonEncode({'orders': []}), 200),
    });

    final repository = VendorRepository(ApiClient(client: client));
    final workspace = await repository.loadWorkspace('token');

    expect(workspace.restaurants.single.isBusy, isTrue);
  });

  test('vendor repository sends busy state updates', () async {
    final client = _FakeHttpClient({
      'PATCH /vendor/restaurants/busy': http.Response(
        jsonEncode({
          'restaurant': {'id': 'rest_1', 'title': 'Campus Bites', 'isBusy': true, 'menuCategories': []},
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
