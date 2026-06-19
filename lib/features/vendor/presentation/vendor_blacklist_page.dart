import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/luqmah_theme.dart';
import '../../../core/network/api_client.dart';
import '../../../features/vendor/vendor_blacklist_controller.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/premium_page_app_bar.dart';
import '../../../shared/widgets/app_surface_card.dart';

class VendorBlacklistPage extends ConsumerStatefulWidget {
  const VendorBlacklistPage({super.key});

  @override
  ConsumerState<VendorBlacklistPage> createState() =>
      _VendorBlacklistPageState();
}

class _VendorBlacklistPageState extends ConsumerState<VendorBlacklistPage> {
  bool _isScrolled = false;

  void _handleScroll(double offset) {
    final next = offset > 0;
    if (next == _isScrolled) {
      return;
    }
    setState(() => _isScrolled = next);
  }

  Future<void> _removeEntry(
    BuildContext context,
    WidgetRef ref,
    String customerId,
    String customerName,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove from blacklist?'),
        content: Text('Allow $customerName to place future orders again?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      await ref
          .read(vendorBlacklistControllerProvider.notifier)
          .removeCustomer(customerId);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('$customerName removed from blacklist.')),
        );
    } on ApiException catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final blacklist = ref.watch(vendorBlacklistControllerProvider);
    final formatter = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: PremiumPageAppBar(
        icon: Icons.block_rounded,
        title: 'Blacklisted students',
        subtitle: 'Review and manage restricted customers from future orders.',
        isScrolled: _isScrolled,
      ),
      body: blacklist.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: AppEmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Unable to load blacklist',
            message: error.toString(),
          ),
        ),
        data: (entries) {
          if (entries.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: AppEmptyState(
                icon: Icons.shield_outlined,
                title: 'No blacklisted students',
                message:
                    'Students you blacklist will appear here for quick review and unblocking.',
              ),
            );
          }

          return NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              _handleScroll(notification.metrics.pixels);
              return false;
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: entries.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.lg),
              itemBuilder: (context, index) {
                final entry = entries[index];
                return AppSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.customerName,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Text(
                          formatter.format(entry.createdAt),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      entry.customerEmail.isEmpty
                          ? 'No email available'
                          : entry.customerEmail,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      entry.customerPhone.isEmpty
                          ? 'No phone number added'
                          : entry.customerPhone,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (entry.reason.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: context.luqmah.surfaceAlt,
                          borderRadius: BorderRadius.circular(AppRadii.lg),
                        ),
                        child: Text(entry.reason),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    OutlinedButton(
                      onPressed: () => _removeEntry(
                        context,
                        ref,
                        entry.customerId,
                        entry.customerName,
                      ),
                      child: const Text('Remove from blacklist'),
                    ),
                  ],
                ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
