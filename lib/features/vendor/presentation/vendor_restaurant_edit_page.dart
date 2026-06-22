import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/theme/luqmah_theme.dart';
import '../../../features/vendor/vendor_data_controller.dart';
import '../../../models/vendor.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/premium_page_app_bar.dart';
import '../../../shared/widgets/app_surface_card.dart';

class VendorRestaurantEditPage extends ConsumerStatefulWidget {
  const VendorRestaurantEditPage({super.key});

  @override
  ConsumerState<VendorRestaurantEditPage> createState() =>
      _VendorRestaurantEditPageState();
}

class _VendorRestaurantEditPageState
    extends ConsumerState<VendorRestaurantEditPage> {
  final _imagePicker = ImagePicker();
  final Map<String, _RestaurantDraft> _draftsByRestaurantId =
      <String, _RestaurantDraft>{};
  bool _isScrolled = false;

  void _handleScroll(double offset) {
    final next = offset > 0;
    if (next == _isScrolled) {
      return;
    }
    setState(() => _isScrolled = next);
  }

  @override
  void dispose() {
    for (final draft in _draftsByRestaurantId.values) {
      draft.dispose();
    }
    super.dispose();
  }

  void _syncDrafts(List<VendorRestaurant> restaurants) {
    final restaurantIds = restaurants
        .map((restaurant) => restaurant.id)
        .toSet();

    final removedIds = _draftsByRestaurantId.keys
        .where((id) => !restaurantIds.contains(id))
        .toList(growable: false);
    for (final id in removedIds) {
      _draftsByRestaurantId.remove(id)?.dispose();
    }

    for (final restaurant in restaurants) {
      final existingDraft = _draftsByRestaurantId[restaurant.id];
      if (existingDraft == null) {
        _draftsByRestaurantId[restaurant.id] = _RestaurantDraft.fromRestaurant(
          restaurant,
        );
        continue;
      }

      existingDraft.syncRestaurant(restaurant);
    }
  }

  Future<void> _pickCoverImage(String restaurantId) async {
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image == null || !mounted) {
      return;
    }

    final bytes = await image.readAsBytes();
    if (!mounted) {
      return;
    }

    setState(() {
      final draft = _draftsByRestaurantId[restaurantId];
      if (draft == null) {
        return;
      }
      draft.selectedCoverImageBytes = bytes;
      draft.selectedCoverImageName = image.name;
      draft.selectedCoverImageMimeType = image.mimeType;
    });
  }

  Future<void> _saveRestaurant(_RestaurantDraft draft) async {
    if (!draft.formKey.currentState!.validate()) {
      return;
    }

    setState(() => draft.isSaving = true);
    try {
      var coverImage = draft.coverImageUrl;
      if (draft.selectedCoverImageBytes != null) {
        coverImage = await ref
            .read(vendorDataControllerProvider.notifier)
            .uploadRestaurantCover(
              bytes: draft.selectedCoverImageBytes!,
              filename: draft.selectedCoverImageName ?? 'restaurant-cover.jpg',
              contentType: draft.selectedCoverImageMimeType,
            );
      }

      await ref
          .read(vendorDataControllerProvider.notifier)
          .updateRestaurant(
            restaurantId: draft.restaurantId,
            title: draft.titleController.text.trim(),
            description: draft.descriptionController.text.trim(),
            address: draft.addressController.text.trim(),
            coverImage: coverImage,
          );
      if (!mounted) {
        return;
      }

      setState(() {
        draft.coverImageUrl = coverImage;
        draft.selectedCoverImageBytes = null;
        draft.selectedCoverImageName = null;
        draft.selectedCoverImageMimeType = null;
        draft.isSaving = false;
        draft.lastSavedTitle = draft.titleController.text.trim();
        draft.lastSavedDescription = draft.descriptionController.text.trim();
        draft.lastSavedAddress = draft.addressController.text.trim();
      });
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Restaurant updated.')));
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => draft.isSaving = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', '')),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vendorData = ref.watch(vendorDataControllerProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/vendor/profile');
        }
      },
      child: Scaffold(
      appBar: PremiumPageAppBar(
        icon: Icons.edit_rounded,
        title: 'Edit restaurant',
        subtitle: 'Update your storefront details and keep everything clear for customers.',
        isScrolled: _isScrolled,
      ),
      body: vendorData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: AppEmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Unable to load restaurants',
            message: error.toString(),
          ),
        ),
        data: (state) {
          if (state.restaurants.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: AppEmptyState(
                icon: Icons.storefront_outlined,
                title: 'No restaurants yet',
                message:
                    'Your restaurant storefront settings will appear here.',
              ),
            );
          }

          _syncDrafts(state.restaurants);

          return NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              _handleScroll(notification.metrics.pixels);
              return false;
            },
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
              for (final restaurant in state.restaurants) ...[
                _RestaurantEditSection(
                  key: ValueKey('restaurant-${restaurant.id}'),
                  draft: _draftsByRestaurantId[restaurant.id]!,
                  onChooseCover: () => _pickCoverImage(restaurant.id),
                  onRemoveCover: () => setState(() {
                    final draft = _draftsByRestaurantId[restaurant.id];
                    if (draft == null) {
                      return;
                    }
                    draft.selectedCoverImageBytes = null;
                    draft.selectedCoverImageName = null;
                    draft.selectedCoverImageMimeType = null;
                    draft.coverImageUrl = '';
                  }),
                  onSave: () =>
                      _saveRestaurant(_draftsByRestaurantId[restaurant.id]!),
                ),
                if (restaurant != state.restaurants.last)
                  const SizedBox(height: AppSpacing.lg),
              ],
              ],
            ),
          );
        },
      ),
    ),);
  }
}

class _RestaurantEditSection extends StatelessWidget {
  const _RestaurantEditSection({
    super.key,
    required this.draft,
    required this.onChooseCover,
    required this.onRemoveCover,
    required this.onSave,
  });

  final _RestaurantDraft draft;
  final VoidCallback onChooseCover;
  final VoidCallback onRemoveCover;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      child: Form(
        key: draft.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              draft.lastSavedTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              key: ValueKey('restaurant-${draft.restaurantId}-title'),
              controller: draft.titleController,
              decoration: const InputDecoration(labelText: 'Restaurant title'),
              validator: (value) => value == null || value.trim().length < 2
                  ? 'Enter at least 2 characters'
                  : null,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              key: ValueKey('restaurant-${draft.restaurantId}-description'),
              controller: draft.descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              key: ValueKey('restaurant-${draft.restaurantId}-address'),
              controller: draft.addressController,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
            const SizedBox(height: AppSpacing.lg),
            _RestaurantCoverPicker(
              selectedBytes: draft.selectedCoverImageBytes,
              imageUrl: draft.coverImageUrl,
              onChoose: draft.isSaving ? null : onChooseCover,
              onRemove: draft.isSaving ? null : onRemoveCover,
            ),
            const SizedBox(height: AppSpacing.lg),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: draft.isSaving ? null : onSave,
                child: draft.isSaving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RestaurantCoverPicker extends StatelessWidget {
  const _RestaurantCoverPicker({
    required this.selectedBytes,
    required this.imageUrl,
    required this.onChoose,
    required this.onRemove,
  });

  final Uint8List? selectedBytes;
  final String imageUrl;
  final VoidCallback? onChoose;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final hasImage = selectedBytes != null || imageUrl.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Restaurant cover image',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: context.luqmah.surfaceAlt,
              alignment: Alignment.center,
              child: selectedBytes != null
                  ? Image.memory(
                      selectedBytes!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    )
                  : imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 42,
                        color: context.luqmah.mutedText,
                      ),
                    )
                  : Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 42,
                      color: context.luqmah.mutedText,
                    ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: onChoose,
              icon: const Icon(Icons.upload_rounded),
              label: Text(hasImage ? 'Change cover' : 'Choose cover'),
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

class _RestaurantDraft {
  _RestaurantDraft({
    required this.restaurantId,
    required this.titleController,
    required this.descriptionController,
    required this.addressController,
    required this.coverImageUrl,
    required this.lastSavedTitle,
    required this.lastSavedDescription,
    required this.lastSavedAddress,
  });

  factory _RestaurantDraft.fromRestaurant(VendorRestaurant restaurant) {
    return _RestaurantDraft(
      restaurantId: restaurant.id,
      titleController: TextEditingController(text: restaurant.title),
      descriptionController: TextEditingController(
        text: restaurant.description,
      ),
      addressController: TextEditingController(text: restaurant.address),
      coverImageUrl: restaurant.coverImage,
      lastSavedTitle: restaurant.title,
      lastSavedDescription: restaurant.description,
      lastSavedAddress: restaurant.address,
    );
  }

  final String restaurantId;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController addressController;
  Uint8List? selectedCoverImageBytes;
  String? selectedCoverImageName;
  String? selectedCoverImageMimeType;
  String coverImageUrl;
  String lastSavedTitle;
  String lastSavedDescription;
  String lastSavedAddress;
  bool isSaving = false;

  void syncRestaurant(VendorRestaurant restaurant) {
    if (isSaving) {
      return;
    }
    if (titleController.text == lastSavedTitle) {
      titleController.text = restaurant.title;
    }
    if (descriptionController.text == lastSavedDescription) {
      descriptionController.text = restaurant.description;
    }
    if (addressController.text == lastSavedAddress) {
      addressController.text = restaurant.address;
    }
    if (selectedCoverImageBytes == null) {
      coverImageUrl = restaurant.coverImage;
    }
    lastSavedTitle = restaurant.title;
    lastSavedDescription = restaurant.description;
    lastSavedAddress = restaurant.address;
  }

  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    addressController.dispose();
  }
}
