import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/theme/luqmah_theme.dart';
import '../../../app/theme/theme_mode_controller.dart';
import '../../../features/session/auth_error_formatter.dart';
import '../../../features/session/session_controller.dart';
import '../../../features/vendor/vendor_data_controller.dart';
import '../../../models/vendor.dart';
import '../../../shared/widgets/app_surface_card.dart';

class VendorProfilePage extends ConsumerWidget {
  const VendorProfilePage({super.key});

  static const _busyMessage =
      'This restaurant is busy right now. You can browse the menu, but ordering is temporarily unavailable.';

  Future<void> _showVendorPasswordDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    String? error;
    bool saving = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Change vendor password'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: currentPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Current password',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: newPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'New password',
                    ),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: saving
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: saving
                      ? null
                      : () async {
                          setState(() {
                            saving = true;
                            error = null;
                          });

                          try {
                            await ref
                                .read(sessionControllerProvider)
                                .changeVendorPassword(
                                  currentPassword:
                                      currentPasswordController.text,
                                  newPassword: newPasswordController.text,
                                );
                            if (context.mounted) {
                              Navigator.of(dialogContext).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Vendor password updated on the backend.',
                                  ),
                                ),
                              );
                            }
                          } catch (err) {
                            setState(() {
                              saving = false;
                              error = formatAuthError(err);
                            });
                          }
                        },
                  child: saving
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
              ],
            );
          },
        );
      },
    );

    currentPasswordController.dispose();
    newPasswordController.dispose();
  }

  Future<void> _showVendorNameDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (_) => const _VendorNameDialog(),
    );
  }

  Future<void> _showRestaurantEditDialog(
    BuildContext context,
    VendorRestaurant restaurant,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _VendorRestaurantDialog(restaurant: restaurant),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider).snapshot;
    final vendorData = ref.watch(vendorDataControllerProvider);
    final themeMode = ref.watch(themeModeControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Vendor profile')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          AppSurfaceCard(
            child: Row(
              children: [
                Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    color: context.luqmah.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                  ),
                  child: Icon(
                    Icons.storefront_rounded,
                    color: context.luqmah.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Workspace identity',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        session.email.isEmpty
                            ? 'Vendor account'
                            : session.email,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        session.displayName.isEmpty
                            ? 'Vendor'
                            : session.displayName,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Connected to the live Luqmah backend.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.luqmah.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () => _showVendorNameDialog(context),
                  child: const Text('Edit profile'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppSurfaceCard(
            child: vendorData.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text(
                error.toString(),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              data: (state) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Restaurants',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Keep your storefront details up to date for customers.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.luqmah.mutedText,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  for (final restaurant in state.restaurants) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (restaurant.coverImage.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadii.md),
                            child: Image.network(
                              restaurant.coverImage,
                              height: 72,
                              width: 72,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 72,
                                width: 72,
                                color: AppColors.surfaceAlt,
                                alignment: Alignment.center,
                                child: const Icon(Icons.storefront_rounded),
                              ),
                            ),
                          )
                        else
                          Container(
                            height: 72,
                            width: 72,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceAlt,
                              borderRadius: BorderRadius.circular(AppRadii.md),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(Icons.storefront_rounded),
                          ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                restaurant.title,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              if (restaurant.description.isNotEmpty) ...[
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  restaurant.description,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                              if (restaurant.address.isNotEmpty) ...[
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  restaurant.address,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ],
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () =>
                              _showRestaurantEditDialog(context, restaurant),
                          child: const Text('Edit'),
                        ),
                      ],
                    ),
                    if (restaurant != state.restaurants.last)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                        child: Divider(height: 1),
                      ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Appearance',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Dark mode'),
                  subtitle: const Text(
                    'Use a darker premium Luqmah workspace.',
                  ),
                  value: themeMode.isDark,
                  onChanged: (value) =>
                      ref.read(themeModeControllerProvider).setDarkMode(value),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Security', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Vendor passwords are managed by the Luqmah backend.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.luqmah.mutedText,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                OutlinedButton(
                  onPressed: () => _showVendorPasswordDialog(context, ref),
                  child: const Text('Change backend password'),
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
                  'Restaurant availability',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _busyMessage,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.luqmah.mutedText,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                vendorData.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Text(
                    error.toString(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  data: (state) => Column(
                    children: state.restaurants
                        .map(
                          (restaurant) => _BusyToggleTile(
                            restaurant: restaurant,
                            onChanged: (value) async {
                              await ref
                                  .read(vendorDataControllerProvider.notifier)
                                  .updateRestaurantBusyState(
                                    restaurant.id,
                                    value,
                                  );
                              if (!context.mounted) {
                                return;
                              }
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      value
                                          ? '${restaurant.title} marked busy.'
                                          : '${restaurant.title} marked available.',
                                    ),
                                  ),
                                );
                            },
                          ),
                        )
                        .toList(growable: false),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppSurfaceCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: FilledButton.icon(
              onPressed: () => ref.read(sessionControllerProvider).logout(),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign out'),
            ),
          ),
        ],
      ),
    );
  }
}

class _VendorNameDialog extends ConsumerStatefulWidget {
  const _VendorNameDialog();

  @override
  ConsumerState<_VendorNameDialog> createState() => _VendorNameDialogState();
}

class _VendorNameDialogState extends ConsumerState<_VendorNameDialog> {
  late final TextEditingController _nameController;
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final session = ref.read(sessionControllerProvider).snapshot;
    _nameController = TextEditingController(text: session.displayName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _saving = true);
    try {
      final messenger = ScaffoldMessenger.of(context);
      await ref
          .read(sessionControllerProvider)
          .updateVendorProfile(name: _nameController.text.trim());
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Vendor profile updated.')),
        );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(formatAuthError(error))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit profile'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Vendor name'),
          validator: (value) => value == null || value.trim().length < 2
              ? 'Enter at least 2 characters'
              : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
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
      ],
    );
  }
}

class _VendorRestaurantDialog extends ConsumerStatefulWidget {
  const _VendorRestaurantDialog({required this.restaurant});

  final VendorRestaurant restaurant;

  @override
  ConsumerState<_VendorRestaurantDialog> createState() =>
      _VendorRestaurantDialogState();
}

class _VendorRestaurantDialogState
    extends ConsumerState<_VendorRestaurantDialog> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _addressController;
  Uint8List? _coverImageBytes;
  String? _coverImageName;
  String? _coverImageMimeType;
  String _coverImageUrl = '';
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
      final messenger = ScaffoldMessenger.of(context);
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
      Navigator.of(context).pop();
      messenger
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
    return AlertDialog(
      title: const Text('Edit restaurant'),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Restaurant title',
                  ),
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
                _VendorCoverImagePicker(
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
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
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
      ],
    );
  }
}

class _VendorCoverImagePicker extends StatelessWidget {
  const _VendorCoverImagePicker({
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

class _BusyToggleTile extends ConsumerStatefulWidget {
  const _BusyToggleTile({required this.restaurant, required this.onChanged});

  final VendorRestaurant restaurant;
  final Future<void> Function(bool value) onChanged;

  @override
  ConsumerState<_BusyToggleTile> createState() => _BusyToggleTileState();
}

class _BusyToggleTileState extends ConsumerState<_BusyToggleTile> {
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      title: Text(widget.restaurant.title),
      subtitle: Text(widget.restaurant.isBusy ? 'Busy' : 'Available'),
      value: widget.restaurant.isBusy,
      onChanged: _saving
          ? null
          : (value) async {
              setState(() => _saving = true);
              try {
                await widget.onChanged(value);
              } catch (error) {
                if (!context.mounted) {
                  return;
                }
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(content: Text(formatAuthError(error))),
                  );
              } finally {
                if (mounted) {
                  setState(() => _saving = false);
                }
              }
            },
    );
  }
}
