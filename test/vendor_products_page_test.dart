import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luqmah/app/theme/luqmah_theme.dart';
import 'package:luqmah/features/vendor/presentation/vendor_products_page.dart';
import 'package:luqmah/features/vendor/vendor_data_controller.dart';
import 'package:luqmah/models/vendor.dart';

class _FakeVendorProductsController extends VendorDataController {
  @override
  Future<VendorDataState> build() async {
    return const VendorDataState(
      orders: [],
      restaurants: [],
      menuItems: [
        VendorMenuItem(
          restaurantId: 'rest_1',
          restaurantTitle: 'Cafe',
          categoryId: 'cat_donuts',
          id: 'item_1',
          title: 'Chocolate Donut',
          description: 'Sweet',
          category: 'Donuts',
          ingredients: [],
          price: 1.5,
          image: '',
          isAvailable: true,
        ),
        VendorMenuItem(
          restaurantId: 'rest_1',
          restaurantTitle: 'Cafe',
          categoryId: 'cat_coffee',
          id: 'item_2',
          title: 'Latte',
          description: 'Coffee',
          category: 'Coffee',
          ingredients: [],
          price: 2.0,
          image: '',
          isAvailable: true,
        ),
      ],
    );
  }
}

void main() {
  testWidgets('vendor products page filters items by category chip', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vendorDataControllerProvider.overrideWith(_FakeVendorProductsController.new),
        ],
        child: MaterialApp(
          theme: buildLuqmahTheme(),
          home: const VendorProductsPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Chocolate Donut'), findsOneWidget);
    expect(find.text('Latte'), findsOneWidget);

    await tester.tap(find.text('Donuts'));
    await tester.pumpAndSettle();

    expect(find.text('Chocolate Donut'), findsOneWidget);
    expect(find.text('Latte'), findsNothing);
  });
}
