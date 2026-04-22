import 'package:flutter/material.dart';

import '../../widgets/account_menu_button.dart';
import '../../widgets/vendor/vendor_access_guard.dart';
import '../../widgets/vendor/vendor_bottom_nav.dart';

class VendorPlaceholderPage extends StatelessWidget {
  final String title;
  final IconData icon;
  final String message;
  final int currentIndex;

  const VendorPlaceholderPage({
    super.key,
    required this.title,
    required this.icon,
    required this.message,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return VendorAccessGuard(
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: [AccountMenuButton(onProfileTap: () {})],
        ),
        bottomNavigationBar: VendorBottomNav(currentIndex: currentIndex),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 56, color: const Color(0xFF2E7D32)),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
