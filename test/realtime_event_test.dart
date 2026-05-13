import 'package:flutter_test/flutter_test.dart';
import 'package:luqmah/core/realtime/realtime_event.dart';

void main() {
  test('RealtimeEvent maps payload fields', () {
    final event = RealtimeEvent.fromJson(const {
      'type': RealtimeEventTypes.orderUpdated,
      'orderId': 'order_1',
      'restaurantId': 'restaurant_1',
    });

    expect(event.type, RealtimeEventTypes.orderUpdated);
    expect(event.orderId, 'order_1');
    expect(event.restaurantId, 'restaurant_1');
  });
}
