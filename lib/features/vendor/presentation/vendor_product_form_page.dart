import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/luqmah_theme.dart';
import '../../../features/vendor/vendor_data_controller.dart';
import '../../../models/vendor.dart';
import '../../../shared/widgets/app_surface_card.dart';

class VendorProductFormPage extends ConsumerStatefulWidget {
  const VendorProductFormPage({super.key});

  @override
  ConsumerState<VendorProductFormPage> createState() => _VendorProductFormPageState();
}

class _VendorProductFormPageState extends ConsumerState<VendorProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _priceController = TextEditingController();
  final _customizationsController = TextEditingController();
  String _type = 'Veg';
  String _category = 'Vegetarian';

  @override
  void dispose() {
    _titleController.dispose();
    _ingredientsController.dispose();
    _priceController.dispose();
    _customizationsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    ref.read(vendorDataControllerProvider.notifier).addMenuItem(
          VendorMenuItem(
            id: 'item_${DateTime.now().millisecondsSinceEpoch}',
            title: _titleController.text.trim(),
            type: _type,
            category: _category,
            ingredients: _ingredientsController.text
                .split(',')
                .map((value) => value.trim())
                .where((value) => value.isNotEmpty)
                .toList(growable: false),
            price: double.parse(_priceController.text.trim()),
            image: '',
            customizations: _customizationsController.text
                .split(',')
                .map((value) => value.trim())
                .where((value) => value.isNotEmpty)
                .toList(growable: false),
          ),
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vendor product added to the mock data.')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add product')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            AppSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Product details', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Food title'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Food title is required'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  DropdownButtonFormField<String>(
                    initialValue: _type,
                    items: const ['Veg', 'Non-Veg', 'Drink', 'Dessert']
                        .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                        .toList(growable: false),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _type = value);
                      }
                    },
                    decoration: const InputDecoration(labelText: 'Product type'),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  DropdownButtonFormField<String>(
                    initialValue: _category,
                    items: const ['Vegetarian', 'Beverage', 'Pizza', 'Burger', 'Dessert']
                        .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                        .toList(growable: false),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _category = value);
                      }
                    },
                    decoration: const InputDecoration(labelText: 'Category'),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _ingredientsController,
                    decoration: const InputDecoration(
                      labelText: 'Ingredients',
                      hintText: 'Tomato, mozzarella, basil',
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Ingredients are required'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Price in JD'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Price is required';
                      }
                      if (double.tryParse(value.trim()) == null) {
                        return 'Enter a valid price';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _customizationsController,
                    decoration: const InputDecoration(
                      labelText: 'Customizations',
                      hintText: 'Extra cheese, extra sauce',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(onPressed: _submit, child: const Text('Add product')),
          ],
        ),
      ),
    );
  }
}
