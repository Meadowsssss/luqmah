import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF15343A);
  static const primaryAlt = Color(0xFF214D4A);
  static const accent = Color(0xFFFF6B57);
  static const background = Color(0xFFF6F7F9);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFEFF3F3);
  static const strongText = Color(0xFF122429);
  static const mutedText = Color(0xFF5F6B70);
  static const border = Color(0xFFD8E0E1);
  static const success = Color(0xFF1D8F55);
  static const warning = Color(0xFFC97A10);
  static const info = Color(0xFF0C87A8);
  static const error = Color(0xFFC2483C);
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
  static const lg = 20.0;
  static const xl = 24.0;
  static const hero = 28.0;
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
        height: 1.1,
      ),
      headlineMedium: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: AppColors.strongText,
        height: 1.15,
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
        height: 1.4,
      ),
      bodySmall: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.mutedText,
        height: 1.35,
      ),
      labelLarge: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
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
      backgroundColor: AppColors.surface,
      height: 72,
      elevation: 0,
      indicatorColor: AppColors.primary.withValues(alpha: 0.12),
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
          fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
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
        borderRadius: BorderRadius.circular(AppRadii.lg),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: AppColors.surfaceAlt,
      selectedColor: AppColors.accent.withValues(alpha: 0.12),
      side: const BorderSide(color: AppColors.border),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
      ),
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
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: const Size.fromHeight(48),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      labelStyle: const TextStyle(color: AppColors.mutedText),
      hintStyle: const TextStyle(color: AppColors.mutedText),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
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
