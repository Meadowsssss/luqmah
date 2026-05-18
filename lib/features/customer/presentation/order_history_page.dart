import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/luqmah_theme.dart';
import '../../../features/customer/orders/customer_orders_controller.dart';
import '../../../models/customer_order.dart';
import '../../../models/vendor.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_surface_card.dart';
import 'order_rating_dialog.dart';

class OrderHistoryPage extends ConsumerWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(customerOrdersControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Order history')),
      body: orders.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: AppEmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Unable to load orders',
            message: error.toString(),
          ),
        ),
        data: (data) {
          if (data.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: AppEmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'No orders yet',
                message:
                    'Orders saved from checkout will appear here with their latest status.',
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemBuilder: (context, index) =>
                _OrderHistoryCard(order: data[index]),
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.lg),
            itemCount: data.length,
          );
        },
      ),
    );
  }
}

class _OrderHistoryCard extends ConsumerWidget {
  const _OrderHistoryCard({required this.order});

  final CustomerOrder order;

  Future<void> _cancelOrder(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel order?'),
        content: const Text(
          'This order is still in queue. Do you want to cancel it?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep order'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Cancel order'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      await ref
          .read(customerOrdersControllerProvider.notifier)
          .cancelOrder(order);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Order cancelled.')));
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> _rateOrder(BuildContext context, WidgetRef ref) async {
    final result = await showOrderRatingDialog(
      context: context,
      order: order,
      allowLater: false,
    );

    if (result?.score == null) {
      return;
    }

    try {
      await ref
          .read(customerOrdersControllerProvider.notifier)
          .rateOrder(order: order, score: result!.score!);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Rating saved.')));
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatter = DateFormat('dd MMM yyyy, hh:mm a');
    final statusColor = switch (order.status) {
      VendorOrderStatus.accepted => context.luqmah.success,
      VendorOrderStatus.inProgress => context.luqmah.warning,
      VendorOrderStatus.ready => context.luqmah.info,
      VendorOrderStatus.completed => context.luqmah.mutedText,
      VendorOrderStatus.cancelled => AppColors.error,
    };
    final tokens = context.luqmah;

    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.restaurantName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      order.id,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  order.status.label,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _OrderProgressTrack(status: order.status, color: statusColor),
          const SizedBox(height: AppSpacing.md),
          Text(
            formatter.format(order.placedAt),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (order.status == VendorOrderStatus.inProgress &&
              order.estimatedReadyAt != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Expected by ${DateFormat('hh:mm a').format(order.estimatedReadyAt!)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.luqmah.info,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: tokens.surfaceAlt.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(color: tokens.border),
            ),
            child: Column(
              children: [
                for (final item in order.items) ...[
                  Row(
                    children: [
                      Expanded(child: Text('${item.name} x${item.quantity}')),
                      Text('${item.lineTotal.toStringAsFixed(2)} JD'),
                    ],
                  ),
                  if (item != order.items.last)
                    const SizedBox(height: AppSpacing.sm),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Total',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '${order.total.toStringAsFixed(2)} JD',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: AppColors.accent),
              ),
            ],
          ),
          if (order.status == VendorOrderStatus.accepted) ...[
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton.icon(
              onPressed: () => _cancelOrder(context, ref),
              icon: const Icon(Icons.close_rounded),
              label: const Text('Cancel order'),
            ),
          ],
          if (order.status == VendorOrderStatus.completed) ...[
            const SizedBox(height: AppSpacing.lg),
            if (order.hasRating)
              _SavedRating(score: order.ratingScore!)
            else
              OutlinedButton.icon(
                onPressed: () => _rateOrder(context, ref),
                icon: const Icon(Icons.star_border_rounded),
                label: const Text('Rate order'),
              ),
          ],
        ],
      ),
    );
  }
}

class _OrderProgressTrack extends StatelessWidget {
  const _OrderProgressTrack({required this.status, required this.color});

  final VendorOrderStatus status;
  final Color color;

  int get _index {
    return switch (status) {
      VendorOrderStatus.accepted => 0,
      VendorOrderStatus.inProgress => 1,
      VendorOrderStatus.ready => 2,
      VendorOrderStatus.completed => 3,
      VendorOrderStatus.cancelled => -1,
    };
  }

  @override
  Widget build(BuildContext context) {
    final labels = const ['Confirmed', 'Preparing', 'Ready', 'Done'];
    final activeIndex = _index;

    return Row(
      children: [
        for (var index = 0; index < labels.length; index++) ...[
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: activeIndex >= index ? color : context.luqmah.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  labels[index],
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (index != labels.length - 1) const SizedBox(width: AppSpacing.xs),
        ],
      ],
    );
  }
}

class _SavedRating extends StatelessWidget {
  const _SavedRating({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Your rating',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(width: AppSpacing.sm),
        for (var index = 1; index <= 5; index++)
          Icon(
            index <= score ? Icons.star_rounded : Icons.star_border_rounded,
            size: 18,
            color: const Color(0xFFD1A340),
          ),
      ],
    );
  }
}
