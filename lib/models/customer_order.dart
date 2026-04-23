import 'vendor.dart';

class CustomerOrderItem {
  const CustomerOrderItem({
    required this.itemId,
    required this.name,
    required this.quantity,
    required this.price,
  });

  final String itemId;
  final String name;
  final int quantity;
  final double price;

  double get lineTotal => quantity * price;

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'name': name,
      'quantity': quantity,
      'price': price,
    };
  }

  factory CustomerOrderItem.fromJson(Map<String, dynamic> json) {
    return CustomerOrderItem(
      itemId: json['itemId'] as String,
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toInt(),
      price: (json['price'] as num).toDouble(),
    );
  }
}

class CustomerOrder {
  const CustomerOrder({
    required this.id,
    required this.restaurantName,
    required this.placedAt,
    required this.status,
    required this.items,
    required this.total,
  });

  final String id;
  final String restaurantName;
  final DateTime placedAt;
  final VendorOrderStatus status;
  final List<CustomerOrderItem> items;
  final double total;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurantName': restaurantName,
      'placedAt': placedAt.toIso8601String(),
      'status': status.name,
      'items': items.map((item) => item.toJson()).toList(growable: false),
      'total': total,
    };
  }

  factory CustomerOrder.fromJson(Map<String, dynamic> json) {
    return CustomerOrder(
      id: json['id'] as String,
      restaurantName: json['restaurantName'] as String,
      placedAt: DateTime.parse(json['placedAt'] as String),
      status: VendorOrderStatus.values.byName(json['status'] as String),
      items: (json['items'] as List<dynamic>)
          .map((item) => CustomerOrderItem.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
      total: (json['total'] as num).toDouble(),
    );
  }
}
