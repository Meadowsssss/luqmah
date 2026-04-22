enum VendorOrderStatus { accepted, inProgress, ready, completed }

extension VendorOrderStatusLabel on VendorOrderStatus {
  String get label {
    switch (this) {
      case VendorOrderStatus.accepted:
        return 'Accepted';
      case VendorOrderStatus.inProgress:
        return 'In Progress';
      case VendorOrderStatus.ready:
        return 'Ready';
      case VendorOrderStatus.completed:
        return 'Completed';
    }
  }

  bool get isPast => this == VendorOrderStatus.completed;
}

class VendorOrderItem {
  final String name;
  final int quantity;
  final double price;
  final List<String> extras;

  const VendorOrderItem({
    required this.name,
    required this.quantity,
    required this.price,
    this.extras = const [],
  });

  double get lineTotal => quantity * price;
}

class VendorOrder {
  final String id;
  final String customerName;
  final String customerPhone;
  final DateTime dateTime;
  final String paymentMethod;
  final VendorOrderStatus status;
  final List<VendorOrderItem> items;
  final double subtotal;
  final double coupon;
  final double total;

  const VendorOrder({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.dateTime,
    required this.paymentMethod,
    required this.status,
    required this.items,
    required this.subtotal,
    required this.coupon,
    required this.total,
  });

  VendorOrder copyWith({VendorOrderStatus? status}) {
    return VendorOrder(
      id: id,
      customerName: customerName,
      customerPhone: customerPhone,
      dateTime: dateTime,
      paymentMethod: paymentMethod,
      status: status ?? this.status,
      items: items,
      subtotal: subtotal,
      coupon: coupon,
      total: total,
    );
  }
}

class VendorMenuItem {
  final String id;
  final String title;
  final String type;
  final String category;
  final List<String> ingredients;
  final double price;
  final String image;
  final List<String> customizations;

  const VendorMenuItem({
    required this.id,
    required this.title,
    required this.type,
    required this.category,
    required this.ingredients,
    required this.price,
    required this.image,
    this.customizations = const [],
  });
}
