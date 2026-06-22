import 'package:flutter/material.dart';

import '../../app/theme/luqmah_theme.dart';

class AppLoadingPage extends StatelessWidget {
  const AppLoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.luqmah;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [tokens.background, tokens.surface],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.96, end: 1),
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeOutCubic,
                builder: (context, scale, child) {
                  return AnimatedOpacity(
                    opacity: scale,
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOut,
                    child: Transform.scale(scale: scale, child: child),
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/Luqmah_transparent.png',
                      height: 96,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: tokens.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Preparing your order experience',
                      style: textTheme.bodyMedium?.copyWith(
                        color: tokens.mutedText,
                      ),
                      textAlign: TextAlign.center,
                    ),
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
