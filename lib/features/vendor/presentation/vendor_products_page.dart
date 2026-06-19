import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/luqmah_theme.dart';
import '../../../features/vendor/vendor_data_controller.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_surface_card.dart';
import '../../../shared/widgets/premium_page_app_bar.dart';

class VendorProductsPage extends ConsumerStatefulWidget {
  const VendorProductsPage({super.key});

  @override
  ConsumerState<VendorProductsPage> createState() => _VendorProductsPageState();
}

class _VendorProductsPageState extends ConsumerState<VendorProductsPage> {
  static const _allCategory = 'All';

  String _selectedCategoryId = _allCategory;
  bool _isScrolled = false;

  void _handleScroll(double offset) {
    final next = offset > 0;
    if (next == _isScrolled) {
      return;
    }
    setState(() => _isScrolled = next);
  }

  Future<void> _toggleAvailability(
    BuildContext context,
    WidgetRef ref,
    String itemId,
    bool isAvailable,
  ) async {
    try {
      await ref
          .read(vendorDataControllerProvider.notifier)
          .toggleMenuItemAvailability(itemId, !isAvailable);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            !isAvailable
                ? 'Product is now visible.'
                : 'Product hidden from customers.',
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  Future<void> _deleteItem(
    BuildContext context,
    WidgetRef ref,
    String itemId,
  ) async {
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
            style: ElevatedButton.styleFrom(
              backgroundColor: context.luqmah.warning,
            ),
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
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(vendorDataControllerProvider);

    return Scaffold(
      appBar: PremiumPageAppBar(
        icon: Icons.restaurant_menu_rounded,
        title: 'Products',
        subtitle: 'Add dishes, update items, and keep your menu ready to order from.',
        isScrolled: _isScrolled,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/vendor/products/new'),
        backgroundColor: context.luqmah.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add item'),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          _handleScroll(notification.metrics.pixels);
          return false;
        },
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
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
                final categoryEntries = <MapEntry<String, String>>[
                  const MapEntry(_allCategory, _allCategory),
                  ...{
                    for (final item in items) item.categoryId: item.category,
                  }.entries,
                ];
                final effectiveSelectedCategoryId = categoryEntries.any(
                      (entry) => entry.key == _selectedCategoryId,
                    )
                    ? _selectedCategoryId
                    : _allCategory;
                final selectedCategoryTitle = categoryEntries
                    .firstWhere(
                      (entry) => entry.key == effectiveSelectedCategoryId,
                    )
                    .value;
                final visibleItems = effectiveSelectedCategoryId == _allCategory
                    ? items
                    : items
                        .where(
                          (item) => item.categoryId == effectiveSelectedCategoryId,
                        )
                        .toList(growable: false);

                if (items.isEmpty) {
                  return const AppEmptyState(
                    icon: Icons.soup_kitchen_outlined,
                    title: 'No products yet',
                    message:
                        'Add your first vendor item to publish it to the customer menu.',
                  );
                }

                return Column(
                  children: [
                    SizedBox(
                      height: 42,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: categoryEntries.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final category = categoryEntries[index];
                          return ChoiceChip(
                            backgroundColor: Colors.transparent,
                            selectedColor: Colors.transparent,
                            side: BorderSide(
                              color: effectiveSelectedCategoryId == category.key
                                  ? context.luqmah.primary.withValues(alpha: 0.45)
                                  : context.luqmah.border,
                            ),
                            labelStyle: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: effectiveSelectedCategoryId == category.key
                                      ? context.luqmah.primary
                                      : context.luqmah.strongText,
                                  fontWeight: FontWeight.w700,
                                ),
                            label: Text(category.value),
                            selected: effectiveSelectedCategoryId == category.key,
                            onSelected: (_) {
                              setState(() => _selectedCategoryId = category.key);
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (visibleItems.isEmpty)
                      AppEmptyState(
                        icon: Icons.inventory_2_outlined,
                        title: 'No products in $selectedCategoryTitle',
                        message:
                            'Add an item in this category or switch filters to review the rest of the menu.',
                      )
                    else ...[
                      for (final item in visibleItems) ...[
                        AppSurfaceCard(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _ProductThumb(imageUrl: item.image),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          style: Theme.of(context).textTheme.titleMedium,
                                        ),
                                        const SizedBox(height: AppSpacing.xs),
                                        Wrap(
                                          spacing: AppSpacing.sm,
                                          runSpacing: AppSpacing.xs,
                                          children: [
                                            _ProductMetaPill(
                                              icon: Icons.storefront_outlined,
                                              label: item.restaurantTitle,
                                            ),
                                            _ProductMetaPill(
                                              icon: Icons.label_outline_rounded,
                                              label: item.category,
                                            ),
                                          ],
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
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: item.isAvailable
                                            ? context.luqmah.primary.withValues(alpha: 0.4)
                                            : context.luqmah.border,
                                      ),
                                    ),
                                    child: Text(
                                      item.isAvailable ? 'Available' : 'Hidden',
                                      style: TextStyle(
                                        color: item.isAvailable
                                            ? context.luqmah.primary
                                            : context.luqmah.mutedText,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Text(
                                    '${item.price.toStringAsFixed(2)} JD',
                                    style: TextStyle(
                                      color: context.luqmah.accent,
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
                                          await _toggleAvailability(
                                            context,
                                            ref,
                                            item.id,
                                            item.isAvailable,
                                          );
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
                              if (item.description.isNotEmpty) ...[
                                const SizedBox(height: AppSpacing.sm),
                                Text(item.description),
                              ],
                              if (item.ingredients.isNotEmpty) ...[
                                const SizedBox(height: AppSpacing.sm),
                                Text(item.ingredients.join(', ')),
                              ],
                              if (item.optionGroups.isNotEmpty) ...[
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  item.optionGroups
                                      .map(
                                        (group) =>
                                            '${group.title}: ${group.options.map((option) => option.label).join(', ')}',
                                      )
                                      .join(' | '),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: context.luqmah.mutedText),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductThumb extends StatelessWidget {
  const _ProductThumb({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: Container(
        height: 58,
        width: 58,
        color: context.luqmah.surfaceAlt,
        child: imageUrl.isEmpty
            ? Icon(Icons.fastfood_rounded, color: context.luqmah.primary)
            : Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.fastfood_rounded, color: context.luqmah.primary),
              ),
      ),
    );
  }
}

class _ProductMetaPill extends StatelessWidget {
  const _ProductMetaPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = context.luqmah;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tokens.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: tokens.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: tokens.strongText,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
