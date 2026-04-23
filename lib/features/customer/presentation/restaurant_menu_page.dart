import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/luqmah_theme.dart';
import '../../../features/customer/cart/cart_controller.dart';
import '../../../features/customer/data/restaurant_repository.dart';
import '../../../models/restaurant.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_surface_card.dart';

class RestaurantMenuPage extends ConsumerStatefulWidget {
  const RestaurantMenuPage({super.key, required this.restaurantId});

  final String restaurantId;

  @override
  ConsumerState<RestaurantMenuPage> createState() => _RestaurantMenuPageState();
}

class _RestaurantMenuPageState extends ConsumerState<RestaurantMenuPage> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final restaurant = ref.watch(restaurantByIdProvider(widget.restaurantId));

    if (restaurant == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: AppEmptyState(
            icon: Icons.storefront_outlined,
            title: 'Restaurant not found',
            message: 'This restaurant is no longer available in the current mock data.',
          ),
        ),
      );
    }

    final categories = <String>{'Most Selling'}
      ..addAll(restaurant.menu.map((item) => item.category));
    final selectedCategory = _selectedCategory ?? categories.first;

    final visibleItems = selectedCategory == 'Most Selling'
        ? restaurant.menu.where((item) => item.isMostSelling).toList(growable: false)
        : restaurant.menu
              .where((item) => item.category == selectedCategory)
              .toList(growable: false);

    final items = visibleItems.isEmpty ? restaurant.menu : visibleItems;

    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Text(restaurant.name, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            restaurant.tags.join(' · '),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context.luqmah.mutedText,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const Icon(Icons.star_rounded, size: 18, color: AppColors.accent),
              const SizedBox(width: 4),
              Text(
                restaurant.rating,
                style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.accent),
              ),
              const SizedBox(width: 12),
              Text(
                restaurant.time,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.xl),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                restaurant.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.surfaceAlt,
                  alignment: Alignment.center,
                  child: const Icon(Icons.image_not_supported_outlined),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = categories.elementAt(index);
                final selected = category == selectedCategory;

                return ChoiceChip(
                  label: Text(category),
                  selected: selected,
                  onSelected: (_) {
                    setState(() => _selectedCategory = category);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          for (final item in items) ...[
            _MenuItemCard(item: item),
            const SizedBox(height: AppSpacing.lg),
          ],
        ],
      ),
    );
  }
}

class _MenuItemCard extends ConsumerWidget {
  const _MenuItemCard({required this.item});

  final MenuItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartControllerProvider);
    final quantity = cart.quantities[item.id] ?? 0;

    return AppSurfaceCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  item.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.luqmah.mutedText,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  '${item.price.toStringAsFixed(2)} JD',
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (quantity == 0)
                  SizedBox(
                    width: 140,
                    child: ElevatedButton(
                      onPressed: () {
                        ref.read(cartControllerProvider.notifier).addItem(item);
                      },
                      child: const Text('Add to cart'),
                    ),
                  )
                else
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          ref.read(cartControllerProvider.notifier).removeItem(item.id);
                        },
                        icon: const Icon(Icons.remove_circle_outline_rounded),
                      ),
                      Text(
                        '$quantity',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      IconButton(
                        onPressed: () {
                          ref.read(cartControllerProvider.notifier).addItem(item);
                        },
                        icon: const Icon(Icons.add_circle_outline_rounded),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            child: SizedBox(
              height: 96,
              width: 96,
              child: Image.network(
                item.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.surfaceAlt,
                  alignment: Alignment.center,
                  child: const Icon(Icons.fastfood_rounded),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
