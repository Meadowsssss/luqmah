import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/luqmah_theme.dart';
import '../../../core/validation/customer_profile_validators.dart';
import '../../../features/session/auth_error_formatter.dart';
import '../../../features/session/session_controller.dart';
import '../../../shared/widgets/app_surface_card.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isHuEmail(String email) => email.toLowerCase().endsWith('hu.edu.jo');

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await ref.read(sessionControllerProvider).registerCustomer(
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) {
        context.go('/verify-email');
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

  @override
  Widget build(BuildContext context) {
    final tokens = context.luqmah;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/login');
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: AppSurfaceCard(
                  child: Form(
                    key: _formKey,
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.stretch,
                       children: [
                         Container(
                           padding: const EdgeInsets.all(AppSpacing.lg),
                           decoration: BoxDecoration(
                             color: tokens.surfaceAlt.withValues(alpha: 0.68),
                             borderRadius: BorderRadius.circular(AppRadii.lg),
                             border: Border.all(color: tokens.border),
                           ),
                           child: Row(
                             children: [
                               Container(
                                 height: 46,
                                 width: 46,
                                 decoration: BoxDecoration(
                                   color: tokens.primary.withValues(alpha: 0.12),
                                   borderRadius: BorderRadius.circular(
                                     AppRadii.md,
                                   ),
                                 ),
                                 child: Icon(
                                   Icons.person_add_alt_1_rounded,
                                   color: tokens.primary,
                                 ),
                               ),
                               const SizedBox(width: AppSpacing.md),
                               Expanded(
                                 child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     Text(
                                       'Create your account',
                                       style: Theme.of(context)
                                           .textTheme
                                           .titleLarge,
                                     ),
                                     const SizedBox(height: AppSpacing.xs),
                                     Text(
                                       'Set up your Luqmah profile with your name, phone number, and Hashemite University email.',
                                       style: Theme.of(context)
                                           .textTheme
                                           .bodyMedium
                                           ?.copyWith(
                                             color: context.luqmah.mutedText,
                                           ),
                                     ),
                                   ],
                                 ),
                               ),
                             ],
                           ),
                         ),
                         const SizedBox(height: AppSpacing.xl),
                         Text(
                           'Profile details',
                           style: Theme.of(context).textTheme.titleMedium,
                         ),
                         const SizedBox(height: AppSpacing.lg),
                         TextFormField(
                           controller: _nameController,
                           textCapitalization: TextCapitalization.words,
                           decoration: const InputDecoration(
                             labelText: 'Full name',
                             hintText: 'Your full name',
                             prefixIcon: Icon(Icons.person_outline_rounded),
                           ),
                           validator: validateCustomerDisplayName,
                         ),
                         const SizedBox(height: AppSpacing.lg),
                         TextFormField(
                           controller: _phoneController,
                           keyboardType: TextInputType.phone,
                           decoration: const InputDecoration(
                             labelText: 'Phone number',
                             hintText: '07...',
                             prefixIcon: Icon(Icons.phone_outlined),
                           ),
                           validator: validateCustomerPhoneNumber,
                         ),
                         const SizedBox(height: AppSpacing.xl),
                         Text(
                           'Account access',
                           style: Theme.of(context).textTheme.titleMedium,
                         ),
                         const SizedBox(height: AppSpacing.lg),
                         TextFormField(
                           controller: _emailController,
                           keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'HU email',
                            hintText: 'your_id@hu.edu.jo',
                            prefixIcon: Icon(Icons.school_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email is required';
                            }
                            if (!_isHuEmail(value.trim())) {
                              return 'Use your university email';
                            }
                            return null;
                          },
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
                           validator: (value) {
                             if (value == null || value.isEmpty) {
                               return 'Password is required';
                             }
                            if (value.length < 6) {
                              return 'Minimum 6 characters';
                            }
                             return null;
                           },
                         ),
                         const SizedBox(height: AppSpacing.lg),
                         TextFormField(
                           controller: _confirmPasswordController,
                           obscureText: _obscureConfirmPassword,
                           decoration: InputDecoration(
                             labelText: 'Confirm password',
                             prefixIcon: const Icon(Icons.lock_outline_rounded),
                             suffixIcon: IconButton(
                               onPressed: () {
                                 setState(
                                   () => _obscureConfirmPassword =
                                       !_obscureConfirmPassword,
                                 );
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
                               return 'Confirm your password';
                             }
                             if (value != _passwordController.text) {
                               return 'Passwords do not match';
                             }
                             return null;
                           },
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
                              : const Text('Create account'),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextButton(
                          onPressed: _loading
                              ? null
                              : () {
                                  if (context.canPop()) {
                                    context.pop();
                                  } else {
                                    context.go('/login');
                                  }
                                },
                          child: const Text('Already have an account? Sign in'),
                        ),
                      ],
                    ),
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
