import 'package:flutter/material.dart';

class AppTheme {
  // Paleta de cores harmoniosa para NFCGuard inspirada em tons frios e profissionais
  static const Color _primaryBlue = Color(0xFF3C9EFE); // Azul oceano mais suave
  static const Color _secondaryTeal = Color(
    0xFF5DACE8,
  ); // Azul-verde harmonioso
  static const Color _accentTurquoise = Color(
    0xFF47ACA6,
  ); // Turquesa profissional
  static const Color _errorRed = Color(0xFFE53935);

  static ThemeData get lightTheme {
    const lightColorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: _primaryBlue,
      onPrimary: Colors.white,
      secondary: _secondaryTeal,
      onSecondary: Colors.white,
      tertiary: _accentTurquoise,
      onTertiary: Colors.white,
      error: _errorRed,
      onError: Colors.white,
      surface: Color(0xFFFAFAFA),
      onSurface: Color(0xFF1A1A1A),
      surfaceContainerHighest: Color(0xFFE8E8E8),
      outline: Color(0xFFBDBDBD),
      outlineVariant: Color(0xFFE0E0E0),
      inverseSurface: Color(0xFF2C2C2C),
      onInverseSurface: Color(0xFFF5F5F5),
      inversePrimary: Color(0xFF90CAF9),
      surfaceTint: _primaryBlue,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: lightColorScheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: lightColorScheme.surface,
        foregroundColor: lightColorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          shadowColor: Colors.black26,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: lightColorScheme.outline),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: lightColorScheme.surface,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightColorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightColorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightColorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightColorScheme.error),
        ),
        contentPadding: const EdgeInsets.all(16),
        filled: true,
        fillColor: lightColorScheme.surface,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: lightColorScheme.inverseSurface,
        contentTextStyle: TextStyle(color: lightColorScheme.onInverseSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static ThemeData get darkTheme {
    const darkColorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: _primaryBlue,
      onPrimary: Colors.white,
      secondary: _secondaryTeal,
      onSecondary: Colors.white,
      tertiary: _accentTurquoise,
      onTertiary: Colors.white,
      error: Color(0xFFEF5350),
      onError: Color(0xFFB71C1C),
      surface: Color(0xFF121212),
      onSurface: Color(0xFFE0E0E0),
      surfaceContainerHighest: Color(0xFF2C2C2C),
      outline: Color(0xFF616161),
      outlineVariant: Color(0xFF424242),
      inverseSurface: Color(0xFFF5F5F5),
      onInverseSurface: Color(0xFF1A1A1A),
      inversePrimary: _primaryBlue,
      surfaceTint: Color(0xFF90CAF9),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: darkColorScheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: darkColorScheme.surface,
        foregroundColor: darkColorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: Colors.black54,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: darkColorScheme.outline),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 8,
        shadowColor: Colors.black54,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: darkColorScheme.surfaceContainerHighest,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkColorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkColorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkColorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkColorScheme.error),
        ),
        contentPadding: const EdgeInsets.all(16),
        filled: true,
        fillColor: darkColorScheme.surfaceContainerHighest,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkColorScheme.inverseSurface,
        contentTextStyle: TextStyle(color: darkColorScheme.onInverseSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
