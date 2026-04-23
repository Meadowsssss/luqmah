import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:luqmah/app/theme/luqmah_theme.dart';
import 'package:luqmah/features/customer/presentation/restaurants_page.dart';

void main() {
  testWidgets('restaurants screen shows hero copy', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: buildLuqmahTheme(),
          home: const RestaurantsPage(),
        ),
      ),
    );

    expect(find.text('Luqmah'), findsOneWidget);
    expect(find.text('Choose a restaurant'), findsOneWidget);
  });
}
