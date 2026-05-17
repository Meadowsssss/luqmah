import 'package:flutter/material.dart';

import '../../app/theme/luqmah_theme.dart';

class AppSurfaceCard extends StatelessWidget {
  const AppSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final tokens = context.luqmah;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: tokens.border),
        boxShadow: [
          BoxShadow(
            color: tokens.primary.withValues(alpha: isDark ? 0.10 : 0.05),
            blurRadius: isDark ? 18 : 26,
            offset: const Offset(0, 12),
          ),
          if (!isDark)
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.65),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
        ],
      ),
      child: child,
    );
  }
}
