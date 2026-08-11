import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_typography.dart';
import 'tokens.dart';

/// Builds the ThemeData for a given semantic palette.
/// Dark is the product default (Foundations Frame 01: «Dark Mode default»).
abstract final class AppTheme {
  static ThemeData dark() => _build(AppColors.dark);
  static ThemeData light() => _build(AppColors.light);

  static ThemeData _build(AppColors c) {
    final t = AppTextStyles.base;

    return ThemeData(
      useMaterial3: true,
      brightness: c.brightness,
      scaffoldBackgroundColor: c.backgroundApp,
      canvasColor: c.backgroundApp,
      fontFamily: AppFonts.persian,
      fontFamilyFallback: AppFonts.fallback,
      extensions: [c, t],

      colorScheme: ColorScheme(
        brightness: c.brightness,
        primary: c.actionPrimary,
        onPrimary: c.onAction,
        secondary: c.premium,
        onSecondary: Neutral.n1000,
        error: c.danger,
        onError: c.onAction,
        surface: c.surfacePrimary,
        onSurface: c.textPrimary,
        outline: c.borderDefault,
      ),

      dividerTheme: DividerThemeData(
        color: c.divider,
        thickness: 1,
        space: 1,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: c.backgroundApp,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: t.h3.copyWith(color: c.textPrimary),
        iconTheme: IconThemeData(color: c.textPrimary, size: 24),
        systemOverlayStyle: c.isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),

      cardTheme: CardThemeData(
        color: c.surfacePrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.card),
          side: BorderSide(color: c.borderDefault),
        ),
      ),

      // Depth on dark surfaces comes from tonal difference + a hairline border,
      // not from heavy shadows (Foundations Frame 04).
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surfacePrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        showDragHandle: true,
        dragHandleColor: c.borderDefault,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.sheet)),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surfaceSecondary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Space.s4,
          vertical: Space.s3,
        ),
        hintStyle: t.bodyMedium.copyWith(color: c.textMuted),
        labelStyle: t.bodySmall.copyWith(color: c.textSecondary),
        errorStyle: t.caption.copyWith(color: c.danger),
        border: _inputBorder(c.borderDefault),
        enabledBorder: _inputBorder(c.borderDefault),
        focusedBorder: _inputBorder(c.borderActive, width: 1.5),
        errorBorder: _inputBorder(c.danger),
        focusedErrorBorder: _inputBorder(c.danger, width: 1.5),
        disabledBorder: _inputBorder(c.actionDisabled),
      ),

      textTheme: TextTheme(
        displayLarge: t.displayLarge.copyWith(color: c.textPrimary),
        displaySmall: t.displaySmall.copyWith(color: c.textPrimary),
        headlineMedium: t.h1.copyWith(color: c.textPrimary),
        headlineSmall: t.h2.copyWith(color: c.textPrimary),
        titleLarge: t.h3.copyWith(color: c.textPrimary),
        bodyLarge: t.bodyLarge.copyWith(color: c.textPrimary),
        bodyMedium: t.bodyMedium.copyWith(color: c.textPrimary),
        bodySmall: t.bodySmall.copyWith(color: c.textSecondary),
        labelMedium: t.caption.copyWith(color: c.textMuted),
        labelSmall: t.micro.copyWith(color: c.textMuted),
      ),

      iconTheme: IconThemeData(color: c.textSecondary, size: 24),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.surfaceSecondary,
        contentTextStyle: t.bodySmall.copyWith(color: c.textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.md),
        ),
      ),

      splashFactory: InkSparkle.splashFactory,
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.input),
        borderSide: BorderSide(color: color, width: width),
      );
}
