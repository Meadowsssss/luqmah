import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/theme/luqmah_theme.dart';
import '../../../shared/widgets/app_surface_card.dart';
import '../admin_vendors_controller.dart';

class AdminCreateVendorPage extends ConsumerStatefulWidget {
  const AdminCreateVendorPage({super.key});

  @override
  ConsumerState<AdminCreateVendorPage> createState() =>
      _AdminCreateVendorPageState();
}

class _AdminCreateVendorPageState extends ConsumerState<AdminCreateVendorPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _restaurantTitleController = TextEditingController();
  final _restaurantDescriptionController = TextEditingController();
  final _restaurantAddressController = TextEditingController();
  final _categoriesController = TextEditingController();
  final _imagePicker = ImagePicker();
  Uint8List? _coverImageBytes;
  String? _coverImageName;
  String? _coverImageMimeType;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _restaurantTitleController.dispose();
    _restaurantDescriptionController.dispose();
    _restaurantAddressController.dispose();
    _categoriesController.dispose();
    super.dispose();
  }

  Future<void> _pickCoverImage() async {
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }

    final bytes = await image.readAsBytes();
    setState(() {
      _coverImageBytes = bytes;
      _coverImageName = image.name;
      _coverImageMimeType = image.mimeType;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _submitting = true);
    try {
      var coverImage = '';
      if (_coverImageBytes != null) {
        coverImage = await ref
            .read(adminVendorsControllerProvider.notifier)
            .uploadRestaurantCover(
              bytes: _coverImageBytes!,
              filename: _coverImageName ?? 'restaurant-cover.jpg',
              contentType: _coverImageMimeType,
            );
      }

      final categories = _categoriesController.text
          .split(',')
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toList(growable: false);

      await ref
          .read(adminVendorsControllerProvider.notifier)
          .createVendor(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            restaurantTitle: _restaurantTitleController.text.trim(),
            restaurantDescription: _restaurantDescriptionController.text.trim(),
            restaurantAddress: _restaurantAddressController.text.trim(),
            coverImage: coverImage,
            categories: categories,
          );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vendor created successfully.')),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Create vendor')),
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
                    'Vendor account',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Vendor name'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Required'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Vendor email',
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Required'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Temporary password',
                    ),
                    validator: (value) =>
                        value == null || value.trim().length < 8
                        ? 'Minimum 8 characters'
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
                  Text(
                    'Restaurant setup',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _restaurantTitleController,
                    decoration: const InputDecoration(
                      labelText: 'Restaurant title',
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Required'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _restaurantDescriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _restaurantAddressController,
                    decoration: const InputDecoration(labelText: 'Address'),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _CoverImagePicker(
                    selectedBytes: _coverImageBytes,
                    onChoose: _submitting ? null : _pickCoverImage,
                    onRemove: _coverImageBytes == null
                        ? null
                        : () => setState(() {
                            _coverImageBytes = null;
                            _coverImageName = null;
                            _coverImageMimeType = null;
                          }),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _categoriesController,
                    decoration: const InputDecoration(
                      labelText: 'Categories',
                      hintText: 'Burgers, Drinks, Desserts',
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'At least one category is required'
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Create vendor'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoverImagePicker extends StatelessWidget {
  const _CoverImagePicker({
    required this.selectedBytes,
    required this.onChoose,
    required this.onRemove,
  });

  final Uint8List? selectedBytes;
  final VoidCallback? onChoose;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final hasImage = selectedBytes != null;

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
              child: selectedBytes == null
                  ? const Icon(Icons.add_photo_alternate_outlined, size: 42)
                  : Image.memory(
                      selectedBytes!,
                      fit: BoxFit.cover,
                      width: double.infinity,
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
