// lib/config/theme/app_colors.dart

import 'package:flutter/material.dart';

/// Kelas `AppColors` berisi definisi palet warna statis untuk aplikasi Gsports.
///
/// Tujuannya adalah untuk memusatkan semua definisi warna di satu tempat
/// agar mudah dikelola dan memastikan konsistensi di seluruh aplikasi.
///
/// Pola yang digunakan adalah membuat kelas dengan constructor privat
/// dan semua properti sebagai `static const`, sehingga tidak perlu diinstansiasi.
class AppColors {
  // Constructor privat untuk mencegah instansiasi kelas.
  AppColors._();

  // --- Warna Utama (Brand Colors) ---
  // Warna-warna ini mendefinisikan identitas brand Gsports.
  // Berdasarkan preferensi: Navy (sekunder) dan Teal (aksen).
  static const Color navy = Color(0xFF001f3f);
  static const Color teal = Color(0xFF39CCCC);

  // --- Warna Berdasarkan Tema (Light Mode) ---
  // Warna-warna ini digunakan saat aplikasi dalam mode terang (light mode).
  static const Color lightPrimary = navy; // Warna utama untuk elemen penting
  static const Color lightSecondary = teal; // Warna aksen untuk tombol, link, dll.
  static const Color lightBackground = Color(0xFFF5F5F7); // Latar belakang utama, sedikit off-white
  static const Color lightSurface = Colors.white; // Warna untuk card, dialog, app bar
  static const Color lightOnPrimary = Colors.white; // Teks di atas warna primary
  static const Color lightOnSecondary = Colors.white; // Teks di atas warna secondary
  static const Color lightOnBackground = Color(0xFF1c1c1e); // Teks utama
  static const Color lightOnSurface = Color(0xFF1c1c1e); // Teks pada card, dialog
  static const Color lightError = Color(0xFFB00020); // Warna untuk pesan error

  // --- Warna Berdasarkan Tema (Dark Mode) ---
  // Warna-warna ini digunakan saat aplikasi dalam mode gelap (dark mode).
  static const Color darkPrimary = Color(0xFF00C853); // Kita tetap pakai navy agar brand konsisten
  static const Color darkSecondary = teal; // Aksen tetap teal agar menonjol
  static const Color darkBackground = Color(0xFF121212); // Latar belakang abu-abu sangat gelap
  static const Color darkSurface = Color(0xFF1E1E1E); // Warna untuk card, dialog (sedikit lebih terang dari background)
  static const Color darkOnPrimary = Colors.white;
  static const Color darkOnSecondary = Colors.white;
  static const Color darkOnBackground = Color(0xFFE4E4E6); // Teks utama (putih pudar)
  static const Color darkOnSurface = Color(0xFFE4E4E6); // Teks pada card, dialog
  static const Color darkError = Color(0xFFCF6679); // Warna error yang kontras di mode gelap

  // --- Warna Status & Utilitas ---
  // Warna-warna ini memiliki makna semantik dan digunakan di berbagai tempat.
  static const Color success = Color(0xFF28a745);  // Hijau untuk pesan sukses, booking terkonfirmasi
  static const Color warning = Color(0xFFffc107);  // Kuning untuk peringatan, booking menunggu pembayaran
  static const Color info = Color(0xFF17a2b8);     // Biru untuk informasi umum
  static const Color disabled = Colors.grey;      // Abu-abu untuk elemen yang tidak aktif
  
  // --- Warna Gradasi (Opsional) ---
  // Bisa digunakan untuk banner atau background yang lebih menarik.
  static const Gradient primaryGradient = LinearGradient(
    colors: [navy, teal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}