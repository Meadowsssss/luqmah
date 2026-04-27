import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/luqmah_theme.dart';
import '../../../features/session/auth_error_formatter.dart';
import '../../../features/session/session_controller.dart';
import '../../../shared/widgets/app_surface_card.dart';

class VendorProfilePage extends ConsumerWidget {
  const VendorProfilePage({super.key});

  Future<void> _showVendorPasswordDialog(BuildContext context, WidgetRef ref) async {
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
                            await ref.read(sessionControllerProvider).changeVendorPassword(
                                  currentPassword: currentPasswordController.text,
                                  newPassword: newPasswordController.text,
                                );
                            if (context.mounted) {
                              Navigator.of(dialogContext).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Vendor password updated on the backend.'),
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

    return Scaffold(
      appBar: AppBar(title: const Text('Vendor profile')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Workspace identity', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  session.email.isEmpty ? 'Vendor account' : session.email,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Vendor workspace connected to the live Luqmah backend.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.luqmah.mutedText,
                  ),
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
            child: ElevatedButton.icon(
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
