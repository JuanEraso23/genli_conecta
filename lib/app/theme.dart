import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color verdePrincipal = Color(0xFF005C3F);
  static const Color verdeOscuro = Color(0xFF00462F);
  static const Color verdeTexto = Color(0xFF174F3B);
  static const Color verdeSecundario = Color(0xFF75A989);
  static const Color verdeClaro = Color(0xFFE8F2ED);

  static const Color amarillo = Color(0xFFF9B233);

  static const Color blanco = Color(0xFFFFFFFF);
  static const Color fondoCampo = Color(0xFFF9FAF9);
  static const Color fondoClaro = Color(0xFFF0F6F2);

  static const Color textoSecundario = Color(0xFF66756F);
  static const Color textoCampo = Color(0xFF52635C);
  static const Color textoSugerencia = Color(0xFF9A9F9C);

  static const Color bordeCampo = Color(0xFFD9DEDB);
  static const Color error = Color(0xFFB3261E);
}

abstract final class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: AppColors.fondoClaro,

      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.verdePrincipal,
        primary: AppColors.verdePrincipal,
        secondary: AppColors.amarillo,
        surface: AppColors.blanco,
        error: AppColors.error,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.verdePrincipal,
        foregroundColor: AppColors.blanco,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.blanco,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.fondoCampo,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: const TextStyle(
          color: AppColors.textoSugerencia,
          fontSize: 14,
        ),
        labelStyle: const TextStyle(color: AppColors.textoCampo),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: AppColors.bordeCampo),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: AppColors.bordeCampo),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(
            color: AppColors.verdePrincipal,
            width: 1.8,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: AppColors.error, width: 1.8),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.verdePrincipal,
          foregroundColor: AppColors.blanco,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.verdePrincipal,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.verdeOscuro,
        contentTextStyle: TextStyle(color: AppColors.blanco),
      ),
    );
  }
}
