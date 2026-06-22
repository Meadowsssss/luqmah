import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/network/api_client.dart';
import '../../../app/theme/luqmah_theme.dart';
import '../../../features/vendor/vendor_blacklist_controller.dart';
import '../../../features/vendor/vendor_data_controller.dart';
import '../../../models/vendor.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/premium_page_app_bar.dart';
import '../../../shared/widgets/app_surface_card.dart';

class VendorOrderDetailsPage extends ConsumerStatefulWidget {
  const VendorOrderDetailsPage({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<VendorOrderDetailsPage> createState() =>
      _VendorOrderDetailsPageState();
}

class _VendorOrderDetailsPageState
    extends ConsumerState<VendorOrderDetailsPage> {
  bool _isUpdatingStatus = false;
  bool _isScrolled = false;

  void _handleScroll(double offset) {
    final next = offset > 0;
    if (next == _isScrolled) {
      return;
    }
    setState(() => _isScrolled = next);
  }

  Future<void> _showBlacklistDialog(VendorOrder order) async {
    final controller = TextEditingController();

    final shouldSubmit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Blacklist student'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Block ${order.customerName} from placing future orders?'),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Reason (optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Blacklist'),
          ),
        ],
      ),
    );

    if (shouldSubmit != true) {
      controller.dispose();
      return;
    }

    try {
      await ref
          .read(vendorBlacklistControllerProvider.notifier)
          .blacklistCustomer(
            customerId: order.customerId,
            reason: controller.text,
          );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('${order.customerName} added to the blacklist.'),
          ),
        );
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      controller.dispose();
    }
  }

  Future<void> _removeBlacklistEntry(VendorOrder order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove from blacklist?'),
        content: Text(
          'Allow ${order.customerName} to place future orders again?',
        ),
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
          .removeCustomer(order.customerId);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('${order.customerName} removed from the blacklist.'),
          ),
        );
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final decodedId = Uri.decodeComponent(widget.orderId);
    final orderAsync = ref.watch(vendorOrderByIdProvider(decodedId));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/vendor/orders');
        }
      },
      child: orderAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        appBar: PremiumPageAppBar(
          icon: Icons.receipt_long_rounded,
          title: 'Order details',
          subtitle: 'Review customer details, items, and order status in one place.',
          isScrolled: _isScrolled,
        ),
        body: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: AppEmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Unable to load order',
            message: error.toString(),
          ),
        ),
      ),
      data: (order) {
        if (order == null) {
          return Scaffold(
            appBar: PremiumPageAppBar(
              icon: Icons.receipt_long_rounded,
              title: 'Order details',
              subtitle: 'Review customer details, items, and order status in one place.',
              isScrolled: _isScrolled,
            ),
            body: const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: AppEmptyState(
                icon: Icons.error_outline_rounded,
                title: 'Order not found',
                message: 'This order is no longer available for this vendor.',
              ),
            ),
          );
        }

        final formatter = DateFormat('dd MMM yyyy, hh:mm a');
        final allowedTransitions = order.status.allowedTransitions;
        final blacklistEntryAsync = ref.watch(
          vendorBlacklistEntryByCustomerIdProvider(order.customerId),
        );
        final blacklistEntry = blacklistEntryAsync.value;
        final isBlacklisted = blacklistEntry != null;

        return Scaffold(
          appBar: PremiumPageAppBar(
            icon: Icons.receipt_long_rounded,
            title: 'Order details',
            subtitle: 'Review customer details, items, and order status in one place.',
            isScrolled: _isScrolled,
          ),
          body: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              _handleScroll(notification.metrics.pixels);
              return false;
            },
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
              AppSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            color: context.luqmah.primary.withValues(
                              alpha: 0.12,
                            ),
                            borderRadius: BorderRadius.circular(AppRadii.lg),
                          ),
                          child: Icon(
                            Icons.person_rounded,
                            color: context.luqmah.primary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.customerName,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Wrap(
                                spacing: AppSpacing.sm,
                                runSpacing: AppSpacing.xs,
                                children: [
                                  _DetailMetaPill(
                                    icon: Icons.receipt_long_outlined,
                                    label: order.id,
                                  ),
                                  _DetailMetaPill(
                                    icon: Icons.schedule_rounded,
                                    label: formatter.format(order.dateTime),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _ContactLine(
                      icon: Icons.mail_outline_rounded,
                      value: order.customerEmail.isEmpty
                          ? 'No email available'
                          : order.customerEmail,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _ContactLine(
                      icon: Icons.phone_outlined,
                      value: order.customerPhone.isEmpty
                          ? 'No phone number added'
                          : order.customerPhone,
                    ),
                    if (order.status == VendorOrderStatus.inProgress &&
                        order.estimatedReadyAt != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Expected by ${DateFormat('hh:mm a').format(order.estimatedReadyAt!)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.luqmah.info,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      children: [
                        _DetailMetaPill(
                          icon: Icons.inventory_2_outlined,
                          label: '${order.items.length} items',
                        ),
                        _DetailMetaPill(
                          icon: Icons.payments_outlined,
                          label: '${order.total.toStringAsFixed(2)} JD',
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (blacklistEntryAsync.isLoading)
                      const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else if (isBlacklisted) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: context.luqmah.warning.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Blacklisted',
                          style: TextStyle(
                            color: context.luqmah.warning,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (blacklistEntry.reason.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          blacklistEntry.reason,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.md),
                      OutlinedButton(
                        onPressed: () => _removeBlacklistEntry(order),
                        child: const Text('Remove from blacklist'),
                      ),
                    ] else
                      FilledButton.icon(
                        onPressed: () => _showBlacklistDialog(order),
                        icon: const Icon(Icons.block_rounded),
                        label: const Text('Blacklist student'),
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
                      'Items',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    for (final item in order.items) ...[
                      _OrderItemRow(item: item),
                      if (item != order.items.last)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                          child: Divider(height: 1),
                        ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order status',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (allowedTransitions.isEmpty) ...[
                      _StatusBadge(status: order.status),
                    ] else ...[
                      _StatusBadge(status: order.status),
                      const SizedBox(height: AppSpacing.md),
                      DropdownButtonFormField<VendorOrderStatus>(
                        key: ValueKey(
                          'vendor-order-status-${order.id}-${order.status.name}',
                        ),
                        hint: Text('Update status'),
                        items: allowedTransitions
                            .map(
                              (status) => DropdownMenuItem(
                                value: status,
                                child: Text(status.label),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: _isUpdatingStatus
                            ? null
                            : (value) async {
                                if (value == null) {
                                  return;
                                }

                                final messenger = ScaffoldMessenger.of(context);
                                setState(() => _isUpdatingStatus = true);
                                try {
                                  await ref
                                      .read(
                                        vendorDataControllerProvider.notifier,
                                      )
                                      .updateOrderStatus(order.id, value);
                                } on ApiException catch (error) {
                                  if (!mounted) {
                                    return;
                                  }
                                  messenger
                                    ..hideCurrentSnackBar()
                                    ..showSnackBar(
                                      SnackBar(content: Text(error.message)),
                                    );
                                } catch (_) {
                                  if (!mounted) {
                                    return;
                                  }
                                  messenger
                                    ..hideCurrentSnackBar()
                                    ..showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Unable to update the order status right now.',
                                        ),
                                      ),
                                    );
                                } finally {
                                  if (mounted) {
                                    setState(() => _isUpdatingStatus = false);
                                  }
                                }
                              },
                      ),
                    ],
                    if (_isUpdatingStatus) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Updating order status...',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Grand total',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Text(
                          '${order.total.toStringAsFixed(2)} JD',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ],
            ),
          ),
        );
      },
    ),);
  }
}

class _ContactLine extends StatelessWidget {
  const _ContactLine({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 17, color: context.luqmah.primary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(value, style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    );
  }
}

class _DetailMetaPill extends StatelessWidget {
  const _DetailMetaPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = context.luqmah;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tokens.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: tokens.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: tokens.strongText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  const _OrderItemRow({required this.item});

  final VendorOrderItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.name, style: Theme.of(context).textTheme.titleMedium),
              if (item.extras.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  item.extras.join(', '),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
        Text(
          'x${item.quantity}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(width: AppSpacing.lg),
        Text(
          '${item.lineTotal.toStringAsFixed(0)} JD',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final VendorOrderStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      VendorOrderStatus.accepted => context.luqmah.success,
      VendorOrderStatus.inProgress => context.luqmah.warning,
      VendorOrderStatus.ready => context.luqmah.info,
      VendorOrderStatus.completed => context.luqmah.mutedText,
      VendorOrderStatus.cancelled => AppColors.error,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}
