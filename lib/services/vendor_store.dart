import 'package:flutter/foundation.dart';

import '../data/vendor_mock_data.dart';
import '../models/vendor.dart';

class VendorStore {
  static final ValueNotifier<List<VendorOrder>> orders =
      ValueNotifier<List<VendorOrder>>(
        List<VendorOrder>.from(initialVendorOrders),
      );
  static final ValueNotifier<List<VendorMenuItem>> menuItems =
      ValueNotifier<List<VendorMenuItem>>(
        List<VendorMenuItem>.from(initialVendorMenuItems),
      );

  static VendorOrder? orderById(String id) {
    for (final order in orders.value) {
      if (order.id == id) return order;
    }
    return null;
  }

  static void updateOrderStatus(String orderId, VendorOrderStatus status) {
    orders.value = orders.value
        .map(
          (order) =>
              order.id == orderId ? order.copyWith(status: status) : order,
        )
        .toList(growable: false);
  }

  static void addMenuItem(VendorMenuItem item) {
    menuItems.value = <VendorMenuItem>[item, ...menuItems.value];
  }
}
