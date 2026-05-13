enum VendorOrderStatus { accepted, inProgress, ready, completed, cancelled }

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
      case VendorOrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  bool get isPast => this == VendorOrderStatus.completed || this == VendorOrderStatus.cancelled;

  List<VendorOrderStatus> get allowedTransitions {
    switch (this) {
      case VendorOrderStatus.accepted:
        return const [VendorOrderStatus.inProgress, VendorOrderStatus.cancelled];
      case VendorOrderStatus.inProgress:
        return const [VendorOrderStatus.ready, VendorOrderStatus.cancelled];
      case VendorOrderStatus.ready:
        return const [VendorOrderStatus.completed, VendorOrderStatus.cancelled];
      case VendorOrderStatus.completed:
      case VendorOrderStatus.cancelled:
        return const [];
    }
  }

  String get apiValue {
    switch (this) {
      case VendorOrderStatus.accepted:
        return 'ACCEPTED';
      case VendorOrderStatus.inProgress:
        return 'IN_PROGRESS';
      case VendorOrderStatus.ready:
        return 'READY';
      case VendorOrderStatus.completed:
        return 'COMPLETED';
      case VendorOrderStatus.cancelled:
        return 'CANCELLED';
    }
  }
}

VendorOrderStatus vendorOrderStatusFromApi(String value) {
  switch (value) {
    case 'ACCEPTED':
      return VendorOrderStatus.accepted;
    case 'IN_PROGRESS':
      return VendorOrderStatus.inProgress;
    case 'READY':
      return VendorOrderStatus.ready;
    case 'COMPLETED':
      return VendorOrderStatus.completed;
    case 'CANCELLED':
      return VendorOrderStatus.cancelled;
    default:
      return VendorOrderStatus.accepted;
  }
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
  final String restaurantId;
  final String restaurantTitle;
  final String categoryId;
  final String id;
  final String title;
  final String description;
  final String category;
  final List<String> ingredients;
  final double price;
  final String image;
  final bool isAvailable;
  final List<VendorMenuItemCustomization> customizations;

  const VendorMenuItem({
    required this.restaurantId,
    required this.restaurantTitle,
    required this.categoryId,
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.ingredients,
    required this.price,
    required this.image,
    required this.isAvailable,
    this.customizations = const [],
  });
}

class VendorMenuItemCustomization {
  const VendorMenuItemCustomization({
    required this.title,
    required this.priceDelta,
  });

  final String title;
  final double priceDelta;

  String get label {
    if (priceDelta == 0) {
      return title;
    }

    return '$title:${priceDelta.toStringAsFixed(2)}';
  }
}

class VendorRestaurant {
  const VendorRestaurant({
    required this.id,
    required this.title,
    this.isBusy = false,
    required this.categories,
  });

  final String id;
  final String title;
  final bool isBusy;
  final List<VendorRestaurantCategory> categories;

  VendorRestaurant copyWith({bool? isBusy}) {
    return VendorRestaurant(
      id: id,
      title: title,
      isBusy: isBusy ?? this.isBusy,
      categories: categories,
    );
  }
}

class VendorRestaurantCategory {
  const VendorRestaurantCategory({required this.id, required this.title});

  final String id;
  final String title;
}
