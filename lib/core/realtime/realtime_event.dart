class RealtimeEvent {
  const RealtimeEvent({required this.type, required this.payload});

  final String type;
  final Map<String, dynamic> payload;

  String? get restaurantId => payload['restaurantId'] as String?;
  String? get orderId => payload['orderId'] as String?;

  factory RealtimeEvent.fromJson(Map<String, dynamic> json) {
    return RealtimeEvent(type: json['type'] as String? ?? '', payload: json);
  }
}

class RealtimeEventTypes {
  const RealtimeEventTypes._();

  static const orderCreated = 'order.created';
  static const orderUpdated = 'order.updated';
  static const restaurantUpdated = 'restaurant.updated';
  static const menuUpdated = 'menu.updated';
  static const ratingCreated = 'rating.created';
  static const ready = 'realtime.ready';
}
