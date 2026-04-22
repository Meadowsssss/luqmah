import 'package:flutter/material.dart';

import '../../models/vendor.dart';
import '../../services/vendor_store.dart';
import '../../widgets/account_menu_button.dart';
import '../../widgets/vendor/vendor_access_guard.dart';
import '../../widgets/vendor/vendor_bottom_nav.dart';
import '../../widgets/vendor/vendor_order_card.dart';
import 'vendor_order_details_page.dart';
import 'vendor_placeholder_page.dart';

class VendorOrdersPage extends StatefulWidget {
  const VendorOrdersPage({super.key});

  @override
  State<VendorOrdersPage> createState() => _VendorOrdersPageState();
}

class _VendorOrdersPageState extends State<VendorOrdersPage> {
  bool _showPastOrders = false;

  @override
  Widget build(BuildContext context) {
    return VendorAccessGuard(
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7F9),
        bottomNavigationBar: const VendorBottomNav(currentIndex: 0),
        body: SafeArea(
          child: ValueListenableBuilder<List<VendorOrder>>(
            valueListenable: VendorStore.orders,
            builder: (context, orders, _) {
              final visibleOrders = orders
                  .where(
                    (order) => _showPastOrders
                        ? order.status.isPast
                        : !order.status.isPast,
                  )
                  .toList(growable: false);

              return Column(
                children: [
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Orders',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        AccountMenuButton(
                          onProfileTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const VendorPlaceholderPage(
                                  title: 'Profile',
                                  icon: Icons.storefront_rounded,
                                  message:
                                      'Vendor profile settings will live here once the backend account data is connected.',
                                  currentIndex: 3,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      children: [
                        Expanded(
                          child: _OrdersTabButton(
                            title: 'New Orders',
                            selected: !_showPastOrders,
                            onTap: () {
                              setState(() => _showPastOrders = false);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _OrdersTabButton(
                            title: 'Past Orders',
                            selected: _showPastOrders,
                            onTap: () {
                              setState(() => _showPastOrders = true);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      children: [
                        if (visibleOrders.isEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 28),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Text(
                              _showPastOrders
                                  ? 'No past orders yet.'
                                  : 'No new orders right now.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        for (final order in visibleOrders)
                          VendorOrderCard(
                            order: order,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      VendorOrderDetailsPage(orderId: order.id),
                                ),
                              );
                            },
                            onStatusChanged: (status) {
                              if (status != null) {
                                VendorStore.updateOrderStatus(order.id, status);
                              }
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _OrdersTabButton extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _OrdersTabButton({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? Colors.black87 : Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 3,
            decoration: BoxDecoration(
              color: selected ? const Color(0xFF0EC56D) : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ),
    );
  }
}
