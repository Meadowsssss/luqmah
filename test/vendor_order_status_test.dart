import 'package:flutter_test/flutter_test.dart';
import 'package:luqmah/models/vendor.dart';

void main() {
  test('vendor order statuses only expose valid next transitions', () {
    expect(
      VendorOrderStatus.accepted.allowedTransitions,
      [VendorOrderStatus.inProgress, VendorOrderStatus.cancelled],
    );
    expect(
      VendorOrderStatus.inProgress.allowedTransitions,
      [VendorOrderStatus.ready, VendorOrderStatus.cancelled],
    );
    expect(
      VendorOrderStatus.ready.allowedTransitions,
      [VendorOrderStatus.completed, VendorOrderStatus.cancelled],
    );
    expect(VendorOrderStatus.completed.allowedTransitions, isEmpty);
    expect(VendorOrderStatus.cancelled.allowedTransitions, isEmpty);
  });
}
