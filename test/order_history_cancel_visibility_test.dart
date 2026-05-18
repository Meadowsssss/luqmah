import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luqmah/app/theme/luqmah_theme.dart';
import 'package:luqmah/features/customer/orders/customer_orders_controller.dart';
import 'package:luqmah/features/customer/presentation/order_history_page.dart';
import 'package:luqmah/models/customer_order.dart';
import 'package:luqmah/models/vendor.dart';

class _FakeAcceptedOrdersController extends CustomerOrdersController {
  @override
  Future<List<CustomerOrder>> build() async {
    return [
      CustomerOrder(
        id: 'order_1',
        restaurantName: 'Campus Bites',
        placedAt: DateTime.parse('2026-05-18T12:00:00.000Z'),
        status: VendorOrderStatus.accepted,
        items: const [],
        total: 5,
      ),
    ];
  }
}

class _FakeReadyOrdersController extends CustomerOrdersController {
  @override
  Future<List<CustomerOrder>> build() async {
    return [
      CustomerOrder(
        id: 'order_1',
        restaurantName: 'Campus Bites',
        placedAt: DateTime.parse('2026-05-18T12:00:00.000Z'),
        status: VendorOrderStatus.ready,
        items: const [],
        total: 5,
      ),
    ];
  }
}

void main() {
  testWidgets('order history shows cancel button only for in queue orders', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          customerOrdersControllerProvider.overrideWith(
            _FakeAcceptedOrdersController.new,
          ),
        ],
        child: MaterialApp(
          theme: buildLuqmahTheme(),
          home: const OrderHistoryPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('In Queue'), findsOneWidget);
    expect(find.text('Cancel order'), findsOneWidget);
  });

  testWidgets('order history hides cancel button after accepted state', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          customerOrdersControllerProvider.overrideWith(
            _FakeReadyOrdersController.new,
          ),
        ],
        child: MaterialApp(
          theme: buildLuqmahTheme(),
          home: const OrderHistoryPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Ready'), findsWidgets);
    expect(find.text('Cancel order'), findsNothing);
  });
}
