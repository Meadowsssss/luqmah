import '../../../models/customer_order.dart';
import '../../../models/vendor.dart';

CustomerOrder? latestCompletedOrderForRatingPrompt(List<CustomerOrder> orders) {
  final completed =
      orders
          .where((order) => order.status == VendorOrderStatus.completed)
          .toList(growable: false)
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  if (completed.isEmpty) {
    return null;
  }

  final latest = completed.first;
  return latest.needsRatingPrompt ? latest : null;
}
