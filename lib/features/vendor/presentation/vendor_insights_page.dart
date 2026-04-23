import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/luqmah_theme.dart';
import '../../../features/vendor/vendor_data_controller.dart';
import '../../../shared/widgets/app_surface_card.dart';

class VendorInsightsPage extends ConsumerWidget {
  const VendorInsightsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insights = ref.watch(vendorInsightsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Active',
                  value: '${insights.activeOrders}',
                  accent: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: _StatCard(
                  label: 'Completed',
                  value: '${insights.completedOrders}',
                  accent: context.luqmah.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Revenue',
                  value: '${insights.totalRevenue.toStringAsFixed(0)} JD',
                  accent: AppColors.accent,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: _StatCard(
                  label: 'Avg order',
                  value: '${insights.averageOrderValue.toStringAsFixed(0)} JD',
                  accent: context.luqmah.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Top items', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppSpacing.md),
                if (insights.topItems.isEmpty)
                  Text(
                    'Top sellers will appear once more mock order activity is recorded.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.luqmah.mutedText,
                    ),
                  )
                else
                  for (final item in insights.topItems) ...[
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          '${item.quantity} sold · ${item.revenue.toStringAsFixed(0)} JD',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    if (item != insights.topItems.last) const Divider(height: 24),
                  ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: accent),
          ),
        ],
      ),
    );
  }
}
