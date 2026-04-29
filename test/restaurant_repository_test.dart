import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:luqmah/core/network/api_client.dart';
import 'package:luqmah/features/customer/data/restaurant_repository.dart';

void main() {
  test('restaurant repository maps all menu items across categories', () async {
    final client = _FakeHttpClient({
      'GET /restaurants/r1/menu': http.Response(
        jsonEncode({
          'restaurant': {
            'id': 'r1',
            'title': 'Drink Cut',
            'description': 'Coffee and dessert',
            'coverImage': '',
            'isBusy': false,
          },
          'categories': [
            {
              'title': 'Iced Coffee',
              'menuItems': [
                {
                  'id': 'm1',
                  'title': 'Iced Americano',
                  'description': 'Cold coffee',
                  'price': 1.5,
                  'imageUrl': '',
                },
                {
                  'id': 'm2',
                  'title': 'Iced Mocha',
                  'description': 'Chocolate coffee',
                  'price': 2.0,
                  'imageUrl': '',
                },
              ],
            },
            {
              'title': 'Desserts',
              'menuItems': [
                {
                  'id': 'm3',
                  'title': 'Cheesecake',
                  'description': 'Cake',
                  'price': 2.5,
                  'imageUrl': '',
                },
              ],
            },
          ],
        }),
        200,
      ),
    });

    final repository = ApiRestaurantRepository(ApiClient(client: client));
    final restaurant = await repository.fetchRestaurantById('r1');

    expect(restaurant, isNotNull);
    expect(restaurant!.menu, hasLength(3));
    expect(restaurant.menu.map((item) => item.name), containsAll(<String>[
      'Iced Americano',
      'Iced Mocha',
      'Cheesecake',
    ]));
  });
}

class _FakeHttpClient extends http.BaseClient {
  _FakeHttpClient(this._responses);

  final Map<String, http.Response> _responses;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final key = '${request.method} ${request.url.path}';
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
