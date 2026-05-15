import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/luqmah_theme.dart';
import '../../../core/network/api_client.dart';
import '../../../features/customer/cart/cart_controller.dart';
import '../../../features/customer/data/restaurant_repository.dart';
import '../../../features/customer/orders/customer_orders_controller.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_surface_card.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  static const _busyMessage =
      'This restaurant is busy right now. You can browse the menu, but ordering is temporarily unavailable.';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lines = ref.watch(cartLinesProvider);
    final total = ref.watch(cartTotalProvider);
    final restaurantAsync = lines.isEmpty
        ? null
        : ref.watch(restaurantByIdProvider(lines.first.item.restaurantId));
    final isBusy = restaurantAsync?.valueOrNull?.isBusy ?? false;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Your cart')),
      body: SafeArea(
        child: lines.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: AppEmptyState(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Your cart is empty',
                  message:
                      'Add a few favourites from campus restaurants to get started.',
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      children: [
                        AppSurfaceCard(
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Your cart',
                                      style: textTheme.titleLarge,
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      'Review your items before placing the order.',
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: context.luqmah.mutedText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.08,
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  '${lines.length} items',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        for (final line in lines) ...[
                          AppSurfaceCard(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    AppRadii.lg,
                                  ),
                                  child: SizedBox(
                                    height: 84,
                                    width: 84,
                                    child: Image.network(
                                      line.item.image,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                color: AppColors.surfaceAlt,
                                                alignment: Alignment.center,
                                                child: const Icon(
                                                  Icons.fastfood_rounded,
                                                ),
                                              ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.lg),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        line.item.name,
                                        style: textTheme.titleMedium,
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      Text(
                                        line.item.restaurantName,
                                        style: textTheme.bodySmall,
                                      ),
                                      if (line.item.selectedOptions.isNotEmpty) ...[
                                        const SizedBox(height: AppSpacing.xs),
                                        Text(
                                          line.item.selectedOptions
                                              .map((option) => '${option.groupTitle}: ${option.title}')
                                              .join(', '),
                                          style: textTheme.bodySmall?.copyWith(
                                            color: context.luqmah.mutedText,
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: AppSpacing.sm),
                                      Text(
                                        '${line.item.price.toStringAsFixed(2)} JD each',
                                        style: textTheme.bodySmall?.copyWith(
                                          color: context.luqmah.mutedText,
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.md),
                                      Text(
                                        '${line.lineTotal.toStringAsFixed(2)} JD',
                                        style: textTheme.titleMedium?.copyWith(
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        ref
                                            .read(
                                              cartControllerProvider.notifier,
                                            )
                                            .deleteItem(line.item.lineId);
                                      },
                                      icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: AppColors.error,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceAlt,
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              ref
                                                  .read(
                                                    cartControllerProvider
                                                        .notifier,
                                                  )
                                                  .removeItem(line.item.lineId);
                                            },
                                            visualDensity:
                                                VisualDensity.compact,
                                            icon: const Icon(
                                              Icons.remove_rounded,
                                            ),
                                          ),
                                          Text(
                                            '${line.quantity}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              ref
                                                  .read(
                                                    cartControllerProvider
                                                        .notifier,
                                                  )
                                                  .incrementItem(
                                                    line.item.lineId,
                                                  );
                                            },
                                            visualDensity:
                                                VisualDensity.compact,
                                            icon: const Icon(Icons.add_rounded),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                    decoration: BoxDecoration(
                      color: AppColors.background.withValues(alpha: 0.94),
                      border: Border(
                        top: BorderSide(
                          color: AppColors.border.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                    child: AppSurfaceCard(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Total', style: textTheme.bodySmall),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  '${total.toStringAsFixed(2)} JD',
                                  style: textTheme.titleLarge?.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          ElevatedButton(
                            onPressed: () async {
                              if (isBusy) {
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    const SnackBar(content: Text(_busyMessage)),
                                  );
                                return;
                              }

                              try {
                                final order = await ref
                                    .read(
                                      customerOrdersControllerProvider.notifier,
                                    )
                                    .placeOrder(lines: lines, total: total);
                                if (!context.mounted) {
                                  return;
                                }

                                await showDialog<void>(
                                  context: context,
                                  builder: (dialogContext) {
                                    return AlertDialog(
                                      title: const Text('Order placed'),
                                      content: Text(
                                        'Checkout saved for ${order.restaurantName}. Your order is now tracked in order history on this device.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(dialogContext).pop(),
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                if (!context.mounted) {
                                  return;
                                }
                                ref
                                    .read(cartControllerProvider.notifier)
                                    .clear();
                              } catch (error) {
                                if (!context.mounted) {
                                  return;
                                }
                                final message = error is ApiException
                                    ? error.message
                                    : error.toString().replaceFirst(
                                        'Exception: ',
                                        '',
                                      );
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    SnackBar(content: Text(message)),
                                  );
                              }
                            },
                            child: const Text('Place order'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
