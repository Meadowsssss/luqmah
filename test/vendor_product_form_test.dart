import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luqmah/app/theme/luqmah_theme.dart';
import 'package:luqmah/features/vendor/presentation/vendor_product_form_page.dart';
import 'package:luqmah/features/vendor/vendor_data_controller.dart';
import 'package:luqmah/models/vendor.dart';

class _FakeVendorDataController extends VendorDataController {
  static final addCalls = <Map<String, Object?>>[];
  static final editCalls = <Map<String, Object?>>[];

  @override
  Future<VendorDataState> build() async {
    return const VendorDataState(
      orders: [],
      menuItems: [
        VendorMenuItem(
          restaurantId: 'rest_1',
          restaurantTitle: 'Blockna Express',
          categoryId: 'cat_2',
          id: 'item_1',
          title: 'Iced Latte',
          description: 'Cold coffee',
          category: 'Drinks',
          ingredients: ['Milk', 'Espresso'],
          price: 2.75,
          image: 'https://example.com/latte.png',
          isAvailable: true,
          customizations: [
            VendorMenuItemCustomization(title: 'Extra shot', priceDelta: 0.50),
          ],
        ),
      ],
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
    addCalls.add({
      'restaurantId': restaurantId,
      'categoryId': categoryId,
      'newCategoryTitle': newCategoryTitle,
      'title': title,
    });
  }

  @override
  Future<void> editMenuItem({
    required String itemId,
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
    editCalls.add({
      'itemId': itemId,
      'restaurantId': restaurantId,
      'categoryId': categoryId,
      'newCategoryTitle': newCategoryTitle,
      'title': title,
      'price': price,
    });
  }
}

void main() {
  setUp(() {
    _FakeVendorDataController.addCalls.clear();
    _FakeVendorDataController.editCalls.clear();
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

    expect(_FakeVendorDataController.addCalls, hasLength(1));
    expect(_FakeVendorDataController.addCalls.first['restaurantId'], 'rest_1');
    expect(_FakeVendorDataController.addCalls.first['categoryId'], isNull);
    expect(_FakeVendorDataController.addCalls.first['newCategoryTitle'], 'Signature Wraps');
    expect(_FakeVendorDataController.addCalls.first['title'], 'Falafel Wrap');
  });

  testWidgets('vendor edit form prefills the existing product and locks restaurant', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vendorDataControllerProvider.overrideWith(_FakeVendorDataController.new),
        ],
        child: MaterialApp(
          theme: buildLuqmahTheme(),
          home: const VendorProductFormPage(itemId: 'item_1'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Edit product'), findsOneWidget);
    expect(find.text('Blockna Express'), findsOneWidget);
    expect(find.text('Iced Latte'), findsOneWidget);
    expect(find.text('Cold coffee'), findsOneWidget);
  });

  test('vendor controller can edit a product in the same restaurant', () async {
    final container = ProviderContainer(
      overrides: [
        vendorDataControllerProvider.overrideWith(_FakeVendorDataController.new),
      ],
    );
    addTearDown(container.dispose);

    await container.read(vendorDataControllerProvider.future);
    final notifier = container.read(vendorDataControllerProvider.notifier);

    await notifier.editMenuItem(
      itemId: 'item_1',
      restaurantId: 'rest_1',
      categoryId: 'cat_2',
      newCategoryTitle: null,
      title: 'Iced Latte XL',
      description: 'Cold coffee',
      price: 3.25,
      imageUrl: '',
      ingredientNames: const ['Milk', 'Espresso'],
      customizations: const [],
    );

    expect(_FakeVendorDataController.editCalls, hasLength(1));
    expect(_FakeVendorDataController.editCalls.first['itemId'], 'item_1');
    expect(_FakeVendorDataController.editCalls.first['restaurantId'], 'rest_1');
    expect(_FakeVendorDataController.editCalls.first['categoryId'], 'cat_2');
    expect(_FakeVendorDataController.editCalls.first['title'], 'Iced Latte XL');
    expect(_FakeVendorDataController.editCalls.first['price'], 3.25);
  });
}
