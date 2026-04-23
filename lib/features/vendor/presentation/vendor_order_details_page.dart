import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/luqmah_theme.dart';
import '../../../features/vendor/vendor_data_controller.dart';
import '../../../models/vendor.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_surface_card.dart';

class VendorOrderDetailsPage extends ConsumerWidget {
  const VendorOrderDetailsPage({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decodedId = Uri.decodeComponent(orderId);
    final orderAsync = ref.watch(vendorOrderByIdProvider(decodedId));

    return orderAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
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
            appBar: AppBar(),
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

        return Scaffold(
          appBar: AppBar(title: Text(order.id)),
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              AppSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.customerName, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${order.customerPhone} · ${formatter.format(order.dateTime)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppSurfaceCard(
                child: Column(
                  children: [
                    for (final item in order.items) ...[
                      _OrderItemRow(item: item),
                      if (item != order.items.last) const Divider(),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<VendorOrderStatus>(
                      initialValue: order.status,
                      items: VendorOrderStatus.values
                          .map(
                            (status) => DropdownMenuItem(
                              value: status,
                              child: Text(status.label),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (value) async {
                        if (value != null) {
                          await ref
                              .read(vendorDataControllerProvider.notifier)
                              .updateOrderStatus(order.id, value);
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _SummaryRow(label: 'Subtotal', value: '${order.subtotal.toStringAsFixed(2)} JD'),
                    const SizedBox(height: AppSpacing.sm),
                    _SummaryRow(
                      label: 'Coupon',
                      value: order.coupon == 0
                          ? '0 JD'
                          : '-${order.coupon.abs().toStringAsFixed(2)} JD',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _SummaryRow(
                      label: 'Grand total',
                      value: '${order.total.toStringAsFixed(2)} JD',
                      strong: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
                Text(item.extras.join(', '), style: Theme.of(context).textTheme.bodySmall),
              ],
            ],
          ),
        ),
        Text('x${item.quantity}', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(width: AppSpacing.lg),
        Text(
          '${item.lineTotal.toStringAsFixed(0)} JD',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value, this.strong = false});

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final style = strong
        ? Theme.of(context).textTheme.titleMedium
        : Theme.of(context).textTheme.bodyMedium;
    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(value, style: style),
      ],
    );
  }
}
