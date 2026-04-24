import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luqmah/app/theme/luqmah_theme.dart';
import 'package:luqmah/features/vendor/presentation/vendor_product_form_page.dart';
import 'package:luqmah/features/vendor/vendor_data_controller.dart';
import 'package:luqmah/models/vendor.dart';

class _FakeVendorDataController extends VendorDataController {
  static final calls = <Map<String, Object?>>[];

  @override
  Future<VendorDataState> build() async {
    return const VendorDataState(
      orders: [],
      menuItems: [],
      restaurants: [
        VendorRestaurant(
          id: 'rest_1',
          title: 'Blockna Express',
          categories: [
            VendorRestaurantCategory(id: 'cat_1', title: 'Wraps'),
            VendorRestaurantCategory(id: 'cat_2', title: 'Drinks'),
          ],
        ),
      ],
    );
  }

  @override
  Future<void> addMenuItem({
    required String restaurantId,
    String? categoryId,
    String? newCategoryTitle,
    required String title,
    required String description,
    required double price,
    required String imageUrl,
    required List<String> ingredientNames,
    required List<Map<String, Object?>> customizations,
  }) async {
    calls.add({
      'restaurantId': restaurantId,
      'categoryId': categoryId,
      'newCategoryTitle': newCategoryTitle,
      'title': title,
    });
  }
}

void main() {
  setUp(() {
    _FakeVendorDataController.calls.clear();
  });

  testWidgets('vendor form shows existing category dropdown by default', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vendorDataControllerProvider.overrideWith(_FakeVendorDataController.new),
        ],
        child: MaterialApp(
          theme: buildLuqmahTheme(),
          home: const VendorProductFormPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Use existing'), findsOneWidget);
    expect(find.text('Create new'), findsOneWidget);
    expect(find.widgetWithText(DropdownButtonFormField<String>, 'Wraps'), findsOneWidget);
  });

  testWidgets('vendor form lets user type a new category and submits it', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vendorDataControllerProvider.overrideWith(_FakeVendorDataController.new),
        ],
        child: MaterialApp(
          theme: buildLuqmahTheme(),
          home: const VendorProductFormPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Create new'));
    await tester.pumpAndSettle();

    expect(find.text('New category name'), findsOneWidget);
  });

  test('vendor controller can create a product with a new category name', () async {
    final container = ProviderContainer(
      overrides: [
        vendorDataControllerProvider.overrideWith(_FakeVendorDataController.new),
      ],
    );
    addTearDown(container.dispose);

    await container.read(vendorDataControllerProvider.future);
    final notifier = container.read(vendorDataControllerProvider.notifier);

    await notifier.addMenuItem(
      restaurantId: 'rest_1',
      categoryId: null,
      newCategoryTitle: 'Signature Wraps',
      title: 'Falafel Wrap',
      description: 'Crispy falafel',
      price: 4.5,
      imageUrl: '',
      ingredientNames: const ['Falafel', 'Tahini'],
      customizations: const [],
    );

    expect(_FakeVendorDataController.calls, hasLength(1));
    expect(_FakeVendorDataController.calls.first['restaurantId'], 'rest_1');
    expect(_FakeVendorDataController.calls.first['categoryId'], isNull);
    expect(_FakeVendorDataController.calls.first['newCategoryTitle'], 'Signature Wraps');
    expect(_FakeVendorDataController.calls.first['title'], 'Falafel Wrap');
  });
}
