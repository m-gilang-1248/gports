// lib/config/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:gsports/config/theme/app_colors.dart'; // Mengimpor palet warna kita

/// Kelas `AppTheme` menyediakan definisi tema terpusat untuk aplikasi.
///
/// Ini mencakup tema untuk mode terang (light) dan gelap (dark),
/// memastikan konsistensi visual di seluruh aplikasi.
class AppTheme {
  // Constructor privat untuk mencegah instansiasi.
  AppTheme._();

  /// Definisi tema untuk Light Mode.
  static final ThemeData lightTheme = ThemeData(
    // Menggunakan Material 3 untuk komponen yang lebih modern.
    useMaterial3: true,
    
    // Skema warna utama untuk light mode.
    colorScheme: const ColorScheme.light(
      primary: AppColors.lightPrimary,
      onPrimary: AppColors.lightOnPrimary,
      secondary: AppColors.lightSecondary,
      onSecondary: AppColors.lightOnSecondary,
      background: AppColors.lightBackground,
      onBackground: AppColors.lightOnBackground,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightOnSurface,
      error: AppColors.lightError,
      onError: Colors.white,
      brightness: Brightness.light,
    ),
    
    // Warna dasar lainnya.
    scaffoldBackgroundColor: AppColors.lightBackground,
    primaryColor: AppColors.lightPrimary,

    // Tema untuk AppBar.
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: AppColors.lightSurface,
      foregroundColor: AppColors.lightOnSurface, // Warna untuk judul dan ikon
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.lightOnSurface),
      titleTextStyle: TextStyle(
        color: AppColors.lightOnSurface,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    // Tema untuk Tombol.
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightPrimary,
        foregroundColor: AppColors.lightOnPrimary,
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    // Tema untuk Input Fields (TextFormField).
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightSurface,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightPrimary, width: 2),
      ),
      hintStyle: TextStyle(color: Colors.grey.shade500),
    ),

    // Tema untuk Card.
    cardTheme: CardTheme(
      elevation: 2,
      color: AppColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
    ),
    
    // (Opsional) Definisikan tema teks jika diperlukan
    // textTheme: ...
  );

  /// Definisi tema untuk Dark Mode.
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    
    // Skema warna utama untuk dark mode.
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkPrimary,
      onPrimary: AppColors.darkOnPrimary,
      secondary: AppColors.darkSecondary,
      onSecondary: AppColors.darkOnSecondary,
      background: AppColors.darkBackground,
      onBackground: AppColors.darkOnBackground,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkOnSurface,
      error: AppColors.darkError,
      onError: Colors.black,
      brightness: Brightness.dark,
    ),

    // Warna dasar lainnya.
    scaffoldBackgroundColor: AppColors.darkBackground,
    primaryColor: AppColors.darkPrimary,

    // Tema untuk AppBar.
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: AppColors.darkSurface,
      foregroundColor: AppColors.darkOnSurface,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.darkOnSurface),
      titleTextStyle: TextStyle(
        color: AppColors.darkOnSurface,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    // Tema untuk Tombol.
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkPrimary,
        foregroundColor: AppColors.darkOnPrimary,
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    
    // Tema untuk Input Fields (TextFormField).
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkPrimary, width: 2),
      ),
      hintStyle: TextStyle(color: Colors.grey.shade600),
    ),

    // Tema untuk Card.
    cardTheme: CardTheme(
      elevation: 4,
      color: AppColors.darkSurface,
      shadowColor: Colors.black.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
    ),
  );
}