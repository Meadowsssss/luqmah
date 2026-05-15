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
    this.restaurantId = '',
    required this.restaurantName,
    required this.placedAt,
    DateTime? updatedAt,
    required this.status,
    required this.items,
    required this.total,
    this.ratingScore,
    this.ratingPromptDismissedAt,
  }) : updatedAt = updatedAt ?? placedAt;

  final String id;
  final String restaurantId;
  final String restaurantName;
  final DateTime placedAt;
  final DateTime updatedAt;
  final VendorOrderStatus status;
  final List<CustomerOrderItem> items;
  final double total;
  final int? ratingScore;
  final DateTime? ratingPromptDismissedAt;

  bool get hasRating => ratingScore != null;
  bool get canRate => status == VendorOrderStatus.completed && !hasRating;
  bool get needsRatingPrompt => canRate && ratingPromptDismissedAt == null;

  CustomerOrder copyWith({
    VendorOrderStatus? status,
    int? ratingScore,
    DateTime? ratingPromptDismissedAt,
  }) {
    return CustomerOrder(
      id: id,
      restaurantId: restaurantId,
      restaurantName: restaurantName,
      placedAt: placedAt,
      updatedAt: DateTime.now(),
      status: status ?? this.status,
      items: items,
      total: total,
      ratingScore: ratingScore ?? this.ratingScore,
      ratingPromptDismissedAt: ratingPromptDismissedAt ?? this.ratingPromptDismissedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'placedAt': placedAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'status': status.name,
      'items': items.map((item) => item.toJson()).toList(growable: false),
      'total': total,
      'ratingScore': ratingScore,
      'ratingPromptDismissedAt': ratingPromptDismissedAt?.toIso8601String(),
    };
  }

  factory CustomerOrder.fromJson(Map<String, dynamic> json) {
    return CustomerOrder(
      id: json['id'] as String,
      restaurantId: json['restaurantId'] as String? ?? '',
      restaurantName: json['restaurantName'] as String,
      placedAt: DateTime.parse(json['placedAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      status: VendorOrderStatus.values.byName(json['status'] as String),
      items: (json['items'] as List<dynamic>)
          .map(
            (item) => CustomerOrderItem.fromJson(item as Map<String, dynamic>),
          )
          .toList(growable: false),
      total: (json['total'] as num).toDouble(),
      ratingScore: (json['ratingScore'] as num?)?.toInt(),
      ratingPromptDismissedAt: json['ratingPromptDismissedAt'] == null
          ? null
          : DateTime.parse(json['ratingPromptDismissedAt'] as String),
    );
  }
}
