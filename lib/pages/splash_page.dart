// lib/pages/splash_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'restaurants_page.dart';
import 'auth/login_page.dart';
import 'auth/verify_email_page.dart';
import 'vendor/vendor_orders_page.dart';
import '../services/app_session_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), _handleNavigation);
  }

  Future<void> _handleNavigation() async {
    final user = FirebaseAuth.instance.currentUser;
    final isVendorDemoEnabled = await AppSessionService.isVendorDemoEnabled();
    if (!mounted) return;

    if (user == null) {
      if (isVendorDemoEnabled) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const VendorOrdersPage()),
        );
        return;
      }

      // Not logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } else if (!user.emailVerified) {
      // Logged in but not verified
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const VerifyEmailPage()),
      );
    } else {
      // Logged in & verified
      final role = await AppSessionService.refreshRoleFromCurrentUser();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => role == AppRole.vendor
              ? const VendorOrdersPage()
              : const RestaurantsPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(
                Icons.restaurant_menu_rounded,
                size: 48,
                color: color,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Luqmah',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Loading...', style: TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
