import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/luqmah_theme.dart';
import '../../../features/customer/orders/customer_orders_controller.dart';
import '../../../features/session/auth_error_formatter.dart';
import '../../../features/session/session_controller.dart';
import '../../../shared/widgets/app_surface_card.dart';

class CustomerSettingsPage extends ConsumerWidget {
  const CustomerSettingsPage({super.key});

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

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Profile', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppSpacing.lg),
                const _SettingRow(label: 'Account type', value: 'Customer'),
                const SizedBox(height: AppSpacing.md),
                _SettingRow(
                  label: 'Name',
                  value: session.displayName.isEmpty
                      ? 'No name available'
                      : session.displayName,
                ),
                const SizedBox(height: AppSpacing.md),
                _SettingRow(
                  label: 'Signed in as',
                  value: session.email.isEmpty ? 'No email available' : session.email,
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
                Text('Security', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Manage your password to help keep your account secure.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.luqmah.mutedText,
                  ),
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
                Text('Orders', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppSpacing.sm),
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
                      return Text(
                        'No order history yet. Orders saved from checkout will appear here.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.luqmah.mutedText,
                        ),
                      );
                    }

                    final latest = orders.first;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          latest.restaurantName,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${latest.status.name} - ${latest.total.toStringAsFixed(2)} JD',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: context.luqmah.mutedText,
                          ),
                        ),
                      ],
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
          AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Session', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Sign out to return to the Luqmah entry flow.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.luqmah.mutedText,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                ElevatedButton.icon(
                  onPressed: () => ref.read(sessionControllerProvider).logout(),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Sign out'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}
