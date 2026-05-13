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
  static const _heroImageUrl =
      'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=1200&q=80';

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
        await ref
            .read(sessionControllerProvider)
            .loginVendor(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );
      } else {
        await ref
            .read(sessionControllerProvider)
            .login(
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
    final controller = TextEditingController(
      text: _emailController.text.trim(),
    );
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
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: sending
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
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
                                .sendCustomerPasswordResetEmail(
                                  controller.text.trim(),
                                );
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
              onPressed: () => Navigator.of(
                dialogContext,
              ).pop(_adminCodeController.text.trim() == _adminEntryCode),
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
    final mutedTextStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(color: context.luqmah.mutedText);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -120,
              right: -60,
              child: Container(
                height: 260,
                width: 260,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -70,
              bottom: -50,
              child: Container(
                height: 180,
                width: 180,
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadii.hero),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              blurRadius: 36,
                              offset: const Offset(0, 16),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadii.hero),
                          child: Stack(
                            children: [
                              Positioned(
                                top: -42,
                                right: -30,
                                child: Container(
                                  height: 210,
                                  width: 210,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.07,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: -6,
                                top: 28,
                                child: ClipOval(
                                  child: SizedBox(
                                    height: 196,
                                    width: 196,
                                    child: Image.network(
                                      _heroImageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              color: AppColors.surfaceAlt,
                                              alignment: Alignment.center,
                                              child: const Icon(
                                                Icons.restaurant_rounded,
                                                color: AppColors.primary,
                                                size: 42,
                                              ),
                                            );
                                          },
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(AppSpacing.xxl),
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 260,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            height: 14,
                                            width: 14,
                                            decoration: const BoxDecoration(
                                              color: AppColors.primary,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: AppSpacing.sm),
                                          Text(
                                            'Luqmah',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge
                                                ?.copyWith(
                                                  color: AppColors.primary,
                                                ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: AppSpacing.xxl),
                                      GestureDetector(
                                        onLongPress: _promptAdminCode,
                                        child: Text(
                                          'Welcome back to Luqmah',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.headlineLarge,
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.md),
                                      Text(
                                        'Sign in as a customer or vendor. Admin access stays hidden behind the private entry code.',
                                        style: mutedTextStyle,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      AppSurfaceCard(
                        padding: const EdgeInsets.all(AppSpacing.xxl),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Sign in',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                _vendorMode
                                    ? 'Use the backend vendor credentials we assigned to your restaurant.'
                                    : 'Use your customer account to continue on the customer side.',
                                style: mutedTextStyle,
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              SegmentedButton<bool>(
                                style: ButtonStyle(
                                  visualDensity: VisualDensity.standard,
                                  padding: WidgetStateProperty.all(
                                    const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  side: WidgetStateProperty.all(
                                    const BorderSide(color: AppColors.border),
                                  ),
                                  shape: WidgetStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppRadii.lg,
                                      ),
                                    ),
                                  ),
                                ),
                                showSelectedIcon: false,
                                segments: const [
                                  ButtonSegment<bool>(
                                    value: false,
                                    icon: Icon(Icons.person_rounded),
                                    label: Text('Customer'),
                                  ),
                                  ButtonSegment<bool>(
                                    value: true,
                                    icon: Icon(Icons.storefront_rounded),
                                    label: Text('Vendor'),
                                  ),
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
                              const SizedBox(height: AppSpacing.lg),
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.06,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppRadii.lg,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      _vendorMode
                                          ? Icons.store_mall_directory_rounded
                                          : Icons.person_rounded,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Text(
                                        _vendorMode
                                            ? 'Vendor access uses your assigned Luqmah workspace credentials.'
                                            : 'Customer access uses your verified Luqmah account on the customer side.',
                                        style: mutedTextStyle,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  labelText: 'Email address',
                                  prefixIcon: Icon(Icons.mail_outline_rounded),
                                ),
                                validator: (value) =>
                                    value == null || value.trim().isEmpty
                                    ? 'Email is required'
                                    : null,
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(
                                    Icons.lock_outline_rounded,
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(
                                        () => _obscurePassword =
                                            !_obscurePassword,
                                      );
                                    },
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                    ),
                                  ),
                                ),
                                validator: (value) =>
                                    value == null || value.isEmpty
                                    ? 'Password is required'
                                    : null,
                              ),
                              if (_error != null) ...[
                                const SizedBox(height: AppSpacing.lg),
                                Container(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.error.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(
                                      AppRadii.lg,
                                    ),
                                  ),
                                  child: Text(
                                    _error!,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                                  ),
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
                                    : Text(
                                        _vendorMode
                                            ? 'Sign in as vendor'
                                            : 'Sign in',
                                      ),
                              ),
                              if (!_vendorMode) ...[
                                const SizedBox(height: AppSpacing.sm),
                                Row(
                                  children: [
                                    TextButton(
                                      onPressed: _loading
                                          ? null
                                          : _showForgotPasswordDialog,
                                      child: const Text('Forgot password?'),
                                    ),
                                    const Spacer(),
                                    TextButton(
                                      onPressed: _loading
                                          ? null
                                          : () => context.go('/register'),
                                      child: const Text('Create account'),
                                    ),
                                  ],
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
          ],
        ),
      ),
    );
  }
}
