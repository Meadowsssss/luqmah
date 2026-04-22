import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../pages/auth/login_page.dart';
import 'app_session_service.dart';

class SessionActions {
  static Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    await AppSessionService.clearVendorDemoAccess();
    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }
}
