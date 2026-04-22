import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CustomerSettingsPage extends StatefulWidget {
  const CustomerSettingsPage({super.key});

  @override
  State<CustomerSettingsPage> createState() => _CustomerSettingsPageState();
}

class _CustomerSettingsPageState extends State<CustomerSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _saving = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _message;
  bool _messageIsError = false;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
      _message = null;
      _messageIsError = false;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'no-current-user',
          message: 'No signed in customer was found.',
        );
      }

      await user.updatePassword(_passwordCtrl.text.trim());

      if (!mounted) return;
      setState(() {
        _message = 'Password updated successfully.';
        _passwordCtrl.clear();
        _confirmPasswordCtrl.clear();
      });
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _messageIsError = true;
        _message = e.code == 'requires-recent-login'
            ? 'For security, please log out and sign in again before changing your password.'
            : (e.message ?? 'Unable to update password right now.');
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _messageIsError = true;
        _message = 'Something went wrong while updating your password.';
      });
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        title: const Text('Customer Settings'),
        backgroundColor: const Color(0xFFF6F7F9),
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Profile',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                _SettingLine(label: 'Account type', value: 'Customer'),
                const SizedBox(height: 10),
                _SettingLine(
                  label: 'Signed in as',
                  value: user?.email ?? 'No email available',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Change Password',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Set a new password for your customer account.',
                    style: TextStyle(color: Colors.black54, height: 1.4),
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'New password',
                      filled: true,
                      fillColor: const Color(0xFFF7F8F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
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
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'New password is required';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _confirmPasswordCtrl,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      labelText: 'Confirm new password',
                      filled: true,
                      fillColor: const Color(0xFFF7F8F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your new password';
                      }
                      if (value != _passwordCtrl.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  if (_message != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _messageIsError
                            ? const Color(0xFFFFF2F2)
                            : const Color(0xFFF1FBF4),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        _message!,
                        style: TextStyle(
                          color: _messageIsError
                              ? const Color(0xFFB3261E)
                              : const Color(0xFF1C7C45),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF15343A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _saving ? null : _changePassword,
                      child: _saving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Update password'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingLine extends StatelessWidget {
  final String label;
  final String value;

  const _SettingLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
