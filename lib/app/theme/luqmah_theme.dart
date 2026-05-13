import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF1D5A3A);
  static const primaryAlt = Color(0xFF2C6B46);
  static const accent = Color(0xFF3D7D56);
  static const background = Color(0xFFF6F1E6);
  static const surface = Color(0xFFFFFCF6);
  static const surfaceAlt = Color(0xFFEEE7D7);
  static const strongText = Color(0xFF193126);
  static const mutedText = Color(0xFF6A756B);
  static const border = Color(0xFFE2D8C6);
  static const success = Color(0xFF2C7A4A);
  static const warning = Color(0xFFB78A2B);
  static const info = Color(0xFF3E7B76);
  static const error = Color(0xFFB65448);
}

class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const hero = 32.0;
}

class AppRadii {
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 22.0;
  static const xl = 28.0;
  static const hero = 36.0;
}

class LuqmahThemeTokens extends ThemeExtension<LuqmahThemeTokens> {
  const LuqmahThemeTokens({
    required this.accent,
    required this.mutedText,
    required this.border,
    required this.success,
    required this.warning,
    required this.info,
  });

  final Color accent;
  final Color mutedText;
  final Color border;
  final Color success;
  final Color warning;
  final Color info;

  @override
  LuqmahThemeTokens copyWith({
    Color? accent,
    Color? mutedText,
    Color? border,
    Color? success,
    Color? warning,
    Color? info,
  }) {
    return LuqmahThemeTokens(
      accent: accent ?? this.accent,
      mutedText: mutedText ?? this.mutedText,
      border: border ?? this.border,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
    );
  }

  @override
  LuqmahThemeTokens lerp(ThemeExtension<LuqmahThemeTokens>? other, double t) {
    if (other is! LuqmahThemeTokens) {
      return this;
    }

    return LuqmahThemeTokens(
      accent: Color.lerp(accent, other.accent, t) ?? accent,
      mutedText: Color.lerp(mutedText, other.mutedText, t) ?? mutedText,
      border: Color.lerp(border, other.border, t) ?? border,
      success: Color.lerp(success, other.success, t) ?? success,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      info: Color.lerp(info, other.info, t) ?? info,
    );
  }
}

extension LuqmahThemeContext on BuildContext {
  LuqmahThemeTokens get luqmah =>
      Theme.of(this).extension<LuqmahThemeTokens>() ??
      const LuqmahThemeTokens(
        accent: AppColors.accent,
        mutedText: AppColors.mutedText,
        border: AppColors.border,
        success: AppColors.success,
        warning: AppColors.warning,
        info: AppColors.info,
      );
}

ThemeData buildLuqmahTheme() {
  const colorScheme = ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.accent,
    surface: AppColors.surface,
    surfaceContainerHighest: AppColors.surfaceAlt,
    error: AppColors.error,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: AppColors.strongText,
    onError: Colors.white,
  );

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Inter',
  );

  return base.copyWith(
    textTheme: base.textTheme.copyWith(
      headlineLarge: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: AppColors.strongText,
        height: 1.08,
      ),
      headlineMedium: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: AppColors.strongText,
        height: 1.12,
      ),
      titleLarge: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.strongText,
      ),
      titleMedium: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.strongText,
      ),
      bodyLarge: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.strongText,
      ),
      bodyMedium: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.strongText,
        height: 1.45,
      ),
      bodySmall: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.mutedText,
        height: 1.35,
      ),
      labelLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.strongText,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface.withValues(alpha: 0.94),
      height: 78,
      elevation: 0,
      shadowColor: AppColors.primary.withValues(alpha: 0.06),
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppColors.primary.withValues(alpha: 0.10),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? AppColors.primary : AppColors.mutedText,
        );
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? AppColors.primary : AppColors.mutedText,
        );
      }),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.accent.withValues(alpha: 0.12),
      side: const BorderSide(color: AppColors.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      labelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.strongText,
      ),
    ),
    dividerColor: AppColors.border,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 54),
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: const Size(0, 48),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      labelStyle: const TextStyle(color: AppColors.mutedText),
      hintStyle: const TextStyle(color: AppColors.mutedText),
      prefixIconColor: AppColors.mutedText,
      suffixIconColor: AppColors.mutedText,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        borderSide: const BorderSide(color: AppColors.error, width: 1.4),
      ),
    ),
    extensions: const [
      LuqmahThemeTokens(
        accent: AppColors.accent,
        mutedText: AppColors.mutedText,
        border: AppColors.border,
        success: AppColors.success,
        warning: AppColors.warning,
        info: AppColors.info,
      ),
    ],
  );
}
