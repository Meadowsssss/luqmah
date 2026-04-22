// lib/pages/auth/login_page.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../restaurants_page.dart';
import '../../services/app_session_service.dart';
import '../vendor/vendor_orders_page.dart';
import 'register_page.dart';
import 'verify_email_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  String? _error;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await AppSessionService.clearVendorDemoAccess();
      final email = _emailCtrl.text.trim();
      final password = _passwordCtrl.text.trim();

      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = cred.user;
      if (user == null) {
        throw Exception('No user');
      }

      if (!user.emailVerified) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const VerifyEmailPage()),
        );
      } else {
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
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Something went wrong');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _continueAsVendorDemo() async {
    await AppSessionService.enableVendorDemoAccess();
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const VendorOrdersPage()),
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const accent = Color(0xFF2E7D32);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF3FAF4), Color(0xFFFFFFFF)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          height: 84,
                          width: 84,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.restaurant_menu_rounded,
                            size: 42,
                            color: accent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Welcome back',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to browse campus restaurants and manage your orders.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.black54,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Login',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Use your account to continue.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Customer login still uses Firebase. Vendor mode can be opened directly for now.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black45,
                              ),
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: _continueAsVendorDemo,
                              icon: const Icon(Icons.storefront_outlined),
                              label: const Text('Continue as vendor'),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.username],
                              decoration: InputDecoration(
                                labelText: 'Email',
                                prefixIcon: const Icon(Icons.mail_outline),
                                filled: true,
                                fillColor: const Color(0xFFF7F8F9),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (v) => v == null || v.isEmpty
                                  ? 'Email required'
                                  : null,
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _passwordCtrl,
                              obscureText: _obscurePassword,
                              autofillHints: const [AutofillHints.password],
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                  ),
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF7F8F9),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (v) => v == null || v.isEmpty
                                  ? 'Password required'
                                  : null,
                            ),
                            if (_error != null) ...[
                              const SizedBox(height: 14),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF2F2),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(
                                  _error!,
                                  style: const TextStyle(
                                    color: Color(0xFFB3261E),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: _loading ? null : _login,
                                child: _loading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('Login'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterPage(),
                            ),
                          );
                        },
                        child: const Text("Don't have an account? Sign up"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
