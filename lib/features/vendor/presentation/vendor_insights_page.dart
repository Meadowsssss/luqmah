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
                    'Prep performance',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    data.averagePrepMinutes == null
                        ? 'Not enough recent prep-time history yet.'
                        : 'Average prep time: ${data.averagePrepMinutes} min',
                    style: Theme.of(context).textTheme.bodyMedium,
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
                    'Recommendations',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (data.restaurantAnalytics.where((insight) => insight.recommendations.isNotEmpty).isEmpty)
                    Text(
                      'Recommendations will appear once restaurants have enough recent order history.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.luqmah.mutedText,
                      ),
                    )
                  else
                    for (final insight in data.restaurantAnalytics.where((insight) => insight.recommendations.isNotEmpty)) ...[
                      Text(
                        insight.restaurantTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      for (final recommendation in insight.recommendations) ...[
                        _RecommendationCard(recommendation: recommendation),
                        if (recommendation != insight.recommendations.last)
                          const SizedBox(height: AppSpacing.sm),
                      ],
                      if (insight != data.restaurantAnalytics.where((entry) => entry.recommendations.isNotEmpty).last)
                        const SizedBox(height: AppSpacing.lg),
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
            const SizedBox(height: AppSpacing.lg),
            AppSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Restaurant analytics',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  for (final insight in data.restaurantAnalytics) ...[
                    _RestaurantAnalyticsCard(insight: insight),
                    if (insight != data.restaurantAnalytics.last)
                      const SizedBox(height: AppSpacing.md),
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

class _RestaurantAnalyticsCard extends StatelessWidget {
  const _RestaurantAnalyticsCard({required this.insight});

  final VendorRestaurantInsight insight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            insight.restaurantTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          if (!insight.hasEnoughHistory) ...[
            Text(
              insight.fallbackTitle ?? 'Not enough recent order history yet',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.luqmah.mutedText,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(insight.fallbackMessage ?? '', style: Theme.of(context).textTheme.bodySmall),
          ] else ...[
            _InsightLine(label: 'Busiest hour', value: '${insight.busiestHourLabel} · ${insight.busiestHourOrderCount} orders'),
            const SizedBox(height: AppSpacing.xs),
            _InsightLine(label: 'Slowest hour', value: '${insight.slowestHourLabel} · ${insight.slowestHourOrderCount} orders'),
            const SizedBox(height: AppSpacing.xs),
            _InsightLine(label: 'Top items in rush hour', value: insight.topItemsInBusiestHour.join(', ')),
            const SizedBox(height: AppSpacing.xs),
            _InsightLine(
              label: 'Average prep time',
              value: insight.averagePrepMinutes == null ? 'Not enough prep data' : '${insight.averagePrepMinutes} min',
            ),
            const SizedBox(height: AppSpacing.xs),
            _InsightLine(
              label: 'Peak-hour prep time',
              value: insight.peakHourPrepMinutes == null ? 'Not enough prep data' : '${insight.peakHourPrepMinutes} min',
            ),
          ],
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.recommendation});

  final VendorRestaurantRecommendation recommendation;

  IconData _icon() {
    switch (recommendation.type) {
      case VendorRestaurantRecommendationType.prepareStock:
        return Icons.schedule_rounded;
      case VendorRestaurantRecommendationType.slowHourOffer:
        return Icons.local_offer_outlined;
      case VendorRestaurantRecommendationType.strongItem:
        return Icons.trending_up_rounded;
      case VendorRestaurantRecommendationType.lowPerformingItem:
        return Icons.inventory_2_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.luqmah.surfaceAlt.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_icon(), color: context.luqmah.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recommendation.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  recommendation.message,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightLine extends StatelessWidget {
  const _InsightLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 132,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.luqmah.mutedText,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(value, style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    );
  }
}
