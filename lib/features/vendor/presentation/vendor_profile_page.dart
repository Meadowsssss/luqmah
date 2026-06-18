import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/luqmah_theme.dart';
import '../../../app/theme/theme_mode_controller.dart';
import '../../../features/session/auth_error_formatter.dart';
import '../../../features/session/session_controller.dart';
import '../../../features/vendor/vendor_blacklist_controller.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider).snapshot;
    final vendorData = ref.watch(vendorDataControllerProvider);
    final blacklist = ref.watch(vendorBlacklistControllerProvider);
    final themeMode = ref.watch(themeModeControllerProvider);

    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      height: 56,
                      width: 56,
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
                            'Vendor workspace',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Keep your storefront, visibility, and account details feeling organized and ready for service.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: context.luqmah.mutedText),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: context.luqmah.surfaceAlt.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    border: Border.all(color: context.luqmah.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Signed in as',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: context.luqmah.mutedText,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              session.email.isEmpty
                                  ? 'Vendor account'
                                  : session.email,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.82),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Vendor',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.luqmah.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
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
                  _VendorSectionIntro(
                    icon: Icons.store_mall_directory_rounded,
                    title: 'Storefronts',
                    subtitle: 'Keep your restaurant details clean, current, and easier for customers to trust.',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton(
                      onPressed: state.restaurants.isEmpty
                          ? null
                          : () => context.push('/vendor/profile/edit'),
                      child: const Text('Edit restaurant'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  for (final restaurant in state.restaurants) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: context.luqmah.surfaceAlt.withValues(alpha: 0.62),
                        borderRadius: BorderRadius.circular(AppRadii.lg),
                        border: Border.all(color: context.luqmah.border),
                      ),
                      child: Row(
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
                        ],
                      ),
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
                _VendorSectionIntro(
                  icon: Icons.palette_outlined,
                  title: 'Appearance',
                  subtitle: 'Keep your workspace comfortable while preserving the same visual language used across Luqmah.',
                ),
                const SizedBox(height: AppSpacing.md),
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
                _VendorSectionIntro(
                  icon: Icons.block_rounded,
                  title: 'Blocked students',
                  subtitle: 'Review who is restricted from future orders and manage that list with less friction.',
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  blacklist.when(
                    loading: () => 'Loading blacklist...',
                    error: (_, __) =>
                        'Review students who are blocked from future orders.',
                    data: (entries) => entries.isEmpty
                        ? 'No students are blocked right now.'
                        : '${entries.length} student${entries.length == 1 ? '' : 's'} currently blocked from future orders.',
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.luqmah.mutedText,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                OutlinedButton(
                  onPressed: () => context.push('/vendor/profile/blacklist'),
                  child: const Text('Manage blacklist'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _VendorSectionIntro(
                  icon: Icons.shield_outlined,
                  title: 'Security',
                  subtitle: 'Manage your vendor password with a little more confidence and less visual clutter.',
                ),
                const SizedBox(height: AppSpacing.lg),
                OutlinedButton(
                  onPressed: () => _showVendorPasswordDialog(context, ref),
                  child: const Text('Change password'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _VendorSectionIntro(
                  icon: Icons.schedule_rounded,
                  title: 'Restaurant availability',
                  subtitle: _busyMessage,
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

class _VendorSectionIntro extends StatelessWidget {
  const _VendorSectionIntro({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final tokens = context.luqmah;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: tokens.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: Icon(icon, color: tokens.primary),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: tokens.mutedText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
