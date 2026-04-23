import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luqmah/features/vendor/vendor_data_controller.dart';

void main() {
  test('vendor insights summarizes orders and top items', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final insights = container.read(vendorInsightsProvider);

    expect(insights.activeOrders, greaterThan(0));
    expect(insights.totalRevenue, greaterThan(0));
    expect(insights.averageOrderValue, greaterThan(0));
    expect(insights.topItems, isNotEmpty);
    expect(insights.topItems.first.quantity, greaterThanOrEqualTo(1));
  });
}
