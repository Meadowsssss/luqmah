import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luqmah/app/theme/luqmah_theme.dart';
import 'package:luqmah/features/customer/orders/customer_orders_controller.dart';
import 'package:luqmah/features/customer/presentation/order_history_page.dart';
import 'package:luqmah/models/customer_order.dart';
import 'package:luqmah/models/vendor.dart';

class _FakeCustomerOrdersController extends CustomerOrdersController {
  @override
  Future<List<CustomerOrder>> build() async {
    return [
      CustomerOrder(
        id: 'order_1',
        restaurantName: 'Campus Cafe',
        placedAt: DateTime.parse('2026-05-16T12:00:00.000Z'),
        estimatedReadyAt: DateTime.parse('2026-05-16T12:15:00.000Z'),
        status: VendorOrderStatus.inProgress,
        items: const [],
        total: 5,
      ),
      CustomerOrder(
        id: 'order_2',
        restaurantName: 'Campus Cafe',
        placedAt: DateTime.parse('2026-05-16T10:00:00.000Z'),
        estimatedReadyAt: DateTime.parse('2026-05-16T10:15:00.000Z'),
        status: VendorOrderStatus.ready,
        items: const [],
        total: 6,
      ),
    ];
  }
}

void main() {
  testWidgets('order history shows ETA only for in-progress orders', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          customerOrdersControllerProvider.overrideWith(_FakeCustomerOrdersController.new),
        ],
        child: MaterialApp(
          theme: buildLuqmahTheme(),
          home: const OrderHistoryPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('Expected by'), findsOneWidget);
    expect(find.text('Ready'), findsWidgets);
  });
}
