import 'package:flutter_test/flutter_test.dart';
import 'package:luqmah/features/customer/orders/rating_prompt_selector.dart';
import 'package:luqmah/models/customer_order.dart';
import 'package:luqmah/models/vendor.dart';

void main() {
  test('selects only the latest completed unrated order', () {
    final oldCompleted = _order(
      id: 'old',
      status: VendorOrderStatus.completed,
      updatedAt: DateTime.utc(2026, 5, 1),
    );
    final latestCompleted = _order(
      id: 'latest',
      status: VendorOrderStatus.completed,
      updatedAt: DateTime.utc(2026, 5, 2),
    );

    final selected = latestCompletedOrderForRatingPrompt([
      oldCompleted,
      latestCompleted,
    ]);

    expect(selected?.id, 'latest');
  });

  test('does not fall back to older orders when latest completed is rated', () {
    final selected = latestCompletedOrderForRatingPrompt([
      _order(
        id: 'old',
        status: VendorOrderStatus.completed,
        updatedAt: DateTime.utc(2026, 5, 1),
      ),
      _order(
        id: 'latest-rated',
        status: VendorOrderStatus.completed,
        updatedAt: DateTime.utc(2026, 5, 2),
        ratingScore: 5,
      ),
    ]);

    expect(selected, isNull);
  });

  test(
    'does not fall back to older orders when latest completed is dismissed',
    () {
      final selected = latestCompletedOrderForRatingPrompt([
        _order(
          id: 'old',
          status: VendorOrderStatus.completed,
          updatedAt: DateTime.utc(2026, 5, 1),
        ),
        _order(
          id: 'latest-dismissed',
          status: VendorOrderStatus.completed,
          updatedAt: DateTime.utc(2026, 5, 2),
          ratingPromptDismissedAt: DateTime.utc(2026, 5, 3),
        ),
      ]);

      expect(selected, isNull);
    },
  );

  test('ignores active orders for auto prompt', () {
    final selected = latestCompletedOrderForRatingPrompt([
      _order(
        id: 'ready',
        status: VendorOrderStatus.ready,
        updatedAt: DateTime.utc(2026, 5, 3),
      ),
    ]);

    expect(selected, isNull);
  });
}

CustomerOrder _order({
  required String id,
  required VendorOrderStatus status,
  required DateTime updatedAt,
  int? ratingScore,
  DateTime? ratingPromptDismissedAt,
}) {
  return CustomerOrder(
    id: id,
    restaurantId: 'restaurant_1',
    restaurantName: 'Campus Bites',
    placedAt: DateTime.utc(2026, 5, 1),
    updatedAt: updatedAt,
    status: status,
    items: const <CustomerOrderItem>[],
    total: 5,
    ratingScore: ratingScore,
    ratingPromptDismissedAt: ratingPromptDismissedAt,
  );
}
