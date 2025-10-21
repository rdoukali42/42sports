import 'package:flutter/material.dart';

class AppTheme {
  // 42 Heilbronn Brand Colors - Modern Minimalist Style
  static const Color neonGreen = Color(0xFF00FF85); // Signature 42 neon green
  static const Color primary = neonGreen;
  static const Color deepBlack = Color(0xFF000000);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color darkGray = Color(0xFF1A1A1A);
  static const Color mediumGray = Color(0xFF757575);
  static const Color lightGray = Color(0xFFEEEEEE);
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color error = Color(0xFFFF3B3B);
  static const Color success = neonGreen;
  
  // Aliases for backward compatibility
  static const Color fortytwoCyan = neonGreen;
  static const Color fortytwoBlue = deepBlack;
  static const Color background = pureWhite;
  static const Color surface = pureWhite;
  static const Color secondary = neonGreen;
  static const Color textPrimary = deepBlack;
  static const Color textSecondary = mediumGray;

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: neonGreen,
      scaffoldBackgroundColor: pureWhite,
      fontFamily: 'Inter', // Modern sans-serif (fallback to system font)
      colorScheme: const ColorScheme.light(
        primary: neonGreen,
        secondary: neonGreen,
        surface: pureWhite,
        error: error,
        onPrimary: deepBlack,
        onSecondary: deepBlack,
        onSurface: deepBlack,
        onError: pureWhite,
        outline: lightGray,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: pureWhite,
        foregroundColor: deepBlack,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: deepBlack,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
        iconTheme: IconThemeData(color: deepBlack),
      ),
      cardTheme: CardThemeData(
        color: pureWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: lightGray, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: neonGreen,
          foregroundColor: deepBlack,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24), // Pill-shaped buttons
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: deepBlack,
          side: const BorderSide(color: deepBlack, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightGray, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: neonGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: backgroundLight,
        selectedColor: neonGreen,
        labelStyle: const TextStyle(color: deepBlack, fontFamily: 'Inter'),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: pureWhite,
        indicatorColor: neonGreen.withOpacity(0.2),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: neonGreen, size: 24);
          }
          return const IconThemeData(color: mediumGray, size: 24);
        }),
        elevation: 0,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: deepBlack,
          fontSize: 57,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          color: deepBlack,
          fontSize: 45,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
          letterSpacing: -0.5,
        ),
        displaySmall: TextStyle(
          color: deepBlack,
          fontSize: 36,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
        headlineLarge: TextStyle(
          color: deepBlack,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
        headlineMedium: TextStyle(
          color: deepBlack,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
        headlineSmall: TextStyle(
          color: deepBlack,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
        titleLarge: TextStyle(
          color: deepBlack,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
        titleMedium: TextStyle(
          color: deepBlack,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
        titleSmall: TextStyle(
          color: deepBlack,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
        bodyLarge: TextStyle(
          color: deepBlack,
          fontSize: 16,
          fontWeight: FontWeight.normal,
          fontFamily: 'Inter',
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: mediumGray,
          fontSize: 14,
          fontWeight: FontWeight.normal,
          fontFamily: 'Inter',
          height: 1.5,
        ),
        bodySmall: TextStyle(
          color: mediumGray,
          fontSize: 12,
          fontWeight: FontWeight.normal,
          fontFamily: 'Inter',
        ),
        labelLarge: TextStyle(
          color: deepBlack,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: lightGray,
        thickness: 1,
        space: 24,
      ),
    );
  }
}
