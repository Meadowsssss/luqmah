import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

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
  ConsumerState<VendorProductFormPage> createState() =>
      _VendorProductFormPageState();
}

class _VendorProductFormPageState extends ConsumerState<VendorProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _titleController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _priceController = TextEditingController();
  final _newCategoryController = TextEditingController();
  final _imagePicker = ImagePicker();

  String? _restaurantId;
  String? _categoryId;
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  String? _selectedImageMimeType;
  bool _creatingNewCategory = false;
  bool _submitting = false;
  bool _didInitializeForm = false;
  bool _clearExistingImage = false;
  List<_OptionGroupDraft> _optionGroups = <_OptionGroupDraft>[];

  @override
  void dispose() {
    _descriptionController.dispose();
    _titleController.dispose();
    _ingredientsController.dispose();
    _priceController.dispose();
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

    if (_restaurantId != selectedRestaurant.id ||
        _categoryId != nextCategoryId) {
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
    _optionGroups = item.optionGroups
        .map(
          (group) => _OptionGroupDraft(
            title: group.title,
            selectionType: group.selectionType,
            isRequired: group.isRequired,
            options: group.options
                .map(
                  (option) => _OptionValueDraft(
                    title: option.title,
                    priceDeltaText: option.priceDelta.toStringAsFixed(2),
                  ),
                )
                .toList(growable: true),
          ),
        )
        .toList(growable: true);
  }

  List<String> _parseCsv(TextEditingController controller) {
    return controller.text
        .split(',')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
  }

  String? _validateOptionGroups() {
    for (final group in _optionGroups) {
      if (group.title.trim().isEmpty) {
        return 'Each option group needs a title.';
      }
      if (group.options.isEmpty) {
        return 'Each option group needs at least one option.';
      }
      for (final option in group.options) {
        if (option.title.trim().isEmpty) {
          return 'Each option needs a title.';
        }
        if (double.tryParse(option.priceDeltaText.trim()) == null) {
          return 'Each option needs a valid price delta.';
        }
      }
    }
    return null;
  }

  List<Map<String, Object?>> _serializeOptionGroups() {
    return _optionGroups
        .asMap()
        .entries
        .map((groupEntry) {
          final group = groupEntry.value;
          return <String, Object?>{
            'title': group.title.trim(),
            'selectionType':
                group.selectionType == VendorMenuItemOptionSelectionType.single
                ? 'single'
                : 'multiple',
            'isRequired': group.isRequired,
            'sortOrder': groupEntry.key,
            'options': group.options
                .asMap()
                .entries
                .map((optionEntry) {
                  final option = optionEntry.value;
                  return <String, Object?>{
                    'title': option.title.trim(),
                    'priceDelta': double.parse(option.priceDeltaText.trim()),
                    'sortOrder': optionEntry.key,
                  };
                })
                .toList(growable: false),
          };
        })
        .toList(growable: false);
  }

  Future<void> _pickImage() async {
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }

    final bytes = await image.readAsBytes();
    setState(() {
      _selectedImageBytes = bytes;
      _selectedImageName = image.name;
      _selectedImageMimeType = image.mimeType;
      _clearExistingImage = false;
    });
  }

  void _removeImage({required bool hasExistingImage}) {
    setState(() {
      if (_selectedImageBytes != null) {
        _selectedImageBytes = null;
        _selectedImageName = null;
        _selectedImageMimeType = null;
        return;
      }

      if (hasExistingImage) {
        _clearExistingImage = true;
      }
    });
  }

  Future<void> _submit({
    required bool isEditMode,
    required VendorMenuItem? editingItem,
  }) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final optionGroupsError = _validateOptionGroups();
    if (optionGroupsError != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(optionGroupsError)));
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
        const SnackBar(
          content: Text('Choose an existing category or create a new one.'),
        ),
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
      final newCategoryTitle = _creatingNewCategory
          ? _newCategoryController.text.trim()
          : null;
      final optionGroups = _serializeOptionGroups();
      var imageUrl = isEditMode && !_clearExistingImage
          ? editingItem!.image
          : '';

      if (_selectedImageBytes != null) {
        imageUrl = await notifier.uploadMenuItemImage(
          bytes: _selectedImageBytes!,
          filename: _selectedImageName ?? 'menu-item-image.jpg',
          contentType: _selectedImageMimeType,
        );
      }

      if (isEditMode) {
        await notifier.editMenuItem(
          itemId: editingItem!.id,
          restaurantId: _restaurantId!,
          categoryId: categoryId,
          newCategoryTitle: newCategoryTitle,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          imageUrl: imageUrl,
          ingredientNames: _parseCsv(_ingredientsController),
          optionGroups: optionGroups,
        );
      } else {
        await notifier.addMenuItem(
          restaurantId: _restaurantId!,
          categoryId: categoryId,
          newCategoryTitle: newCategoryTitle,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          imageUrl: imageUrl,
          ingredientNames: _parseCsv(_ingredientsController),
          optionGroups: optionGroups,
        );
      }

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditMode
                ? 'Product updated successfully.'
                : 'Product published successfully.',
          ),
        ),
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
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
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
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
                message:
                    'Ask an admin to create your restaurant and categories before publishing products.',
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
        final existingImageUrl = isEditMode && !_clearExistingImage
            ? editingItem?.image ?? ''
            : '';
        final hasImage =
            _selectedImageBytes != null || existingImageUrl.isNotEmpty;
        final activeCategoryId =
            categories.any((item) => item.id == _categoryId)
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
                      Text(
                        'Product details',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      if (isEditMode)
                        TextFormField(
                          initialValue: selectedRestaurant.title,
                          decoration: const InputDecoration(
                            labelText: 'Restaurant',
                          ),
                          readOnly: true,
                          enabled: false,
                        )
                      else
                        DropdownButtonFormField<String>(
                          key: ValueKey(currentRestaurantId),
                          initialValue: currentRestaurantId,
                          items: restaurants
                              .map(
                                (value) => DropdownMenuItem(
                                  value: value.id,
                                  child: Text(value.title),
                                ),
                              )
                              .toList(growable: false),
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }
                            setState(() {
                              _restaurantId = value;
                              final nextRestaurant = restaurants.firstWhere(
                                (item) => item.id == value,
                              );
                              _categoryId = nextRestaurant.categories.isEmpty
                                  ? null
                                  : nextRestaurant.categories.first.id;
                              _creatingNewCategory = false;
                              _newCategoryController.clear();
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Restaurant',
                          ),
                        ),
                      const SizedBox(height: AppSpacing.lg),
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment<bool>(
                            value: false,
                            label: Text('Use existing'),
                          ),
                          ButtonSegment<bool>(
                            value: true,
                            label: Text('Create new'),
                          ),
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
                          key: ValueKey(
                            '${selectedRestaurant.id}-${activeCategoryId ?? 'none'}',
                          ),
                          initialValue: activeCategoryId,
                          items: categories
                              .map(
                                (value) => DropdownMenuItem(
                                  value: value.id,
                                  child: Text(value.title),
                                ),
                              )
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
                        decoration: const InputDecoration(
                          labelText: 'Food title',
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Food title is required'
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      TextFormField(
                        controller: _ingredientsController,
                        decoration: const InputDecoration(
                          labelText: 'Ingredients',
                          hintText: 'Tomato, mozzarella, basil',
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Ingredients are required'
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      TextFormField(
                        controller: _priceController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Base price in JD',
                        ),
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
                      _ProductImagePicker(
                        selectedBytes: _selectedImageBytes,
                        existingImageUrl: existingImageUrl,
                        onChoose: _submitting ? null : _pickImage,
                        onRemove: hasImage
                            ? () => _removeImage(
                                hasExistingImage: existingImageUrl.isNotEmpty,
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppSurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Option groups',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _optionGroups.add(
                                  _OptionGroupDraft(
                                    title: '',
                                    selectionType:
                                        VendorMenuItemOptionSelectionType
                                            .single,
                                    options: [
                                      _OptionValueDraft(
                                        title: '',
                                        priceDeltaText: '0',
                                      ),
                                    ],
                                  ),
                                );
                              });
                            },
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Add group'),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Use groups for size, milk type, sugar level, extras, or any other choices. New groups start as single choice.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.luqmah.mutedText,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      if (_optionGroups.isEmpty)
                        Text(
                          'No option groups yet. Leave this empty for a simple product, or add a group for choices like size.',
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      else
                        for (final entry in _optionGroups.asMap().entries) ...[
                          _OptionGroupEditor(
                            key: ValueKey('option-group-${entry.key}'),
                            group: entry.value,
                            onRemove: () {
                              setState(() => _optionGroups.removeAt(entry.key));
                            },
                            onChanged: () => setState(() {}),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  onPressed: _submitting
                      ? null
                      : () => _submit(
                          isEditMode: isEditMode,
                          editingItem: editingItem,
                        ),
                  child: _submitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
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

class _ProductImagePicker extends StatelessWidget {
  const _ProductImagePicker({
    required this.selectedBytes,
    required this.existingImageUrl,
    required this.onChoose,
    required this.onRemove,
  });

  final Uint8List? selectedBytes;
  final String existingImageUrl;
  final VoidCallback? onChoose;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final hasImage = selectedBytes != null || existingImageUrl.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Product image', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              color: AppColors.surfaceAlt,
              alignment: Alignment.center,
              child: selectedBytes != null
                  ? Image.memory(
                      selectedBytes!,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                    )
                  : existingImageUrl.isNotEmpty
                  ? Image.network(
                      existingImageUrl,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image_not_supported_outlined),
                    )
                  : const Icon(Icons.add_photo_alternate_outlined, size: 42),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: onChoose,
              icon: const Icon(Icons.upload_rounded),
              label: Text(hasImage ? 'Change image' : 'Choose image'),
            ),
            if (hasImage) ...[
              const SizedBox(width: AppSpacing.md),
              TextButton.icon(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Remove'),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'JPEG, PNG, or WebP. Maximum 5 MB.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _OptionGroupEditor extends StatelessWidget {
  const _OptionGroupEditor({
    super.key,
    required this.group,
    required this.onRemove,
    required this.onChanged,
  });

  final _OptionGroupDraft group;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: group.title,
                  decoration: const InputDecoration(labelText: 'Group title'),
                  onChanged: (value) => group.title = value,
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SegmentedButton<VendorMenuItemOptionSelectionType>(
            segments: const [
              ButtonSegment(
                value: VendorMenuItemOptionSelectionType.single,
                label: Text('Single choice (radio buttons)'),
              ),
              ButtonSegment(
                value: VendorMenuItemOptionSelectionType.multiple,
                label: Text('Multiple choice (checkboxes)'),
              ),
            ],
            selected: <VendorMenuItemOptionSelectionType>{group.selectionType},
            onSelectionChanged: (value) {
              group.selectionType = value.first;
              onChanged();
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: group.isRequired,
            title: const Text('Required'),
            subtitle: const Text(
              'Customers must choose from this group before adding to cart.',
            ),
            onChanged: (value) {
              group.isRequired = value;
              onChanged();
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final optionEntry in group.options.asMap().entries) ...[
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: optionEntry.value.title,
                    decoration: const InputDecoration(
                      labelText: 'Option title',
                    ),
                    onChanged: (value) => optionEntry.value.title = value,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                SizedBox(
                  width: 120,
                  child: TextFormField(
                    initialValue: optionEntry.value.priceDeltaText,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Price delta'),
                    onChanged: (value) =>
                        optionEntry.value.priceDeltaText = value,
                  ),
                ),
                IconButton(
                  onPressed: group.options.length == 1
                      ? null
                      : () {
                          group.options.removeAt(optionEntry.key);
                          onChanged();
                        },
                  icon: const Icon(Icons.remove_circle_outline_rounded),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          TextButton.icon(
            onPressed: () {
              group.options.add(
                _OptionValueDraft(title: '', priceDeltaText: '0'),
              );
              onChanged();
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add option'),
          ),
        ],
      ),
    );
  }
}

class _OptionGroupDraft {
  _OptionGroupDraft({
    required this.title,
    required this.selectionType,
    this.isRequired = false,
    List<_OptionValueDraft>? options,
  }) : options = options ?? <_OptionValueDraft>[];

  String title;
  VendorMenuItemOptionSelectionType selectionType;
  bool isRequired;
  List<_OptionValueDraft> options;
}

class _OptionValueDraft {
  _OptionValueDraft({required this.title, required this.priceDeltaText});

  String title;
  String priceDeltaText;
}
