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
    final orders = ref.watch(vendorDataControllerProvider).orders;
    final visibleOrders = orders
        .where((order) => _showPastOrders ? order.status.isPast : !order.status.isPast)
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vendor workspace', style: Theme.of(context).textTheme.titleLarge),
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
                Text('Order queue', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Track what is active now and move completed orders into history.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.luqmah.mutedText,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment<bool>(value: false, label: Text('Active')),
                    ButtonSegment<bool>(value: true, label: Text('History')),
                  ],
                  selected: <bool>{_showPastOrders},
                  onSelectionChanged: (value) {
                    setState(() => _showPastOrders = value.first);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (visibleOrders.isEmpty)
            const AppEmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No orders in this view',
              message: 'New orders and completed orders will appear here as the mock data changes.',
            )
          else
            for (final order in visibleOrders) ...[
              _VendorOrderCard(
                order: order,
                onTap: () => context.push('/vendor/orders/${Uri.encodeComponent(order.id)}'),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.id, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${order.customerName} · ${formatter.format(order.dateTime)}',
                        style: Theme.of(context).textTheme.bodySmall,
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
            Text(
              '${order.items.length} items · ${order.total.toStringAsFixed(0)} JD',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
