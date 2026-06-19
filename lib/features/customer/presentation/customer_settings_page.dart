import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/luqmah_theme.dart';
import '../../../app/theme/theme_mode_controller.dart';
import '../../../core/validation/customer_profile_validators.dart';
import '../../../features/customer/orders/customer_orders_controller.dart';
import '../../../features/session/auth_error_formatter.dart';
import '../../../features/session/session_controller.dart';
import '../../../shared/widgets/app_surface_card.dart';

class CustomerSettingsPage extends ConsumerWidget {
  const CustomerSettingsPage({super.key});

  Future<void> _showCustomerNameDialog(
    BuildContext context,
    WidgetRef ref,
    String currentName,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => _CustomerNameDialog(
        currentName: currentName,
        onSaved: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Name updated.')),
          );
        },
      ),
    );
  }

  Future<void> _showPhoneNumberDialog(
    BuildContext context,
    WidgetRef ref,
    String currentPhoneNumber,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => _PhoneNumberDialog(
        currentPhoneNumber: currentPhoneNumber,
        onSaved: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Phone number updated.')),
          );
        },
      ),
    );
  }

  Future<void> _showCustomerPasswordDialog(BuildContext context, WidgetRef ref) async {
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
              title: const Text('Change password'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: currentPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Current password'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: newPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'New password'),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      error!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: saving ? null : () => Navigator.of(dialogContext).pop(),
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
                            await ref.read(sessionControllerProvider).changeCustomerPassword(
                                  currentPassword: currentPasswordController.text,
                                  newPassword: newPasswordController.text,
                                );
                            if (context.mounted) {
                              Navigator.of(dialogContext).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Customer password updated in Firebase.'),
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
    final recentOrders = ref.watch(customerOrdersControllerProvider);
    final themeMode = ref.watch(themeModeControllerProvider);
    final displayName = session.displayName.trim();
    final phoneNumber = session.phoneNumber.trim();
    final tokens = context.luqmah;
    final leadingInitial =
        displayName.isEmpty ? 'C' : displayName.characters.first.toUpperCase();

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        children: [
          AppSurfaceCard(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 56,
                      width: 56,
                      decoration: BoxDecoration(
                        color: tokens.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        leadingInitial,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: tokens.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName.isEmpty ? 'Customer profile' : displayName,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Keep your profile, preferences, and recent activity neatly in sync.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: tokens.mutedText),
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
                        color: tokens.surfaceAlt,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: tokens.border),
                      ),
                      child: Text(
                        'Customer',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: tokens.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: tokens.surfaceAlt.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    border: Border.all(color: tokens.border),
                  ),
                  child: Column(
                    children: [
                      _SettingInfoRow(
                        icon: Icons.badge_outlined,
                        label: 'Name',
                        value: displayName.isEmpty ? 'No name available' : displayName,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _SettingInfoRow(
                        icon: Icons.mail_outline_rounded,
                        label: 'Signed in as',
                        value: session.email.isEmpty
                            ? 'No email available'
                            : session.email,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _SettingInfoRow(
                        icon: Icons.phone_outlined,
                        label: 'Phone number',
                        value: phoneNumber.isEmpty
                            ? 'No phone number added'
                            : phoneNumber,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () =>
                          _showCustomerNameDialog(context, ref, displayName),
                      icon: const Icon(Icons.badge_outlined),
                      label: const Text('Change name'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () =>
                          _showPhoneNumberDialog(context, ref, phoneNumber),
                      icon: const Icon(Icons.phone_outlined),
                      label: Text(
                        phoneNumber.isEmpty
                            ? 'Add phone number'
                            : 'Change phone number',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionIntro(
                  icon: Icons.palette_outlined,
                  title: 'Appearance',
                  subtitle: 'Choose how Luqmah looks for you.',
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    border: Border.all(color: tokens.border),
                  ),
                  child: SwitchListTile.adaptive(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.xs,
                    ),
                    title: Text(
                      'Dark mode',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    value: themeMode.isDark,
                    onChanged: (value) => ref
                        .read(themeModeControllerProvider)
                        .setDarkMode(value),
                  ),
                ),
              ],
            ),
          ),
          if (session.customerSyncError != null) ...[
            const SizedBox(height: AppSpacing.lg),
            AppSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Backend sync issue',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(session.customerSyncError!),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionIntro(
                  icon: Icons.shield_outlined,
                  title: 'Security',
                  subtitle: 'Keep your account details protected with quick access to password management.',
                ),
                const SizedBox(height: AppSpacing.lg),
                OutlinedButton(
                  onPressed: () => _showCustomerPasswordDialog(context, ref),
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
                _SectionIntro(
                  icon: Icons.receipt_long_rounded,
                  title: 'Orders',
                  subtitle: 'See your recent activity and view your full order history here.',
                ),
                const SizedBox(height: AppSpacing.lg),
                recentOrders.when(
                  loading: () => const Text('Loading recent orders...'),
                  error: (error, stackTrace) => Text(
                    'Unable to load history right now.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  data: (orders) {
                    if (orders.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: tokens.surfaceAlt.withValues(alpha: 0.68),
                          borderRadius: BorderRadius.circular(AppRadii.lg),
                        ),
                        child: Text(
                          'No order history yet. Orders saved from checkout will appear here.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: context.luqmah.mutedText,
                          ),
                        ),
                      );
                    }

                    final latest = orders.first;
                    return Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: tokens.surfaceAlt.withValues(alpha: 0.68),
                        borderRadius: BorderRadius.circular(AppRadii.lg),
                        border: Border.all(color: tokens.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 42,
                            width: 42,
                            decoration: BoxDecoration(
                              color: tokens.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(AppRadii.md),
                            ),
                            child: Icon(
                              Icons.local_dining_rounded,
                              color: tokens.primary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  latest.restaurantName,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  '${latest.status.name} · ${latest.total.toStringAsFixed(2)} JD',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: context.luqmah.mutedText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                OutlinedButton(
                  onPressed: () => context.push('/settings/orders'),
                  child: const Text('View order history'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: () => ref.read(sessionControllerProvider).logout(),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}

class _PhoneNumberDialog extends ConsumerStatefulWidget {
  const _PhoneNumberDialog({
    required this.currentPhoneNumber,
    required this.onSaved,
  });

  final String currentPhoneNumber;
  final VoidCallback onSaved;

  @override
  ConsumerState<_PhoneNumberDialog> createState() => _PhoneNumberDialogState();
}

class _PhoneNumberDialogState extends ConsumerState<_PhoneNumberDialog> {
  late final TextEditingController _phoneController;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.currentPhoneNumber);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final phoneNumber = _phoneController.text.trim();
    if (phoneNumber.isEmpty) {
      setState(() => _error = 'Phone number is required.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await ref
          .read(sessionControllerProvider)
          .updateCustomerPhoneNumber(phoneNumber);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      widget.onSaved();
    } catch (err) {
      if (!mounted) {
        return;
      }
      setState(() {
        _saving = false;
        _error = formatAuthError(err);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.currentPhoneNumber.isEmpty
            ? 'Add phone number'
            : 'Change phone number',
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone number',
              hintText: '07...',
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
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

class _SectionIntro extends StatelessWidget {
  const _SectionIntro({
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

class _CustomerNameDialog extends ConsumerStatefulWidget {
  const _CustomerNameDialog({
    required this.currentName,
    required this.onSaved,
  });

  final String currentName;
  final VoidCallback onSaved;

  @override
  ConsumerState<_CustomerNameDialog> createState() =>
      _CustomerNameDialogState();
}

class _CustomerNameDialogState extends ConsumerState<_CustomerNameDialog> {
  late final TextEditingController _nameController;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final validationError = validateCustomerDisplayName(_nameController.text);
    if (validationError != null) {
      setState(() => _error = validationError);
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await ref
          .read(sessionControllerProvider)
          .updateCustomerName(_nameController.text.trim());
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      widget.onSaved();
    } catch (err) {
      if (!mounted) {
        return;
      }
      setState(() {
        _saving = false;
        _error = formatAuthError(err);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change name'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Full name',
              hintText: 'Your full name',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
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

class _SettingInfoRow extends StatelessWidget {
  const _SettingInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tokens = context.luqmah;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: Icon(icon, size: 18, color: tokens.primary),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: tokens.mutedText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(value, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
