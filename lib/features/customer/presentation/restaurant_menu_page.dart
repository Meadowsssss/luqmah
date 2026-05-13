import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
  static const _busyMessage =
      'This restaurant is busy right now. You can browse the menu, but ordering is temporarily unavailable.';
  static const _allCategories = 'All';

  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final restaurantAsync = ref.watch(
      restaurantByIdProvider(widget.restaurantId),
    );
    final textTheme = Theme.of(context).textTheme;

    return restaurantAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: AppEmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Unable to load menu',
            message: error.toString(),
          ),
        ),
      ),
      data: (restaurant) {
        if (restaurant == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: AppEmptyState(
                icon: Icons.storefront_outlined,
                title: 'Restaurant not found',
                message: 'This restaurant is no longer available.',
              ),
            ),
          );
        }

        final categories = restaurant.menu
            .map((item) => item.category)
            .toSet()
            .toList(growable: false);
        final categoryOptions = categories.isEmpty
            ? const <String>[]
            : <String>[_allCategories, ...categories];
        final selectedCategory =
            _selectedCategory ??
            (categoryOptions.isEmpty ? null : _allCategories);
        final items =
            selectedCategory == null || selectedCategory == _allCategories
            ? restaurant.menu
            : restaurant.menu
                  .where((item) => item.category == selectedCategory)
                  .toList(growable: false);
        final cart = ref.watch(cartControllerProvider);
        final cartTotal = ref.watch(cartTotalProvider);
        final showCheckoutButton =
            cart.itemCount > 0 && cart.activeRestaurantId == restaurant.id;

        return Scaffold(
          appBar: AppBar(),
          body: Stack(
            children: [
              RefreshIndicator(
                onRefresh: () => ref.refresh(
                  restaurantByIdProvider(widget.restaurantId).future,
                ),
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    showCheckoutButton ? 112 : 24,
                  ),
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadii.hero),
                      child: AspectRatio(
                        aspectRatio: 16 / 11,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              restaurant.image,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: AppColors.surfaceAlt,
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.image_not_supported_outlined,
                                    ),
                                  ),
                            ),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.06),
                                    Colors.black.withValues(alpha: 0.62),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              left: AppSpacing.xl,
                              right: AppSpacing.xl,
                              bottom: AppSpacing.xl,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.92,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                        ),
                                        child: Text(
                                          restaurant.isBusy
                                              ? 'Busy now'
                                              : 'Open now',
                                          style: TextStyle(
                                            color: restaurant.isBusy
                                                ? context.luqmah.warning
                                                : AppColors.primary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  Text(
                                    restaurant.name,
                                    style: textTheme.headlineMedium?.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    restaurant.description,
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.86,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    restaurant.time,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.82,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.star_rounded,
                                        size: 18,
                                        color: Color(0xFFD1A340),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        restaurant.ratingCount > 0
                                            ? '${restaurant.rating} (${restaurant.ratingCount})'
                                            : restaurant.rating,
                                        style: textTheme.bodySmall?.copyWith(
                                          color: Colors.white.withValues(
                                            alpha: 0.82,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (restaurant.isBusy) ...[
                      const SizedBox(height: AppSpacing.lg),
                      AppSurfaceCard(
                        child: Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              color: context.luqmah.warning,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                _busyMessage,
                                style: textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (categoryOptions.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xl),
                      SizedBox(
                        height: 42,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: categoryOptions.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final category = categoryOptions[index];
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
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Menu', style: textTheme.titleLarge),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'Prepared fresh for today\'s service.',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: context.luqmah.mutedText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (items.isEmpty)
                      const AppEmptyState(
                        icon: Icons.no_food_outlined,
                        title: 'No menu items yet',
                        message:
                            'This restaurant has not published any available menu items yet.',
                      )
                    else
                      for (final item in items) ...[
                        _MenuItemCard(
                          item: item,
                          restaurantId: restaurant.id,
                          restaurantName: restaurant.name,
                          restaurantIsBusy: restaurant.isBusy,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _CheckoutFloatingButton(
                  total: cartTotal,
                  visible: showCheckoutButton,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CheckoutFloatingButton extends StatelessWidget {
  const _CheckoutFloatingButton({required this.total, required this.visible});

  final double total;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: IgnorePointer(
        ignoring: !visible,
        child: AnimatedSlide(
          offset: visible ? Offset.zero : const Offset(0, 0.08),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: AnimatedOpacity(
            opacity: visible ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/cart'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  elevation: 12,
                  shadowColor: AppColors.success.withValues(alpha: 0.28),
                  minimumSize: const Size.fromHeight(58),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                icon: const Icon(Icons.shopping_bag_rounded),
                label: Text('Checkout • ${total.toStringAsFixed(2)} JD'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuItemCard extends ConsumerWidget {
  const _MenuItemCard({
    required this.item,
    required this.restaurantId,
    required this.restaurantName,
    required this.restaurantIsBusy,
  });

  final MenuItem item;
  final String restaurantId;
  final String restaurantName;
  final bool restaurantIsBusy;

  static const _busyMessage =
      'This restaurant is busy right now. You can browse the menu, but ordering is temporarily unavailable.';

  Future<void> _showBusyMessage(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Restaurant busy'),
        content: const Text(_busyMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAddPressed(BuildContext context, WidgetRef ref) async {
    if (restaurantIsBusy) {
      await _showBusyMessage(context);
      return;
    }

    final controller = ref.read(cartControllerProvider.notifier);
    final cart = ref.read(cartControllerProvider);
    final added = controller.addItem(
      item,
      restaurantId: restaurantId,
      restaurantName: restaurantName,
    );

    if (added) {
      return;
    }

    final existingRestaurantName =
        cart.activeRestaurantName ?? 'another restaurant';
    final shouldReplace = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Switch restaurant?'),
          content: Text(
            'Your cart already contains items from $existingRestaurantName. Clear the cart and add this item from $restaurantName instead?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Clear cart and add'),
            ),
          ],
        );
      },
    );

    if (shouldReplace == true) {
      controller.replaceWithItem(
        item,
        restaurantId: restaurantId,
        restaurantName: restaurantName,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartControllerProvider);
    final quantity = cart.items[item.id]?.quantity ?? 0;
    final textTheme = Theme.of(context).textTheme;

    return AppSurfaceCard(
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            child: SizedBox(
              height: 88,
              width: 88,
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
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  item.category,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    color: context.luqmah.mutedText,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  '${item.price.toStringAsFixed(2)} JD',
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          if (quantity == 0)
            IconButton.filled(
              onPressed: () => _handleAddPressed(context, ref),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              icon: Icon(
                restaurantIsBusy ? Icons.schedule_rounded : Icons.add_rounded,
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      ref
                          .read(cartControllerProvider.notifier)
                          .removeItem(item.id);
                    },
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.remove_rounded),
                  ),
                  Text(
                    '$quantity',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  IconButton(
                    onPressed: () => _handleAddPressed(context, ref),
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.add_rounded),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
