// lib/core/utils/snackbar.dart

import 'package:flutter/material.dart';
import 'package:gsports/config/theme/app_colors.dart'; // Mengimpor palet warna kita

/// Menampilkan `SnackBar` kustom di bagian bawah layar.
///
/// Fungsi ini adalah helper global untuk menampilkan feedback kepada pengguna
/// dengan cara yang konsisten di seluruh aplikasi.
///
/// [context]: `BuildContext` dari widget pemanggil, diperlukan untuk menemukan `ScaffoldMessenger`.
/// [message]: Teks yang akan ditampilkan di dalam `SnackBar`.
/// [isError]: Flag opsional. Jika `true`, `SnackBar` akan memiliki warna latar
///            merah (error), jika `false` (default), akan menggunakan warna
///            abu-abu gelap sebagai penanda informasi.
void showSnackBar(BuildContext context, String message, {bool isError = false}) {
  // Pertama, kita hapus SnackBar yang mungkin sedang ditampilkan
  // untuk mencegah tumpukan SnackBar jika aksi terjadi berurutan dengan cepat.
  ScaffoldMessenger.of(context).hideCurrentSnackBar();

  // Kemudian, kita tampilkan SnackBar yang baru.
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      // Konten utama dari SnackBar.
      content: Text(
        message,
        style: const TextStyle(
          color: Colors.white, // Warna teks selalu putih agar kontras
          fontWeight: FontWeight.w500,
        ),
      ),
      
      // Mengatur warna latar belakang berdasarkan status error.
      // Kita menggunakan warna dari AppColors untuk konsistensi.
      backgroundColor: isError
          ? AppColors.lightError // atau AppColors.darkError tergantung tema
          : Colors.black87, // Warna netral untuk pesan info
          
      // Mengatur perilaku SnackBar agar mengambang di atas konten lain,
      // bukan mendorongnya ke atas.
      behavior: SnackBarBehavior.floating,

      // Memberi sedikit radius pada sudut SnackBar agar sesuai dengan
      // tema umum aplikasi (misal: tombol dan card yang rounded).
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      
      // Sedikit margin agar tidak menempel di tepi layar.
      margin: const EdgeInsets.all(12.0),
    ),
  );
}