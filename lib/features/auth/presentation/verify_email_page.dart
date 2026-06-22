import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/luqmah_theme.dart';
import '../../../core/validation/customer_profile_validators.dart';
import '../../../features/session/auth_error_formatter.dart';
import '../../../features/session/session_controller.dart';
import '../../../shared/widgets/app_surface_card.dart';

class VerifyEmailPage extends ConsumerStatefulWidget {
  const VerifyEmailPage({super.key, this.emailLink});

  final String? emailLink;

  @override
  ConsumerState<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends ConsumerState<VerifyEmailPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _checking = false;
  bool _showDetailsForm = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _message;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIncomingLink();
    });
  }

  @override
  void didUpdateWidget(VerifyEmailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.emailLink != oldWidget.emailLink) {
      _checkIncomingLink();
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isHuEmail(String email) => email.toLowerCase().endsWith('hu.edu.jo');

  Future<void> _checkIncomingLink() async {
    final link = widget.emailLink;
    if (link == null || link.isEmpty) return;

    final authRepo = ref.read(authRepositoryProvider);
    if (!authRepo.isSignInWithEmailLink(link)) {
      return;
    }

    setState(() {
      _checking = true;
      _message = 'Verifying link and signing in...';
      _showDetailsForm = false;
    });

    try {
      final sessionController = ref.read(sessionControllerProvider);
      await sessionController.completeEmailLinkRegistration(link);

      if (mounted) {
        setState(() {
          _checking = false;
          _message = 'Successfully registered and signed in!';
        });
      }
    } catch (error) {
      if (mounted) {
        final storedProfile = ref.read(sessionControllerProvider).pendingProfile;
        if (storedProfile == null || storedProfile.email.isEmpty) {
          setState(() {
            _checking = false;
            _showDetailsForm = true;
            _message = 'Verification link detected. Please confirm your details to complete registration.';
          });
        } else {
          setState(() {
            _checking = false;
            _message = formatAuthError(error);
          });
        }
      }
    }
  }

  Future<void> _submitDetailsForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _checking = true;
      _message = 'Completing registration...';
    });

    try {
      final sessionController = ref.read(sessionControllerProvider);
      await sessionController.completeEmailLinkRegistration(
        widget.emailLink!,
        email: _emailController.text.trim(),
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _checking = false;
          _message = 'Successfully registered and signed in!';
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _checking = false;
          _message = formatAuthError(error);
        });
      }
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _checking = true;
      _message = null;
    });

    try {
      await ref.read(sessionControllerProvider).reloadVerification();

      if (mounted) {
        setState(() {
          _checking = false;
          _message = 'Verification status refreshed.';
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _checking = false;
          _message = formatAuthError(error);
        });
      }
    }
  }

  Future<void> _resend() async {
    try {
      await ref.read(sessionControllerProvider).resendVerification();
      if (mounted) {
        setState(() => _message = 'Verification email sent again.');
      }
    } catch (error) {
      if (mounted) {
        setState(() => _message = formatAuthError(error));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(sessionControllerProvider).snapshot;
    final pendingProfile = ref.watch(sessionControllerProvider).pendingProfile;
    final emailAddress = snapshot.email.isNotEmpty
        ? snapshot.email
        : (pendingProfile?.email ?? 'your email');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify your email'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => ref.read(sessionControllerProvider).logout(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: AppSurfaceCard(
                child: _showDetailsForm
                    ? Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Complete Registration',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'We detected a verification link. Since your session details are missing (e.g. different device or cleared storage), please fill in your details to secure your account.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: context.luqmah.mutedText,
                              ),
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
                            const SizedBox(height: AppSpacing.md),
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
                            const SizedBox(height: AppSpacing.md),
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
                            const SizedBox(height: AppSpacing.md),
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
                            const SizedBox(height: AppSpacing.md),
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
                            const SizedBox(height: AppSpacing.xl),
                            ElevatedButton(
                              onPressed: _checking ? null : _submitDetailsForm,
                              child: _checking
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Complete & Sign In'),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            TextButton(
                              onPressed: () => ref.read(sessionControllerProvider).logout(),
                              child: const Text('Cancel & Back to login'),
                            ),
                            if (_message != null) ...[
                              const SizedBox(height: AppSpacing.lg),
                              Text(
                                _message!,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Check your inbox',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'We sent a verification link to $emailAddress.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: context.luqmah.mutedText,
                            ),
                          ),
                          if (snapshot.customerSyncError != null) ...[
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              snapshot.customerSyncError!,
                              style: TextStyle(color: Theme.of(context).colorScheme.error),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.xl),
                          ElevatedButton(
                            onPressed: _checking ? null : _refresh,
                            child: _checking
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('I verified, continue'),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          OutlinedButton(
                            onPressed: _resend,
                            child: const Text('Resend verification email'),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          TextButton(
                            onPressed: () => ref.read(sessionControllerProvider).logout(),
                            child: const Text('Back to login'),
                          ),
                          if (_message != null) ...[
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              _message!,
                              style: Theme.of(context).textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
