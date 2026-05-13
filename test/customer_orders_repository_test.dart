import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:luqmah/core/network/api_client.dart';
import 'package:luqmah/features/customer/orders/customer_orders_repository.dart';
import 'package:luqmah/models/vendor.dart';

void main() {
  test('customer order repository loads backend order history', () async {
    final client = _FakeHttpClient({
      'GET /orders/me': http.Response(
        jsonEncode({
          'orders': [
            {
              'id': 'ord_1',
              'status': 'ACCEPTED',
              'createdAt': '2026-04-23T12:00:00.000Z',
              'updatedAt': '2026-04-23T12:30:00.000Z',
              'totalAmount': 5.0,
              'ratingPromptDismissedAt': '2026-04-23T13:00:00.000Z',
              'restaurant': {'id': 'rest_1', 'title': 'Al-Salam Grill'},
              'rating': {'score': 4},
              'orderItems': [
                {
                  'menuItemId': 'item_1',
                  'itemTitle': 'Chicken Shawarma',
                  'quantity': 2,
                  'unitPrice': 2.5,
                },
              ],
            },
          ],
        }),
        200,
      ),
    });

    final repository = CustomerOrdersRepository(ApiClient(client: client));
    final orders = await repository.loadOrders('token');

    expect(orders, hasLength(1));
    expect(orders.first.id, 'ord_1');
    expect(orders.first.restaurantId, 'rest_1');
    expect(orders.first.restaurantName, 'Al-Salam Grill');
    expect(orders.first.updatedAt, DateTime.parse('2026-04-23T12:30:00.000Z'));
    expect(orders.first.status, VendorOrderStatus.accepted);
    expect(orders.first.ratingScore, 4);
    expect(orders.first.ratingPromptDismissedAt, isNotNull);
    expect(orders.first.items.single.name, 'Chicken Shawarma');
  });

  test(
    'customer order repository maps checkout payload to backend order',
    () async {
      final client = _FakeHttpClient({
        'POST /orders': http.Response(
          jsonEncode({
            'order': {
              'id': 'ord_2',
              'status': 'ACCEPTED',
              'createdAt': '2026-04-23T13:00:00.000Z',
              'totalAmount': 7.0,
              'restaurant': {'id': 'campus_burger', 'title': 'Campus Burger'},
              'rating': null,
              'orderItems': [
                {
                  'menuItemId': 'burger_1',
                  'itemTitle': 'Classic Burger',
                  'quantity': 2,
                  'unitPrice': 3.5,
                },
              ],
            },
          }),
          201,
        ),
      });

      final repository = CustomerOrdersRepository(ApiClient(client: client));
      final order = await repository.createOrder(
        token: 'token',
        restaurantId: 'campus_burger',
        items: const [
          CustomerCheckoutItemInput(menuItemId: 'burger_1', quantity: 2),
        ],
      );

      expect(client.lastRequestBody?['restaurantId'], 'campus_burger');
      expect(
        (client.lastRequestBody?['items'] as List<dynamic>)
            .single['menuItemId'],
        'burger_1',
      );
      expect(order.restaurantName, 'Campus Burger');
      expect(order.total, 7.0);
    },
  );

  test('customer order repository submits and dismisses ratings', () async {
    final client = _FakeHttpClient({
      'POST /orders/ord_1/rating': http.Response(
        jsonEncode({
          'rating': {'score': 5},
        }),
        201,
      ),
      'POST /orders/ord_1/rating-dismiss': http.Response(
        jsonEncode({'order': {}}),
        200,
      ),
    });

    final repository = CustomerOrdersRepository(ApiClient(client: client));

    await repository.rateOrder(token: 'token', orderId: 'ord_1', score: 5);
    expect(client.lastRequestBody?['score'], 5);

    await repository.dismissRatingPrompt(token: 'token', orderId: 'ord_1');
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
