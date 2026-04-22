// lib/pages/auth/register_page.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/app_session_service.dart';
import '../vendor/vendor_orders_page.dart';
import 'verify_email_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  String? _error;
  AppRole _selectedRole = AppRole.customer;

  bool _isHuEmail(String email) {
    return email.toLowerCase().endsWith('hu.edu.jo');
  }

  Future<void> _register() async {
    if (_selectedRole == AppRole.vendor) {
      await _continueAsVendorDemo();
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await AppSessionService.clearVendorDemoAccess();
      final email = _emailCtrl.text.trim();
      final password = _passwordCtrl.text.trim();

      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await AppSessionService.setRoleForIdentifier(
        cred.user!.uid,
        _selectedRole,
      );
      await AppSessionService.setRoleForIdentifier(email, _selectedRole);
      await AppSessionService.setRoleForCurrentUser(_selectedRole);
      await cred.user!.sendEmailVerification();

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const VerifyEmailPage()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Something went wrong, try again.');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _continueAsVendorDemo() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await AppSessionService.enableVendorDemoAccess();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const VendorOrdersPage()),
        (route) => false,
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
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
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: _loading
                              ? null
                              : () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Container(
                          height: 84,
                          width: 84,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_add_alt_1_rounded,
                            size: 40,
                            color: accent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Create your account',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedRole == AppRole.vendor
                            ? 'Open the vendor dashboard in demo mode without creating a Firebase account.'
                            : 'Join Luqmah with your university email to start ordering on campus.',
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
                              'Register',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _selectedRole == AppRole.vendor
                                  ? 'Vendor registration is bypassed for now so you can test the vendor pages directly.'
                                  : 'Only Hashemite University email addresses are allowed.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 18),
                            SegmentedButton<AppRole>(
                              showSelectedIcon: false,
                              segments: const [
                                ButtonSegment<AppRole>(
                                  value: AppRole.customer,
                                  label: Text('Customer'),
                                  icon: Icon(Icons.person_outline_rounded),
                                ),
                                ButtonSegment<AppRole>(
                                  value: AppRole.vendor,
                                  label: Text('Vendor'),
                                  icon: Icon(Icons.storefront_outlined),
                                ),
                              ],
                              selected: <AppRole>{_selectedRole},
                              onSelectionChanged: (selection) {
                                setState(() {
                                  _selectedRole = selection.first;
                                });
                              },
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _selectedRole == AppRole.vendor
                                  ? 'No email or password is required for vendor demo access right now.'
                                  : 'Customer accounts will open the restaurant browsing flow after email verification.',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black45,
                              ),
                            ),
                            const SizedBox(height: 20),
                            if (_selectedRole == AppRole.customer) ...[
                              TextFormField(
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                autofillHints: const [
                                  AutofillHints.newUsername,
                                ],
                                decoration: InputDecoration(
                                  labelText: 'HU email',
                                  hintText: 'your_id@hu.edu.jo',
                                  prefixIcon: const Icon(
                                    Icons.alternate_email_rounded,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF7F8F9),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Email required';
                                  }
                                  if (!_isHuEmail(value)) {
                                    return 'You must use your university email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _passwordCtrl,
                                obscureText: _obscurePassword,
                                autofillHints: const [
                                  AutofillHints.newPassword,
                                ],
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  helperText: 'Use at least 6 characters',
                                  prefixIcon: const Icon(
                                    Icons.lock_outline_rounded,
                                  ),
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
                                validator: (value) =>
                                    value != null && value.length >= 6
                                    ? null
                                    : 'Min 6 characters',
                              ),
                            ] else ...[
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3FAF4),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.info_outline_rounded,
                                      color: Color(0xFF2E7D32),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'This is a temporary shortcut so you can test the vendor experience before the real backend is ready.',
                                        style: TextStyle(
                                          height: 1.4,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
                                onPressed: _loading ? null : _register,
                                child: _loading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        _selectedRole == AppRole.vendor
                                            ? 'Continue as vendor'
                                            : 'Sign up',
                                      ),
                              ),
                            ),
                          ],
                        ),
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
