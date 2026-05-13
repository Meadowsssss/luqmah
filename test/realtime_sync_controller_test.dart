import 'package:flutter_test/flutter_test.dart';
import 'package:luqmah/core/realtime/realtime_event.dart';
import 'package:luqmah/core/realtime/realtime_sync_controller.dart';
import 'package:luqmah/features/session/session_models.dart';

void main() {
  test('customer order events refresh customer orders only', () {
    final actions = actionsForRealtimeEvent(
      AppRole.customer,
      const RealtimeEvent(
        type: RealtimeEventTypes.orderUpdated,
        payload: {'type': RealtimeEventTypes.orderUpdated, 'orderId': 'ord_1'},
      ),
    );

    expect(actions, {RealtimeSyncAction.refreshCustomerOrders});
  });

  test('vendor order events refresh vendor workspace only', () {
    final actions = actionsForRealtimeEvent(
      AppRole.vendor,
      const RealtimeEvent(
        type: RealtimeEventTypes.orderUpdated,
        payload: {'type': RealtimeEventTypes.orderUpdated, 'orderId': 'ord_1'},
      ),
    );

    expect(actions, {RealtimeSyncAction.refreshVendorData});
  });

  test('restaurant events refresh restaurant list and matching detail', () {
    final actions = actionsForRealtimeEvent(
      AppRole.customer,
      const RealtimeEvent(
        type: RealtimeEventTypes.restaurantUpdated,
        payload: {
          'type': RealtimeEventTypes.restaurantUpdated,
          'restaurantId': 'rest_1',
        },
      ),
    );

    expect(actions, {
      RealtimeSyncAction.refreshRestaurants,
      RealtimeSyncAction.refreshRestaurantDetail,
    });
  });

  test('rating events refresh customer orders and restaurant data', () {
    final actions = actionsForRealtimeEvent(
      AppRole.customer,
      const RealtimeEvent(
        type: RealtimeEventTypes.ratingCreated,
        payload: {
          'type': RealtimeEventTypes.ratingCreated,
          'restaurantId': 'rest_1',
        },
      ),
    );

    expect(actions, {
      RealtimeSyncAction.refreshCustomerOrders,
      RealtimeSyncAction.refreshRestaurants,
      RealtimeSyncAction.refreshRestaurantDetail,
    });
  });

  test('ready events do not refresh app state', () {
    final actions = actionsForRealtimeEvent(
      AppRole.customer,
      const RealtimeEvent(
        type: RealtimeEventTypes.ready,
        payload: {'type': RealtimeEventTypes.ready},
      ),
    );

    expect(actions, isEmpty);
  });
}
