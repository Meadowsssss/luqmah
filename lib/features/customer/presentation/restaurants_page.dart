import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/luqmah_theme.dart';
import '../../../features/customer/data/restaurant_repository.dart';
import '../../../models/restaurant.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_surface_card.dart';

class RestaurantsPage extends ConsumerWidget {
  const RestaurantsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurants = ref.watch(restaurantsProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Luqmah',
              style: textTheme.titleLarge?.copyWith(color: AppColors.primary),
            ),
            Text(
              'Campus favourites, ready when you are',
              style: textTheme.bodySmall,
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.hero),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  blurRadius: 30,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -16,
                  right: -12,
                  child: Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  right: 18,
                  bottom: -18,
                  child: Container(
                    height: 88,
                    width: 88,
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceAlt,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'On campus now',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 290),
                      child: Text(
                        'Good food. Great mood. On campus.',
                        style: textTheme.headlineMedium,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: Text(
                        'Discover warm bowls, quick bites, and all-day favorites from nearby restaurant partners.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: context.luqmah.mutedText,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          restaurants.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => AppEmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Unable to load restaurants',
              message: error.toString(),
            ),
            data: (items) {
              if (items.isEmpty) {
                return const AppEmptyState(
                  icon: Icons.storefront_outlined,
                  title: 'No restaurants yet',
                  message:
                      'Restaurants will appear here after vendors are onboarded and published.',
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Popular restaurants',
                              style: textTheme.titleLarge,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Premium campus picks curated for quick ordering.',
                              style: textTheme.bodyMedium?.copyWith(
                                color: context.luqmah.mutedText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('See all'),
                      ),
                    ],
                  ),
                  for (final restaurant in items) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _RestaurantCard(
                      restaurant: restaurant,
                      onTap: () =>
                          context.push('/restaurants/${restaurant.id}'),
                    ),
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

class _RestaurantCard extends StatelessWidget {
  const _RestaurantCard({required this.restaurant, required this.onTap});

  final Restaurant restaurant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final detailColor = context.luqmah.mutedText;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.xl),
      child: AppSurfaceCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadii.xl),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      restaurant.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.surfaceAlt,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.restaurant_rounded,
                            size: 38,
                            color: AppColors.mutedText,
                          ),
                        );
                      },
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.04),
                            Colors.black.withValues(alpha: 0.58),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: AppSpacing.lg,
                      right: AppSpacing.lg,
                      bottom: AppSpacing.lg,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            restaurant.name,
                            style: textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            restaurant.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.86),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (restaurant.isBusy)
                      Positioned(
                        top: AppSpacing.lg,
                        left: AppSpacing.lg,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Busy now',
                            style: TextStyle(
                              color: context.luqmah.warning,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          restaurant.time,
                          style: textTheme.bodySmall?.copyWith(
                            color: detailColor,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.star_rounded,
                        size: 18,
                        color: Color(0xFFD1A340),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        restaurant.rating,
                        style: textTheme.bodySmall?.copyWith(
                          color: detailColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: restaurant.tags
                        .take(2)
                        .map(
                          (tag) => Chip(
                            label: Text(tag),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                        )
                        .toList(growable: false),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
