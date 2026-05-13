import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/luqmah_theme.dart';
import '../../../features/vendor/vendor_data_controller.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_surface_card.dart';

class VendorProductsPage extends ConsumerWidget {
  const VendorProductsPage({super.key});

  Future<void> _toggleAvailability(
    BuildContext context,
    WidgetRef ref,
    String itemId,
    bool isAvailable,
  ) async {
    try {
      await ref.read(vendorDataControllerProvider.notifier).toggleMenuItemAvailability(
            itemId,
            !isAvailable,
          );
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(!isAvailable ? 'Product is now visible.' : 'Product hidden from customers.')),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _deleteItem(BuildContext context, WidgetRef ref, String itemId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete product?'),
        content: const Text(
          'This permanently removes the product from your menu. Past orders keep their saved item snapshot.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: context.luqmah.warning),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      await ref.read(vendorDataControllerProvider.notifier).deleteMenuItem(itemId);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted permanently.')),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

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
                               Container(
                                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                 decoration: BoxDecoration(
                                   color: item.isAvailable
                                       ? AppColors.primary.withValues(alpha: 0.08)
                                       : AppColors.surfaceAlt,
                                   borderRadius: BorderRadius.circular(999),
                                 ),
                                 child: Text(
                                   item.isAvailable ? 'Available' : 'Hidden',
                                   style: TextStyle(
                                     color: item.isAvailable ? AppColors.primary : context.luqmah.mutedText,
                                     fontWeight: FontWeight.w700,
                                   ),
                                 ),
                               ),
                               const SizedBox(width: AppSpacing.sm),
                               Text(
                                 '${item.price.toStringAsFixed(2)} JD',
                                 style: const TextStyle(
                                   color: AppColors.accent,
                                   fontWeight: FontWeight.w800,
                                 ),
                               ),
                               PopupMenuButton<String>(
                                 onSelected: (value) async {
                                   switch (value) {
                                     case 'edit':
                                       await context.push('/vendor/products/${item.id}/edit');
                                       break;
                                     case 'availability':
                                       await _toggleAvailability(context, ref, item.id, item.isAvailable);
                                       break;
                                     case 'delete':
                                       await _deleteItem(context, ref, item.id);
                                       break;
                                   }
                                 },
                                 itemBuilder: (context) => [
                                   const PopupMenuItem<String>(
                                     value: 'edit',
                                     child: Text('Edit'),
                                   ),
                                   PopupMenuItem<String>(
                                     value: 'availability',
                                     child: Text(item.isAvailable ? 'Hide' : 'Show'),
                                   ),
                                   const PopupMenuItem<String>(
                                     value: 'delete',
                                     child: Text('Delete'),
                                   ),
                                 ],
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
                          if (item.customizations.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              item.customizations.map((customization) => customization.label).join(', '),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: context.luqmah.mutedText,
                              ),
                            ),
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
