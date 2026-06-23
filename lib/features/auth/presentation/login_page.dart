import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'luqmah.project@gmail.com',
    );
    try {
      if (!await launchUrl(emailUri, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $emailUri';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open email application.')),
        );
      }
    }
  }

  Future<void> _launchPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+962778700012');
    try {
      if (!await launchUrl(phoneUri, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $phoneUri';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open phone application.')),
        );
      }
    }
  }

  void _showContactUsBottomSheet() {
    final tokens = context.luqmah;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: tokens.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Text(
                  'How can we help?',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: tokens.strongText,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Select a contact method below.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: tokens.mutedText,
                  ),
                ),
                const SizedBox(height: 24),
                _buildContactOption(
                  context: context,
                  icon: Icons.mail_outline_rounded,
                  label: 'E-mail: luqmah.project@gmail.com',
                  onTap: () {
                    Navigator.pop(context);
                    _launchEmail();
                  },
                ),
                const SizedBox(height: 12),
                _buildContactOption(
                  context: context,
                  icon: Icons.phone_outlined,
                  label: '+962778700012',
                  onTap: () {
                    Navigator.pop(context);
                    _launchPhone();
                  },
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Close',
                    style: GoogleFonts.plusJakartaSans(
                      color: tokens.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContactOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final tokens = context.luqmah;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: tokens.surfaceAlt.withValues(alpha: 0.8),
          foregroundColor: tokens.strongText,
          side: BorderSide(color: tokens.border, width: 1),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: tokens.strongText, size: 20),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: tokens.strongText,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mutedTextStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(color: context.luqmah.mutedText);
    final tokens = context.luqmah;

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
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              tokens.surface,
                              tokens.surfaceAlt.withValues(alpha: 0.92),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(AppRadii.hero),
                          border: Border.all(color: tokens.border),
                          boxShadow: [
                            BoxShadow(
                              color: tokens.primary.withValues(alpha: 0.08),
                              blurRadius: 26,
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
                                    color: tokens.primary.withValues(
                                      alpha: 0.08,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Positioned(
                                left: -30,
                                top: 76,
                                child: Transform.rotate(
                                  angle: -0.28,
                                  child: Container(
                                    height: 18,
                                    width: 142,
                                    decoration: BoxDecoration(
                                      color: tokens.primary.withValues(
                                        alpha: 0.10,
                                      ),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(AppSpacing.xxl),
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 320,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Image.asset(
                                        'assets/Luqmah_transparent.png',
                                        height: 42,
                                        fit: BoxFit.contain,
                                      ),
                                      const SizedBox(height: AppSpacing.lg),
                                      GestureDetector(
                                        onLongPress: _promptAdminCode,
                                        child: Text(
                                          'Welcome back to Luqmah',
                                          style: GoogleFonts.plusJakartaSans(
                                            textStyle: Theme.of(
                                              context,
                                            ).textTheme.headlineMedium,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.sm),
                                      Text(
                                        _vendorMode
                                            ? 'Sign in to track incoming orders, update your menu, and keep your storefront running smoothly.'
                                            : 'Sign in to browse campus favourites, manage your cart, and keep up with your orders.',
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
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SegmentedButton<bool>(
                                style: ButtonStyle(
                                  visualDensity: VisualDensity.standard,
                                  padding: WidgetStateProperty.all(
                                    const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                  backgroundColor:
                                      WidgetStateProperty.resolveWith(
                                        (states) =>
                                            states.contains(
                                              WidgetState.selected,
                                            )
                                            ? tokens.primary
                                            : tokens.surfaceAlt.withValues(
                                                alpha: 0.6,
                                              ),
                                      ),
                                  foregroundColor:
                                      WidgetStateProperty.resolveWith(
                                        (states) =>
                                            states.contains(
                                              WidgetState.selected,
                                            )
                                            ? Colors.white
                                            : tokens.strongText,
                                      ),
                                  side: WidgetStateProperty.all(
                                    BorderSide(color: tokens.border),
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
                      const SizedBox(height: AppSpacing.xxl),
                      Center(
                        child: OutlinedButton(
                          onPressed: _loading
                              ? null
                              : _showContactUsBottomSheet,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: tokens.mutedText,
                            side: BorderSide(color: tokens.border),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            shape: const StadiumBorder(),
                          ),
                          child: Text(
                            'Need help? Contact Us',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: tokens.strongText,
                            ),
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
