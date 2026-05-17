import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/luqmah_theme.dart';

class VendorShell extends StatelessWidget {
  const VendorShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final tokens = context.luqmah;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: tokens.surface,
          border: Border(top: BorderSide(color: tokens.border)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long_rounded),
              label: 'Orders',
            ),
            NavigationDestination(
              icon: Icon(Icons.soup_kitchen_outlined),
              selectedIcon: Icon(Icons.soup_kitchen_rounded),
              label: 'Products',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart_rounded),
              label: 'Insights',
            ),
            NavigationDestination(
              icon: Icon(Icons.storefront_outlined),
              selectedIcon: Icon(Icons.storefront_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
