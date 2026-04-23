import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/vendor_mock_data.dart';
import '../customer/cart/cart_controller.dart';
import '../../models/vendor.dart';

class VendorDataState {
  const VendorDataState({required this.orders, required this.menuItems});

  final List<VendorOrder> orders;
  final List<VendorMenuItem> menuItems;
}

class VendorDataController extends Notifier<VendorDataState> {
  @override
  VendorDataState build() {
    return VendorDataState(
      orders: List<VendorOrder>.from(initialVendorOrders),
      menuItems: List<VendorMenuItem>.from(initialVendorMenuItems),
    );
  }

  void updateOrderStatus(String orderId, VendorOrderStatus status) {
    state = VendorDataState(
      orders: state.orders
          .map((order) => order.id == orderId ? order.copyWith(status: status) : order)
          .toList(growable: false),
      menuItems: state.menuItems,
    );
  }

  void addMenuItem(VendorMenuItem item) {
    state = VendorDataState(
      orders: state.orders,
      menuItems: <VendorMenuItem>[item, ...state.menuItems],
    );
  }

  void appendIncomingOrder({
    required String customerName,
    required String customerPhone,
    required String paymentMethod,
    required List<CartLine> lines,
    required double total,
  }) {
    final subtotal = lines.fold<double>(0, (sum, line) => sum + line.lineTotal);
    final nextOrder = VendorOrder(
      id: '#${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      customerName: customerName,
      customerPhone: customerPhone,
      dateTime: DateTime.now(),
      paymentMethod: paymentMethod,
      status: VendorOrderStatus.accepted,
      items: lines
          .map(
            (line) => VendorOrderItem(
              name: line.item.name,
              quantity: line.quantity,
              price: line.item.price,
            ),
          )
          .toList(growable: false),
      subtotal: subtotal,
      coupon: subtotal - total,
      total: total,
    );

    state = VendorDataState(
      orders: <VendorOrder>[nextOrder, ...state.orders],
      menuItems: state.menuItems,
    );
  }
}

final vendorDataControllerProvider =
    NotifierProvider<VendorDataController, VendorDataState>(
      VendorDataController.new,
    );

final vendorOrderByIdProvider = Provider.family<VendorOrder?, String>((ref, id) {
  for (final order in ref.watch(vendorDataControllerProvider).orders) {
    if (order.id == id) {
      return order;
    }
  }
  return null;
});

class VendorInsightsSummary {
  const VendorInsightsSummary({
    required this.activeOrders,
    required this.completedOrders,
    required this.totalRevenue,
    required this.averageOrderValue,
    required this.topItems,
  });

  final int activeOrders;
  final int completedOrders;
  final double totalRevenue;
  final double averageOrderValue;
  final List<VendorTopItem> topItems;
}

class VendorTopItem {
  const VendorTopItem({
    required this.name,
    required this.quantity,
    required this.revenue,
  });

  final String name;
  final int quantity;
  final double revenue;
}

final vendorInsightsProvider = Provider<VendorInsightsSummary>((ref) {
  final orders = ref.watch(vendorDataControllerProvider).orders;
  final completedOrders = orders.where((order) => order.status.isPast).toList(growable: false);
  final activeOrders = orders.length - completedOrders.length;
  final revenueSource = completedOrders.isEmpty ? orders : completedOrders;
  final totalRevenue = revenueSource.fold<double>(0, (sum, order) => sum + order.total);
  final averageOrderValue = revenueSource.isEmpty
      ? 0.0
      : totalRevenue / revenueSource.length;

  final totals = <String, VendorTopItem>{};
  for (final order in orders) {
    for (final item in order.items) {
      final existing = totals[item.name];
      totals[item.name] = VendorTopItem(
        name: item.name,
        quantity: (existing?.quantity ?? 0) + item.quantity,
        revenue: (existing?.revenue ?? 0) + item.lineTotal,
      );
    }
  }

  final topItems = totals.values.toList(growable: false)
    ..sort((a, b) => b.quantity.compareTo(a.quantity));

  return VendorInsightsSummary(
    activeOrders: activeOrders,
    completedOrders: completedOrders.length,
    totalRevenue: totalRevenue,
    averageOrderValue: averageOrderValue,
    topItems: topItems.take(4).toList(growable: false),
  );
});
