import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/luqmah_theme.dart';
import '../../../features/vendor/vendor_data_controller.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_surface_card.dart';

class VendorProductsPage extends ConsumerWidget {
  const VendorProductsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(vendorDataControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/vendor/products/new'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add item'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Menu management', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Add and review menu items with the same Luqmah design system used on the customer side.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.luqmah.mutedText,
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
              title: 'Unable to load products',
              message: error.toString(),
            ),
            data: (state) {
              final items = state.menuItems;
              if (items.isEmpty) {
                return const AppEmptyState(
                  icon: Icons.soup_kitchen_outlined,
                  title: 'No products yet',
                  message: 'Add your first vendor item to publish it to the customer menu.',
                );
              }

              return Column(
                children: [
                  for (final item in items) ...[
                    AppSurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(item.title, style: Theme.of(context).textTheme.titleMedium),
                              ),
                              Text(
                                '${item.price.toStringAsFixed(2)} JD',
                                style: const TextStyle(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            '${item.restaurantTitle} · ${item.category}${item.isAvailable ? '' : ' · Unavailable'}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          if (item.description.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.sm),
                            Text(item.description),
                          ],
                          if (item.ingredients.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.sm),
                            Text(item.ingredients.join(', ')),
                          ],
                        ],
                      ),
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
