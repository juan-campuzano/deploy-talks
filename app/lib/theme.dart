import 'package:flutter/material.dart';

// ── Palette ──────────────────────────────────────────────────────────────────
class AppColors {
  AppColors._();

  static const bg = Color(0xFF07070F);
  static const surface = Color(0xFF0F0F1A);
  static const surfaceEl = Color(0xFF171726);
  static const surfaceHigh = Color(0xFF1F1F30);

  static const primary = Color(0xFF8B5CF6);
  static const primaryBright = Color(0xFFA78BFA);
  static const primaryDim = Color(0xFF4C1D95);

  static const accent = Color(0xFF34D399);
  static const accentDim = Color(0xFF064E3B);

  static const danger = Color(0xFFF87171);
  static const dangerDim = Color(0xFF450A0A);

  static const warning = Color(0xFFFBBF24);

  static const textPrimary = Color(0xFFF0F0FF);
  static const textSecondary = Color(0xFF8888AA);
  static const textMuted = Color(0xFF4A4A6A);

  static const border = Color(0xFF2A2A42);
  static const borderBright = Color(0xFF3D3D5C);
}

// ── Theme ─────────────────────────────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  static const _fontDisplay = 'Syne';
  static const _fontBody = 'Plus Jakarta Sans';

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme.dark(
        brightness: Brightness.dark,
        surface: AppColors.surface,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.accent,
        onSecondary: Colors.black,
        error: AppColors.danger,
        onSurface: AppColors.textPrimary,
        outline: AppColors.border,
        surfaceContainerHighest: AppColors.surfaceEl,
      ),
      textTheme: _textTheme,
      inputDecorationTheme: _inputTheme,
      filledButtonTheme: _filledButtonTheme,
      textButtonTheme: _textButtonTheme,
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: _appBarTheme,
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceEl,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border),
        ),
        titleTextStyle: const TextStyle(
          fontFamily: _fontDisplay,
          fontWeight: FontWeight.w700,
          fontSize: 20,
          color: AppColors.textPrimary,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: _fontBody,
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.textSecondary),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceEl,
        contentTextStyle: const TextStyle(
          fontFamily: _fontBody,
          color: AppColors.textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Text theme ──────────────────────────────────────────────────────────────
  static const _textTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: _fontDisplay,
      fontWeight: FontWeight.w800,
      fontSize: 57,
      color: AppColors.textPrimary,
      letterSpacing: -1.5,
    ),
    displayMedium: TextStyle(
      fontFamily: _fontDisplay,
      fontWeight: FontWeight.w700,
      fontSize: 45,
      color: AppColors.textPrimary,
      letterSpacing: -1,
    ),
    displaySmall: TextStyle(
      fontFamily: _fontDisplay,
      fontWeight: FontWeight.w700,
      fontSize: 36,
      color: AppColors.textPrimary,
      letterSpacing: -0.5,
    ),
    headlineLarge: TextStyle(
      fontFamily: _fontDisplay,
      fontWeight: FontWeight.w700,
      fontSize: 32,
      color: AppColors.textPrimary,
      letterSpacing: -0.5,
    ),
    headlineMedium: TextStyle(
      fontFamily: _fontDisplay,
      fontWeight: FontWeight.w700,
      fontSize: 26,
      color: AppColors.textPrimary,
      letterSpacing: -0.3,
    ),
    headlineSmall: TextStyle(
      fontFamily: _fontDisplay,
      fontWeight: FontWeight.w600,
      fontSize: 22,
      color: AppColors.textPrimary,
    ),
    titleLarge: TextStyle(
      fontFamily: _fontDisplay,
      fontWeight: FontWeight.w600,
      fontSize: 18,
      color: AppColors.textPrimary,
    ),
    titleMedium: TextStyle(
      fontFamily: _fontBody,
      fontWeight: FontWeight.w600,
      fontSize: 15,
      color: AppColors.textPrimary,
      letterSpacing: 0.1,
    ),
    titleSmall: TextStyle(
      fontFamily: _fontBody,
      fontWeight: FontWeight.w500,
      fontSize: 13,
      color: AppColors.textSecondary,
      letterSpacing: 0.1,
    ),
    bodyLarge: TextStyle(
      fontFamily: _fontBody,
      fontWeight: FontWeight.w400,
      fontSize: 16,
      color: AppColors.textPrimary,
    ),
    bodyMedium: TextStyle(
      fontFamily: _fontBody,
      fontWeight: FontWeight.w400,
      fontSize: 14,
      color: AppColors.textPrimary,
    ),
    bodySmall: TextStyle(
      fontFamily: _fontBody,
      fontWeight: FontWeight.w400,
      fontSize: 12,
      color: AppColors.textSecondary,
    ),
    labelLarge: TextStyle(
      fontFamily: _fontBody,
      fontWeight: FontWeight.w600,
      fontSize: 14,
      color: AppColors.textPrimary,
      letterSpacing: 0.1,
    ),
    labelMedium: TextStyle(
      fontFamily: _fontBody,
      fontWeight: FontWeight.w500,
      fontSize: 12,
      color: AppColors.textSecondary,
      letterSpacing: 0.5,
    ),
    labelSmall: TextStyle(
      fontFamily: _fontBody,
      fontWeight: FontWeight.w500,
      fontSize: 11,
      color: AppColors.textMuted,
      letterSpacing: 0.5,
    ),
  );

  // ── Input theme ─────────────────────────────────────────────────────────────
  static final _inputTheme = InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surfaceEl,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.danger),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    hintStyle: const TextStyle(
      fontFamily: _fontBody,
      color: AppColors.textMuted,
      fontSize: 14,
    ),
    labelStyle: const TextStyle(
      fontFamily: _fontBody,
      color: AppColors.textSecondary,
      fontSize: 14,
    ),
    floatingLabelStyle: const TextStyle(
      fontFamily: _fontBody,
      color: AppColors.primary,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
  );

  // ── Filled button theme ─────────────────────────────────────────────────────
  static final _filledButtonTheme = FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      minimumSize: const Size.fromHeight(48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(
        fontFamily: _fontBody,
        fontWeight: FontWeight.w600,
        fontSize: 15,
        letterSpacing: 0.2,
      ),
      elevation: 0,
    ),
  );

  // ── Text button theme ───────────────────────────────────────────────────────
  static final _textButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primaryBright,
      textStyle: const TextStyle(
        fontFamily: _fontBody,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );

  // ── AppBar theme ────────────────────────────────────────────────────────────
  static const _appBarTheme = AppBarTheme(
    backgroundColor: AppColors.bg,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(
      fontFamily: _fontDisplay,
      fontWeight: FontWeight.w700,
      fontSize: 18,
      color: AppColors.textPrimary,
    ),
    iconTheme: IconThemeData(color: AppColors.textSecondary),
    actionsIconTheme: IconThemeData(color: AppColors.textSecondary),
  );

}
