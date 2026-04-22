import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/pages/vendor/vendor_orders_page.dart';
import 'package:flutter_application_1/services/app_session_service.dart';

void main() {
  testWidgets('vendor home shows orders screen', (WidgetTester tester) async {
    AppSessionService.role.value = AppRole.vendor;

    await tester.pumpWidget(const MaterialApp(home: VendorOrdersPage()));

    expect(find.text('Orders'), findsWidgets);
    expect(find.text('New Orders'), findsOneWidget);
    expect(find.text('Past Orders'), findsOneWidget);
  });
}
