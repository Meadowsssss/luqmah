import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../app/theme/luqmah_theme.dart';
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

    return Scaffold(
      appBar: AppBar(title: const Text('Your cart')),
      body: SafeArea(
        child: lines.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: AppEmptyState(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Your cart is empty',
                  message: 'Add a few favourites from campus restaurants to get started.',
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      itemCount: lines.length,
                      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.lg),
                      itemBuilder: (context, index) {
                        final line = lines[index];
                        return AppSurfaceCard(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      line.item.name,
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      line.item.restaurantName,
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      '${line.item.price.toStringAsFixed(2)} JD each',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    Text(
                                      '${line.lineTotal.toStringAsFixed(2)} JD',
                                      style: const TextStyle(
                                        color: AppColors.accent,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      ref
                                          .read(cartControllerProvider.notifier)
                                          .removeItem(line.item.itemId);
                                    },
                                    icon: const Icon(Icons.remove_circle_outline_rounded),
                                  ),
                                  Text(
                                    '${line.quantity}',
                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      ref
                                          .read(cartControllerProvider.notifier)
                                          .incrementItem(line.item.itemId);
                                    },
                                    icon: const Icon(Icons.add_circle_outline_rounded),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      ref
                                          .read(cartControllerProvider.notifier)
                                          .deleteItem(line.item.itemId);
                                    },
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      color: AppColors.error,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        border: Border(top: BorderSide(color: AppColors.border)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Total', style: Theme.of(context).textTheme.bodySmall),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  '${total.toStringAsFixed(2)} JD',
                                  style: Theme.of(context).textTheme.titleLarge,
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
                                  ..showSnackBar(const SnackBar(content: Text(_busyMessage)));
                                return;
                              }

                              try {
                                final order = await ref
                                    .read(customerOrdersControllerProvider.notifier)
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
                                          onPressed: () => Navigator.of(dialogContext).pop(),
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                if (!context.mounted) {
                                  return;
                                }
                                ref.read(cartControllerProvider.notifier).clear();
                              } catch (error) {
                                if (!context.mounted) {
                                  return;
                                }
                                final message = error is ApiException
                                    ? error.message
                                    : error.toString().replaceFirst('Exception: ', '');
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(SnackBar(content: Text(message)));
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
