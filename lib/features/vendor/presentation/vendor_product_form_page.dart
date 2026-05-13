import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/luqmah_theme.dart';
import '../../../features/vendor/vendor_data_controller.dart';
import '../../../models/vendor.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_surface_card.dart';

class VendorProductFormPage extends ConsumerStatefulWidget {
  const VendorProductFormPage({super.key, this.itemId});

  final String? itemId;

  bool get isEditMode => itemId != null;

  @override
  ConsumerState<VendorProductFormPage> createState() => _VendorProductFormPageState();
}

class _VendorProductFormPageState extends ConsumerState<VendorProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _titleController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _customizationsController = TextEditingController();
  final _newCategoryController = TextEditingController();

  String? _restaurantId;
  String? _categoryId;
  bool _creatingNewCategory = false;
  bool _submitting = false;
  bool _didInitializeForm = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _titleController.dispose();
    _ingredientsController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _customizationsController.dispose();
    _newCategoryController.dispose();
    super.dispose();
  }

  void _syncCreateSelectionState(List<VendorRestaurant> restaurants) {
    if (widget.isEditMode || restaurants.isEmpty) {
      return;
    }

    final fallbackRestaurantId = _restaurantId ?? restaurants.first.id;
    final selectedRestaurant = restaurants.firstWhere(
      (item) => item.id == fallbackRestaurantId,
      orElse: () => restaurants.first,
    );

    final categories = selectedRestaurant.categories;
    final nextCategoryId = categories.isEmpty
        ? null
        : categories.any((item) => item.id == _categoryId)
            ? _categoryId
            : categories.first.id;

    if (_restaurantId != selectedRestaurant.id || _categoryId != nextCategoryId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        setState(() {
          _restaurantId = selectedRestaurant.id;
          _categoryId = nextCategoryId;
        });
      });
    }
  }

  void _initializeEditForm(VendorMenuItem item) {
    if (_didInitializeForm) {
      return;
    }

    _didInitializeForm = true;
    _restaurantId = item.restaurantId;
    _categoryId = item.categoryId;
    _titleController.text = item.title;
    _descriptionController.text = item.description;
    _ingredientsController.text = item.ingredients.join(', ');
    _priceController.text = item.price.toStringAsFixed(2);
    _imageUrlController.text = item.image;
    _customizationsController.text = item.customizations
        .map((customization) => customization.label)
        .join(', ');
  }

  List<String> _parseCsv(TextEditingController controller) {
    return controller.text
        .split(',')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
  }

  List<Map<String, Object?>> _parseCustomizations() {
    return _customizationsController.text
        .split(',')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .map((value) {
          final parts = value.split(':');
          final title = parts.first.trim();
          final priceDelta = parts.length > 1 ? double.tryParse(parts.last.trim()) ?? 0 : 0;
          return <String, Object?>{'title': title, 'priceDelta': priceDelta};
        })
        .where((value) => (value['title'] as String).isNotEmpty)
        .toList(growable: false);
  }

  Future<void> _submit({required bool isEditMode, required VendorMenuItem? editingItem}) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_restaurantId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose a restaurant first.')),
      );
      return;
    }

    if (!_creatingNewCategory && _categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose an existing category or create a new one.')),
      );
      return;
    }

    if (isEditMode && editingItem == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This product could not be found.')),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      final notifier = ref.read(vendorDataControllerProvider.notifier);
      final categoryId = _creatingNewCategory ? null : _categoryId;
      final newCategoryTitle = _creatingNewCategory ? _newCategoryController.text.trim() : null;

      if (isEditMode) {
        await notifier.editMenuItem(
          itemId: editingItem!.id,
          restaurantId: _restaurantId!,
          categoryId: categoryId,
          newCategoryTitle: newCategoryTitle,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          imageUrl: _imageUrlController.text.trim(),
          ingredientNames: _parseCsv(_ingredientsController),
          customizations: _parseCustomizations(),
        );
      } else {
        await notifier.addMenuItem(
          restaurantId: _restaurantId!,
          categoryId: categoryId,
          newCategoryTitle: newCategoryTitle,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          imageUrl: _imageUrlController.text.trim(),
          ingredientNames: _parseCsv(_ingredientsController),
          customizations: _parseCustomizations(),
        );
      }

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditMode ? 'Product updated successfully.' : 'Product published successfully.',
          ),
        ),
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(vendorDataControllerProvider);
    final isEditMode = widget.isEditMode;
    final pageTitle = isEditMode ? 'Edit product' : 'Add product';

    return data.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: Text(pageTitle)),
        body: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text(error.toString()),
        ),
      ),
      data: (state) {
        final restaurants = state.restaurants;
        VendorMenuItem? editingItem;
        if (isEditMode) {
          for (final item in state.menuItems) {
            if (item.id == widget.itemId) {
              editingItem = item;
              break;
            }
          }
        }

        if (isEditMode && editingItem != null) {
          _initializeEditForm(editingItem);
        } else {
          _syncCreateSelectionState(restaurants);
        }

        if (restaurants.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: Text(pageTitle)),
            body: const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: AppEmptyState(
                icon: Icons.storefront_outlined,
                title: 'No restaurant setup yet',
                message: 'Ask an admin to create your restaurant and categories before publishing products.',
              ),
            ),
          );
        }

        if (isEditMode && editingItem == null) {
          return Scaffold(
            appBar: AppBar(title: Text(pageTitle)),
            body: const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: AppEmptyState(
                icon: Icons.inventory_2_outlined,
                title: 'Product not found',
                message: 'This menu item is no longer available to edit.',
              ),
            ),
          );
        }

        final currentRestaurantId = _restaurantId ?? restaurants.first.id;
        final selectedRestaurant = restaurants.firstWhere(
          (item) => item.id == currentRestaurantId,
          orElse: () => restaurants.first,
        );
        final categories = selectedRestaurant.categories;
        final activeCategoryId = categories.any((item) => item.id == _categoryId)
            ? _categoryId
            : (categories.isEmpty ? null : categories.first.id);

        return Scaffold(
          appBar: AppBar(title: Text(pageTitle)),
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
                      if (isEditMode)
                        TextFormField(
                          initialValue: selectedRestaurant.title,
                          decoration: const InputDecoration(labelText: 'Restaurant'),
                          readOnly: true,
                          enabled: false,
                        )
                      else
                        DropdownButtonFormField<String>(
                          key: ValueKey(currentRestaurantId),
                          initialValue: currentRestaurantId,
                          items: restaurants
                              .map((value) => DropdownMenuItem(value: value.id, child: Text(value.title)))
                              .toList(growable: false),
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }
                            setState(() {
                              _restaurantId = value;
                              final nextRestaurant = restaurants.firstWhere((item) => item.id == value);
                              _categoryId = nextRestaurant.categories.isEmpty ? null : nextRestaurant.categories.first.id;
                              _creatingNewCategory = false;
                              _newCategoryController.clear();
                            });
                          },
                          decoration: const InputDecoration(labelText: 'Restaurant'),
                        ),
                      const SizedBox(height: AppSpacing.lg),
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment<bool>(value: false, label: Text('Use existing')),
                          ButtonSegment<bool>(value: true, label: Text('Create new')),
                        ],
                        selected: <bool>{_creatingNewCategory},
                        onSelectionChanged: (selection) {
                          setState(() {
                            _creatingNewCategory = selection.first;
                            if (!_creatingNewCategory) {
                              _newCategoryController.clear();
                            }
                          });
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      if (_creatingNewCategory)
                        TextFormField(
                          controller: _newCategoryController,
                          decoration: const InputDecoration(
                            labelText: 'New category name',
                            hintText: 'Wraps, Breakfast, Signature drinks',
                          ),
                          validator: (value) {
                            if (!_creatingNewCategory) {
                              return null;
                            }
                            if (value == null || value.trim().isEmpty) {
                              return 'Category name is required';
                            }
                            return null;
                          },
                        )
                      else
                        DropdownButtonFormField<String>(
                          key: ValueKey('${selectedRestaurant.id}-${activeCategoryId ?? 'none'}'),
                          initialValue: activeCategoryId,
                          items: categories
                              .map((value) => DropdownMenuItem(value: value.id, child: Text(value.title)))
                              .toList(growable: false),
                          onChanged: categories.isEmpty
                              ? null
                              : (value) {
                                  setState(() => _categoryId = value);
                                },
                          decoration: InputDecoration(
                            labelText: 'Category',
                            helperText: categories.isEmpty
                                ? 'No categories exist yet for this restaurant. Create one below.'
                                : null,
                          ),
                        ),
                      const SizedBox(height: AppSpacing.lg),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(labelText: 'Food title'),
                        validator: (value) => value == null || value.trim().isEmpty
                            ? 'Food title is required'
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(labelText: 'Description'),
                        maxLines: 3,
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
                        controller: _imageUrlController,
                        decoration: const InputDecoration(labelText: 'Image URL'),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      TextFormField(
                        controller: _customizationsController,
                        decoration: const InputDecoration(
                          labelText: 'Customizations',
                          hintText: 'Extra cheese:0.50, Extra sauce:0.25',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  onPressed: _submitting
                      ? null
                      : () => _submit(isEditMode: isEditMode, editingItem: editingItem),
                  child: _submitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(isEditMode ? 'Save changes' : 'Add product'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
