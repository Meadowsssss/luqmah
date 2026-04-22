import 'package:flutter/material.dart';

import '../../pages/vendor/vendor_add_item_page.dart';
import '../../pages/vendor/vendor_orders_page.dart';
import '../../pages/vendor/vendor_placeholder_page.dart';

class VendorBottomNav extends StatelessWidget {
  final int currentIndex;

  const VendorBottomNav({super.key, required this.currentIndex});

  void _openTab(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget page;
    switch (index) {
      case 0:
        page = const VendorOrdersPage();
        break;
      case 1:
        page = const VendorPlaceholderPage(
          title: 'Insights',
          icon: Icons.bar_chart_rounded,
          message:
              'Insights will live here once your vendor analytics are ready.',
          currentIndex: 1,
        );
        break;
      case 2:
        page = const VendorAddItemPage();
        break;
      default:
        page = const VendorPlaceholderPage(
          title: 'Profile',
          icon: Icons.person_outline_rounded,
          message: 'Vendor profile settings will live here.',
          currentIndex: 3,
        );
        break;
    }

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: const Color(0xFF0EC56D),
      unselectedItemColor: Colors.white70,
      backgroundColor: const Color(0xFF10242B),
      type: BottomNavigationBarType.fixed,
      onTap: (index) => _openTab(context, index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined),
          activeIcon: Icon(Icons.receipt_long_rounded),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart_outlined),
          activeIcon: Icon(Icons.bar_chart_rounded),
          label: 'Insights',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.spa_outlined),
          activeIcon: Icon(Icons.spa_rounded),
          label: 'Products',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.storefront_outlined),
          activeIcon: Icon(Icons.storefront_rounded),
          label: 'Profile',
        ),
      ],
    );
  }
}
