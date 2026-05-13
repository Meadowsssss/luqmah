import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/luqmah_theme.dart';
import '../../../models/customer_order.dart';
import '../cart/cart_controller.dart';
import '../orders/customer_orders_controller.dart';
import 'order_rating_dialog.dart';

class CustomerShell extends ConsumerStatefulWidget {
  const CustomerShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends ConsumerState<CustomerShell> {
  final Set<String> _handledPromptOrderIds = <String>{};
  bool _ratingDialogOpen = false;

  CustomerOrder? _latestCompletedOrder(List<CustomerOrder> orders) {
    final completed =
        orders
            .where((order) => order.status.name == 'completed')
            .toList(growable: false)
          ..sort((a, b) => b.placedAt.compareTo(a.placedAt));
    return completed.isEmpty ? null : completed.first;
  }

  void _maybePromptForRating(List<CustomerOrder> orders) {
    final latest = _latestCompletedOrder(orders);
    if (latest == null ||
        !latest.needsRatingPrompt ||
        _ratingDialogOpen ||
        _handledPromptOrderIds.contains(latest.id)) {
      return;
    }

    _handledPromptOrderIds.add(latest.id);
    _ratingDialogOpen = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }

      final result = await showOrderRatingDialog(
        context: context,
        order: latest,
        allowLater: true,
      );

      if (!mounted) {
        return;
      }

      try {
        if (result?.dismissed == true) {
          await ref
              .read(customerOrdersControllerProvider.notifier)
              .dismissRatingPrompt(latest);
        } else if (result?.score != null) {
          await ref
              .read(customerOrdersControllerProvider.notifier)
              .rateOrder(order: latest, score: result!.score!);
        }
      } catch (error) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(error.toString())));
      } finally {
        _ratingDialogOpen = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<List<CustomerOrder>>>(
      customerOrdersControllerProvider,
      (_, next) {
        next.whenData(_maybePromptForRating);
      },
    );

    ref.watch(customerOrdersControllerProvider).whenData(_maybePromptForRating);
    final cartCount = ref.watch(cartControllerProvider).itemCount;

    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.navigationShell.currentIndex,
        onDestinationSelected: (index) {
          widget.navigationShell.goBranch(
            index,
            initialLocation: index == widget.navigationShell.currentIndex,
          );
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront_rounded),
            label: 'Browse',
          ),
          NavigationDestination(
            icon: _CartDestinationIcon(count: cartCount),
            selectedIcon: _CartDestinationIcon(
              count: cartCount,
              selected: true,
            ),
            label: 'Cart',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _CartDestinationIcon extends StatelessWidget {
  const _CartDestinationIcon({required this.count, this.selected = false});

  final int count;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 24,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Icon(
            selected ? Icons.shopping_bag_rounded : Icons.shopping_bag_outlined,
          ),
          if (count > 0)
            Positioned(
              right: 0,
              top: -6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
