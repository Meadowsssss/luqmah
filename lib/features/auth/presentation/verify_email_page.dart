import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/luqmah_theme.dart';
import '../../../features/session/auth_error_formatter.dart';
import '../../../features/session/session_controller.dart';
import '../../../shared/widgets/app_surface_card.dart';

class VerifyEmailPage extends ConsumerStatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  ConsumerState<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends ConsumerState<VerifyEmailPage> {
  bool _checking = false;
  String? _message;

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

    return Scaffold(
      appBar: AppBar(title: const Text('Verify your email')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: AppSurfaceCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Check your inbox',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'We sent a verification link to ${snapshot.email.isEmpty ? 'your email' : snapshot.email}.',
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
