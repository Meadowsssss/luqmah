import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/luqmah_theme.dart';
import '../../../features/customer/data/restaurant_repository.dart';
import '../../../models/restaurant.dart';
import '../../../shared/widgets/app_empty_state.dart';

class RestaurantsPage extends ConsumerWidget {
  const RestaurantsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurants = ref.watch(restaurantsProvider);
    final textTheme = Theme.of(context).textTheme;
    final tokens = context.luqmah;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Luqmah',
              style: textTheme.titleLarge?.copyWith(color: tokens.primary),
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
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: tokens.surface,
              borderRadius: BorderRadius.circular(AppRadii.xl),
              border: Border.all(color: tokens.border),
              boxShadow: [
                BoxShadow(
                  color: tokens.primary.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -26,
                  right: -20,
                  child: Container(
                    height: 132,
                    width: 132,
                    decoration: BoxDecoration(
                      color: tokens.primary.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  right: -28,
                  bottom: 12,
                  child: Transform.rotate(
                    angle: -0.32,
                    child: Container(
                      height: 18,
                      width: 118,
                      decoration: BoxDecoration(
                        color: tokens.primary.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(999),
                      ),
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
                        color: tokens.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'On campus now',
                        style: TextStyle(
                          color: tokens.primary,
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
                        'Clean, premium campus picks curated for quick ordering.',
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
    final tokens = context.luqmah;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.xl),
      child: Container(
        height: 168,
        decoration: BoxDecoration(
          color: const Color(0xFF101510),
          borderRadius: BorderRadius.circular(AppRadii.xl),
          border: Border.all(color: tokens.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              restaurant.image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: tokens.surfaceAlt,
                alignment: Alignment.center,
                child: Icon(Icons.restaurant_rounded, color: tokens.mutedText),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Colors.black.withValues(alpha: 0.08),
                    Colors.black.withValues(alpha: 0.34),
                    Colors.black.withValues(alpha: 0.80),
                  ],
                ),
              ),
            ),
            Positioned(
              right: -20,
              top: 18,
              child: Transform.rotate(
                angle: -0.24,
                child: Container(
                  height: 10,
                  width: 112,
                  decoration: BoxDecoration(
                    color: tokens.primary.withValues(alpha: 0.82),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
            Positioned(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: AppSpacing.lg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    restaurant.name,
                    style: textTheme.titleMedium?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    restaurant.tags.take(3).join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.78),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: Color(0xFFD1A340),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        restaurant.ratingCount > 0
                            ? '${restaurant.rating} (${restaurant.ratingCount})'
                            : restaurant.rating,
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '· ${restaurant.estimatedPrepMinutes}-${restaurant.estimatedPrepMinutes + 10} min',
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.76),
                        ),
                      ),
                      if (restaurant.isBusy) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          '· Busy',
                          style: textTheme.bodySmall?.copyWith(
                            color: tokens.warning,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ],
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
