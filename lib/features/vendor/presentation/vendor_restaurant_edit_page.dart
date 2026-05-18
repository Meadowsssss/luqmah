import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/theme/luqmah_theme.dart';
import '../../../features/vendor/vendor_data_controller.dart';
import '../../../models/vendor.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_surface_card.dart';

class VendorRestaurantEditPage extends ConsumerWidget {
  const VendorRestaurantEditPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendorData = ref.watch(vendorDataControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit restaurant')),
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

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              for (final restaurant in state.restaurants) ...[
                _RestaurantEditCard(restaurant: restaurant),
                if (restaurant != state.restaurants.last)
                  const SizedBox(height: AppSpacing.lg),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _RestaurantEditCard extends ConsumerStatefulWidget {
  const _RestaurantEditCard({required this.restaurant});

  final VendorRestaurant restaurant;

  @override
  ConsumerState<_RestaurantEditCard> createState() =>
      _RestaurantEditCardState();
}

class _RestaurantEditCardState extends ConsumerState<_RestaurantEditCard> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _addressController;
  Uint8List? _coverImageBytes;
  String? _coverImageName;
  String? _coverImageMimeType;
  late String _coverImageUrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.restaurant.title);
    _descriptionController = TextEditingController(
      text: widget.restaurant.description,
    );
    _addressController = TextEditingController(text: widget.restaurant.address);
    _coverImageUrl = widget.restaurant.coverImage;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickCoverImage() async {
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }

    final bytes = await image.readAsBytes();
    if (!mounted) {
      return;
    }

    setState(() {
      _coverImageBytes = bytes;
      _coverImageName = image.name;
      _coverImageMimeType = image.mimeType;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _saving = true);
    try {
      var coverImage = _coverImageUrl;
      if (_coverImageBytes != null) {
        coverImage = await ref
            .read(vendorDataControllerProvider.notifier)
            .uploadRestaurantCover(
              bytes: _coverImageBytes!,
              filename: _coverImageName ?? 'restaurant-cover.jpg',
              contentType: _coverImageMimeType,
            );
      }

      await ref
          .read(vendorDataControllerProvider.notifier)
          .updateRestaurant(
            restaurantId: widget.restaurant.id,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            address: _addressController.text.trim(),
            coverImage: coverImage,
          );
      if (!mounted) {
        return;
      }

      setState(() {
        _coverImageUrl = coverImage;
        _coverImageBytes = null;
        _coverImageName = null;
        _coverImageMimeType = null;
        _saving = false;
      });
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Restaurant updated.')));
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _saving = false);
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
    return AppSurfaceCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.restaurant.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Restaurant title'),
              validator: (value) => value == null || value.trim().length < 2
                  ? 'Enter at least 2 characters'
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
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
            const SizedBox(height: AppSpacing.lg),
            _RestaurantCoverPicker(
              selectedBytes: _coverImageBytes,
              imageUrl: _coverImageUrl,
              onChoose: _saving ? null : _pickCoverImage,
              onRemove: _saving
                  ? null
                  : () => setState(() {
                      _coverImageBytes = null;
                      _coverImageName = null;
                      _coverImageMimeType = null;
                      _coverImageUrl = '';
                    }),
            ),
            const SizedBox(height: AppSpacing.lg),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
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
              color: AppColors.surfaceAlt,
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
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 42,
                      ),
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
