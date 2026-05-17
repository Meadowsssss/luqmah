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
      body: insights.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) => ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            AppSurfaceCard(
              child: Row(
                children: [
                  Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      color: context.luqmah.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: Icon(
                      Icons.bar_chart_rounded,
                      color: context.luqmah.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Performance',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'A clean pulse check for today and recent orders.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Active',
                    value: '${data.activeOrders}',
                    accent: context.luqmah.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: _StatCard(
                    label: 'Completed',
                    value: '${data.completedOrders}',
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
                    value: '${data.totalRevenue.toStringAsFixed(2)} JD',
                    accent: context.luqmah.accent,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: _StatCard(
                    label: 'Avg order',
                    value: '${data.averageOrderValue.toStringAsFixed(2)} JD',
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
                  Text(
                    'Top items',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (data.topItems.isEmpty)
                    Text(
                      'Top sellers will appear once real order activity is recorded.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.luqmah.mutedText,
                      ),
                    )
                  else
                    for (final item in data.topItems) ...[
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          Text(
                            '${item.quantity} sold · ${item.revenue.toStringAsFixed(2)} JD',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      if (item != data.topItems.last) const Divider(height: 24),
                    ],
                ],
              ),
            ),
          ],
        ),
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
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: accent),
          ),
        ],
      ),
    );
  }
}
