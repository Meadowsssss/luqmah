import 'package:flutter/material.dart';

import '../../pages/restaurants_page.dart';
import '../../services/app_session_service.dart';

class VendorAccessGuard extends StatelessWidget {
  final Widget child;

  const VendorAccessGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (AppSessionService.role.value == AppRole.vendor) {
      return child;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Vendor access only')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.storefront_outlined,
                size: 54,
                color: Color(0xFF2E7D32),
              ),
              const SizedBox(height: 12),
              const Text(
                'This section is only available for vendor accounts.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'Switch back to the customer side to browse restaurants.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const RestaurantsPage()),
                    (route) => false,
                  );
                },
                child: const Text('Go to customer home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
