import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/luqmah_theme.dart';
import '../../../features/vendor/vendor_data_controller.dart';
import '../../../models/vendor.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_surface_card.dart';

class VendorOrdersPage extends ConsumerStatefulWidget {
  const VendorOrdersPage({super.key});

  @override
  ConsumerState<VendorOrdersPage> createState() => _VendorOrdersPageState();
}

class _VendorOrdersPageState extends ConsumerState<VendorOrdersPage> {
  bool _showPastOrders = false;

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(vendorDataControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Orders', style: Theme.of(context).textTheme.titleLarge),
            Text('Luqmah operations', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
      body: ListView(
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
                        color: context.luqmah.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppRadii.lg),
                      ),
                      child: Icon(Icons.receipt_long_rounded, color: context.luqmah.primary),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order queue',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Track what is active now, keep your history tidy, and respond faster from one calmer workspace.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: context.luqmah.mutedText,
                            ),
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
                        color: context.luqmah.surfaceAlt,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: context.luqmah.border),
                      ),
                      child: Text(
                        _showPastOrders ? 'History' : 'Active',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.luqmah.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: context.luqmah.surfaceAlt.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    border: Border.all(color: context.luqmah.border),
                  ),
                  child: SegmentedButton<bool>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment<bool>(value: false, label: Text('Active')),
                      ButtonSegment<bool>(value: true, label: Text('History')),
                    ],
                    selected: <bool>{_showPastOrders},
                    onSelectionChanged: (value) {
                      setState(() => _showPastOrders = value.first);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          data.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, _) => AppEmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Unable to load orders',
              message: error.toString(),
            ),
            data: (state) {
              final visibleOrders = state.orders
                  .where((order) => _showPastOrders ? order.status.isPast : !order.status.isPast)
                  .toList(growable: false);
              if (visibleOrders.isEmpty) {
                return const AppEmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'No orders in this view',
                  message: 'Active and historical orders will appear here as customers place them.',
                );
              }

              return Column(
                children: [
                  for (final order in visibleOrders) ...[
                    _VendorOrderCard(
                      order: order,
                      onTap: () => context.push('/vendor/orders/${Uri.encodeComponent(order.id)}'),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _VendorOrderCard extends StatelessWidget {
  const _VendorOrderCard({required this.order, required this.onTap});

  final VendorOrder order;
  final VoidCallback onTap;

  Color _statusColor(BuildContext context) {
    switch (order.status) {
      case VendorOrderStatus.accepted:
        return context.luqmah.success;
      case VendorOrderStatus.inProgress:
        return context.luqmah.warning;
      case VendorOrderStatus.ready:
        return context.luqmah.info;
      case VendorOrderStatus.completed:
        return context.luqmah.mutedText;
      case VendorOrderStatus.cancelled:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd MMM, hh:mm a');
    final statusColor = _statusColor(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.xl),
      child: AppSurfaceCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.customerName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.xs,
                        children: [
                          _OrderMetaPill(
                            icon: Icons.receipt_long_outlined,
                            label: order.id,
                          ),
                          _OrderMetaPill(
                            icon: Icons.schedule_rounded,
                            label: formatter.format(order.dateTime),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    order.status.label,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                _OrderMetaPill(
                  icon: Icons.inventory_2_outlined,
                  label: '${order.items.length} items',
                ),
                _OrderMetaPill(
                  icon: Icons.payments_outlined,
                  label: '${order.total.toStringAsFixed(2)} JD',
                ),
              ],
            ),
            if (order.status == VendorOrderStatus.inProgress && order.estimatedReadyAt != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Expected by ${DateFormat('hh:mm a').format(order.estimatedReadyAt!)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.luqmah.info,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OrderMetaPill extends StatelessWidget {
  const _OrderMetaPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = context.luqmah;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: tokens.surfaceAlt.withValues(alpha: 0.78),
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
