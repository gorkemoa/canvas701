import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'canvas701_theme_data.dart';

/// Canvas701 Flutter Theme
class Canvas701Theme {
  Canvas701Theme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Renk Şeması
      colorScheme: const ColorScheme.light(
        primary: Canvas701Colors.primary,
        onPrimary: Canvas701Colors.textOnPrimary,
        secondary: Canvas701Colors.accent,
        onSecondary: Canvas701Colors.textOnPrimary,
        surface: Canvas701Colors.surface,
        onSurface: Canvas701Colors.textPrimary,
        error: Canvas701Colors.error,
        onError: Canvas701Colors.textOnPrimary,
      ),

      // Scaffold
      scaffoldBackgroundColor: Canvas701Colors.background,

      // AppBar
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Canvas701Colors.surface,
        foregroundColor: Canvas701Colors.textPrimary,
        centerTitle: true,
        titleTextStyle: Canvas701Typography.titleLarge,
        iconTheme: IconThemeData(
          color: Canvas701Colors.textPrimary,
          size: 24,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Canvas701Colors.surface,
        selectedItemColor: Canvas701Colors.primary,
        unselectedItemColor: Canvas701Colors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: Canvas701Typography.labelSmall,
        unselectedLabelStyle: Canvas701Typography.labelSmall,
      ),

      // Card
      cardTheme: CardThemeData(
        color: Canvas701Colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: Canvas701Radius.cardRadius,
        ),
        margin: EdgeInsets.zero,
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Canvas701Colors.primary,
          foregroundColor: Canvas701Colors.textOnPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: Canvas701Spacing.lg,
            vertical: Canvas701Spacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: Canvas701Radius.buttonRadius,
          ),
          textStyle: Canvas701Typography.button,
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Canvas701Colors.primary,
          side: const BorderSide(
            color: Canvas701Colors.primary,
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: Canvas701Spacing.lg,
            vertical: Canvas701Spacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: Canvas701Radius.buttonRadius,
          ),
          textStyle: Canvas701Typography.button,
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Canvas701Colors.primary,
          textStyle: Canvas701Typography.button,
        ),
      ),

      // Icon Button
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: Canvas701Colors.textPrimary,
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Canvas701Colors.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Canvas701Spacing.md,
          vertical: Canvas701Spacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: Canvas701Radius.buttonRadius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: Canvas701Radius.buttonRadius,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: Canvas701Radius.buttonRadius,
          borderSide: const BorderSide(
            color: Canvas701Colors.primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: Canvas701Radius.buttonRadius,
          borderSide: const BorderSide(
            color: Canvas701Colors.error,
            width: 1.5,
          ),
        ),
        hintStyle: Canvas701Typography.bodyMedium.copyWith(
          color: Canvas701Colors.textTertiary,
        ),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: Canvas701Colors.surfaceVariant,
        selectedColor: Canvas701Colors.primary,
        labelStyle: Canvas701Typography.labelMedium,
        padding: const EdgeInsets.symmetric(
          horizontal: Canvas701Spacing.sm,
          vertical: Canvas701Spacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: Canvas701Radius.chipRadius,
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: Canvas701Colors.divider,
        thickness: 1,
        space: 1,
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Canvas701Colors.primary,
        contentTextStyle: Canvas701Typography.bodyMedium.copyWith(
          color: Canvas701Colors.textOnPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: Canvas701Radius.buttonRadius,
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Bottom Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Canvas701Colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(Canvas701Radius.lg),
          ),
        ),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: Canvas701Colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: Canvas701Radius.cardRadius,
        ),
        titleTextStyle: Canvas701Typography.headlineSmall,
        contentTextStyle: Canvas701Typography.bodyMedium,
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: Canvas701Typography.displayLarge,
        displayMedium: Canvas701Typography.displayMedium,
        displaySmall: Canvas701Typography.displaySmall,
        headlineLarge: Canvas701Typography.headlineLarge,
        headlineMedium: Canvas701Typography.headlineMedium,
        headlineSmall: Canvas701Typography.headlineSmall,
        titleLarge: Canvas701Typography.titleLarge,
        titleMedium: Canvas701Typography.titleMedium,
        titleSmall: Canvas701Typography.titleSmall,
        bodyLarge: Canvas701Typography.bodyLarge,
        bodyMedium: Canvas701Typography.bodyMedium,
        bodySmall: Canvas701Typography.bodySmall,
        labelLarge: Canvas701Typography.labelLarge,
        labelMedium: Canvas701Typography.labelMedium,
        labelSmall: Canvas701Typography.labelSmall,
      ),
    );
  }
}
