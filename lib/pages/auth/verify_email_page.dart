// lib/pages/auth/verify_email_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../restaurants_page.dart';
import '../../services/app_session_service.dart';
import '../vendor/vendor_orders_page.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool _checking = false;
  String? _msg;

  Future<void> _refreshStatus() async {
    setState(() {
      _checking = true;
      _msg = null;
    });

    await FirebaseAuth.instance.currentUser?.reload();
    final user = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    if (user != null && user.emailVerified) {
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
    } else {
      setState(() {
        _msg = 'Still not verified. Check your HU email inbox/spam.';
        _checking = false;
      });
    }
  }

  Future<void> _resendEmail() async {
    await FirebaseAuth.instance.currentUser?.sendEmailVerification();
    setState(() {
      _msg = 'Verification email sent again.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Verify your email')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'We sent a verification link to:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(email, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            if (_msg != null)
              Text(_msg!, style: const TextStyle(color: Colors.blueGrey)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _checking ? null : _refreshStatus,
                child: _checking
                    ? const CircularProgressIndicator()
                    : const Text('I verified, continue'),
              ),
            ),
            TextButton(
              onPressed: _resendEmail,
              child: const Text('Resend email'),
            ),
          ],
        ),
      ),
    );
  }
}
