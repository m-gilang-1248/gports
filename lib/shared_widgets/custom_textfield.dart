// lib/shared_widgets/custom_textfield.dart

import 'package:flutter/material.dart';

/// `CustomTextField` adalah sebuah widget `TextFormField` yang sudah di-styling
/// sesuai dengan tema aplikasi Gsports.
///
/// Ini menyederhanakan pembuatan form di seluruh aplikasi dan memastikan
/// semua input field memiliki tampilan dan nuansa yang konsisten.
class CustomTextField extends StatelessWidget {
  /// Controller untuk mengelola teks di dalam field.
  final TextEditingController controller;

  /// Teks petunjuk yang muncul saat field kosong.
  final String hintText;

  /// Validator untuk input. Mengembalikan string error jika tidak valid,
  /// atau `null` jika valid.
  final String? Function(String?)? validator;

  /// Jenis keyboard yang akan ditampilkan.
  final TextInputType keyboardType;

  /// Flag untuk menyembunyikan teks (berguna untuk password).
  final bool isObscure;

  /// Ikon yang ditampilkan di sebelah kiri (prefix) field.
  final IconData? prefixIcon;

  /// Widget yang ditampilkan di sebelah kanan (suffix) field.
  /// Berguna untuk tombol lihat/sembunyikan password.
  final Widget? suffixIcon;
  final int maxLines;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.isObscure = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1
  });

  @override
  Widget build(BuildContext context) {
    // --- PERBAIKAN: Kita tidak lagi mengambil inputDecorationTheme secara manual. ---
    // TextFormField secara otomatis akan menggunakan tema yang didefinisikan
    // di `AppTheme.dart` sebagai dasarnya.
    
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: isObscure,
      // Kita langsung membuat instance `InputDecoration` di sini.
      // Properti yang tidak kita atur di sini (seperti `filled`, `fillColor`, `border`)
      // akan secara otomatis diambil dari `inputDecorationTheme` di tema global kita.
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                // Kita tetap perlu mengatur warna ikon secara manual di sini
                // agar konsisten.
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              )
            : null,
        suffixIcon: suffixIcon,
      ),
    );
  }
}