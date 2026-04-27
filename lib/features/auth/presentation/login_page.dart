import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/luqmah_theme.dart';
import '../../../features/session/session_controller.dart';
import '../../../features/session/auth_error_formatter.dart';
import '../../../shared/widgets/app_surface_card.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  static const _adminEntryCode = 'luqmah-admin-portal';

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _adminCodeController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  bool _vendorMode = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _adminCodeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (_vendorMode) {
        await ref.read(sessionControllerProvider).loginVendor(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        await ref.read(sessionControllerProvider).login(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }
    } catch (error) {
      setState(() {
        _error = formatAuthError(error);
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _showForgotPasswordDialog() async {
    final controller = TextEditingController(text: _emailController.text.trim());
    String? error;
    bool sending = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Reset customer password'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      error!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: sending ? null : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: sending
                      ? null
                      : () async {
                          setState(() {
                            sending = true;
                            error = null;
                          });

                          try {
                            await ref
                                .read(sessionControllerProvider)
                                .sendCustomerPasswordResetEmail(controller.text.trim());
                            if (dialogContext.mounted && context.mounted) {
                              Navigator.of(dialogContext).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Password reset email sent.'),
                                ),
                              );
                            }
                          } catch (err) {
                            setState(() {
                              error = formatAuthError(err);
                              sending = false;
                            });
                          }
                        },
                  child: sending
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Send reset email'),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
  }

  Future<void> _promptAdminCode() async {
    _adminCodeController.clear();
    final isMatch = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Admin entry'),
          content: TextField(
            controller: _adminCodeController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Entry code'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(
                _adminCodeController.text.trim() == _adminEntryCode,
              ),
              child: const Text('Enter'),
            ),
          ],
        );
      },
    );

    if (!mounted || isMatch != true) {
      return;
    }

    context.go('/admin/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryAlt],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppRadii.hero),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'Campus utility with warmth',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        GestureDetector(
                          onLongPress: _promptAdminCode,
                          child: Text(
                            'Welcome back to Luqmah',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Sign in as a customer or vendor. Admin access stays hidden behind the private entry code.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  AppSurfaceCard(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Sign in', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: AppSpacing.xs),
                          SegmentedButton<bool>(
                            segments: const [
                              ButtonSegment<bool>(value: false, label: Text('Customer')),
                              ButtonSegment<bool>(value: true, label: Text('Vendor')),
                            ],
                            selected: <bool>{_vendorMode},
                            onSelectionChanged: _loading
                                ? null
                                : (value) {
                                    setState(() {
                                      _vendorMode = value.first;
                                      _error = null;
                                    });
                                  },
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            _vendorMode
                                ? 'Use the backend vendor credentials we assigned to your restaurant.'
                                : 'Use your customer account to continue on the customer side.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: context.luqmah.mutedText,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.mail_outline_rounded),
                            ),
                            validator: (value) => value == null || value.trim().isEmpty
                                ? 'Email is required'
                                : null,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() => _obscurePassword = !_obscurePassword);
                                },
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                              ),
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Password is required'
                                : null,
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              _error!,
                              style: TextStyle(color: Theme.of(context).colorScheme.error),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.xl),
                          ElevatedButton(
                            onPressed: _loading ? null : _submit,
                            child: _loading
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(_vendorMode ? 'Sign in as vendor' : 'Sign in'),
                          ),
                          if (!_vendorMode) ...[
                            const SizedBox(height: AppSpacing.sm),
                            TextButton(
                              onPressed: _loading ? null : _showForgotPasswordDialog,
                              child: const Text('Forgot password?'),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            TextButton(
                              onPressed: _loading ? null : () => context.go('/register'),
                              child: const Text('Need an account? Create one'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
