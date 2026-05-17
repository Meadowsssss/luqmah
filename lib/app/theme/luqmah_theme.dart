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
    required this.primary,
    required this.surface,
    required this.surfaceAlt,
    required this.background,
    required this.strongText,
    required this.accent,
    required this.mutedText,
    required this.border,
    required this.success,
    required this.warning,
    required this.info,
  });

  final Color primary;
  final Color surface;
  final Color surfaceAlt;
  final Color background;
  final Color strongText;
  final Color accent;
  final Color mutedText;
  final Color border;
  final Color success;
  final Color warning;
  final Color info;

  @override
  LuqmahThemeTokens copyWith({
    Color? primary,
    Color? surface,
    Color? surfaceAlt,
    Color? background,
    Color? strongText,
    Color? accent,
    Color? mutedText,
    Color? border,
    Color? success,
    Color? warning,
    Color? info,
  }) {
    return LuqmahThemeTokens(
      primary: primary ?? this.primary,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      background: background ?? this.background,
      strongText: strongText ?? this.strongText,
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
      primary: Color.lerp(primary, other.primary, t) ?? primary,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t) ?? surfaceAlt,
      background: Color.lerp(background, other.background, t) ?? background,
      strongText: Color.lerp(strongText, other.strongText, t) ?? strongText,
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
        primary: AppColors.primary,
        surface: AppColors.surface,
        surfaceAlt: AppColors.surfaceAlt,
        background: AppColors.background,
        strongText: AppColors.strongText,
        accent: AppColors.accent,
        mutedText: AppColors.mutedText,
        border: AppColors.border,
        success: AppColors.success,
        warning: AppColors.warning,
        info: AppColors.info,
      );
}

ThemeData buildLuqmahTheme() {
  return _buildLuqmahTheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    primaryAlt: AppColors.primaryAlt,
    accent: AppColors.accent,
    background: AppColors.background,
    surface: AppColors.surface,
    surfaceAlt: AppColors.surfaceAlt,
    strongText: AppColors.strongText,
    mutedText: AppColors.mutedText,
    border: AppColors.border,
    success: AppColors.success,
    warning: AppColors.warning,
    info: AppColors.info,
    error: AppColors.error,
  );
}

ThemeData buildLuqmahDarkTheme() {
  return _buildLuqmahTheme(
    brightness: Brightness.dark,
    primary: const Color(0xFF76C891),
    primaryAlt: const Color(0xFF4E9E68),
    accent: const Color(0xFF9CCFA8),
    background: const Color(0xFF0E1712),
    surface: const Color(0xFF17231B),
    surfaceAlt: const Color(0xFF223328),
    strongText: const Color(0xFFEAF3EA),
    mutedText: const Color(0xFFA9B9AC),
    border: const Color(0xFF314536),
    success: const Color(0xFF86D99A),
    warning: const Color(0xFFE2BD68),
    info: const Color(0xFF8DC8C1),
    error: const Color(0xFFFF8D7E),
  );
}

ThemeData _buildLuqmahTheme({
  required Brightness brightness,
  required Color primary,
  required Color primaryAlt,
  required Color accent,
  required Color background,
  required Color surface,
  required Color surfaceAlt,
  required Color strongText,
  required Color mutedText,
  required Color border,
  required Color success,
  required Color warning,
  required Color info,
  required Color error,
}) {
  final colorScheme = ColorScheme(
    brightness: brightness,
    primary: primary,
    onPrimary: brightness == Brightness.dark
        ? const Color(0xFF082111)
        : Colors.white,
    secondary: accent,
    onSecondary: brightness == Brightness.dark
        ? const Color(0xFF082111)
        : Colors.white,
    error: error,
    onError: brightness == Brightness.dark
        ? const Color(0xFF240D0A)
        : Colors.white,
    surface: surface,
    onSurface: strongText,
  );

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: background,
    brightness: brightness,
    fontFamily: 'Inter',
  );

  return base.copyWith(
    textTheme: base.textTheme.copyWith(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: strongText,
        height: 1.08,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: strongText,
        height: 1.12,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: strongText,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: strongText,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: strongText,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: strongText,
        height: 1.45,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: mutedText,
        height: 1.35,
      ),
      labelLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      foregroundColor: strongText,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surface.withValues(alpha: 0.95),
      height: 78,
      elevation: 0,
      shadowColor: primary.withValues(alpha: 0.08),
      surfaceTintColor: Colors.transparent,
      indicatorColor: primary.withValues(alpha: 0.14),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(color: selected ? primary : mutedText);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? primary : mutedText,
        );
      }),
    ),
    cardTheme: CardThemeData(
      color: surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        side: BorderSide(color: border),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: surface,
      selectedColor: accent.withValues(
        alpha: brightness == Brightness.dark ? 0.20 : 0.12,
      ),
      side: BorderSide(color: border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: strongText,
      ),
    ),
    dividerColor: border,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
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
        foregroundColor: primary,
        minimumSize: const Size(0, 48),
        side: BorderSide(color: border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      labelStyle: TextStyle(color: mutedText),
      hintStyle: TextStyle(color: mutedText),
      prefixIconColor: mutedText,
      suffixIconColor: mutedText,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        borderSide: BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        borderSide: BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        borderSide: BorderSide(color: primary, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        borderSide: BorderSide(color: error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        borderSide: BorderSide(color: error, width: 1.4),
      ),
    ),
    extensions: [
      LuqmahThemeTokens(
        primary: primary,
        surface: surface,
        surfaceAlt: surfaceAlt,
        background: background,
        strongText: strongText,
        accent: accent,
        mutedText: mutedText,
        border: border,
        success: success,
        warning: warning,
        info: info,
      ),
    ],
  );
}
