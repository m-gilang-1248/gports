// lib/shared_widgets/custom_button.dart

import 'package:flutter/material.dart';

/// `CustomButton` adalah sebuah widget tombol serbaguna untuk aplikasi Gsports.
///
/// Widget ini membungkus `ElevatedButton` dan menambahkan fungsionalitas
/// untuk menampilkan indikator loading, yang sangat berguna untuk aksi
/// yang membutuhkan proses asynchronous (seperti login, registrasi, booking).
class CustomButton extends StatelessWidget {
  /// Teks yang akan ditampilkan di dalam tombol.
  final String text;

  /// Callback yang akan dieksekusi saat tombol ditekan.
  final VoidCallback onPressed;

  /// Sebuah flag untuk menentukan apakah tombol harus menampilkan
  /// indikator loading. Jika `true`, tombol akan dinonaktifkan dan
  /// menampilkan `CircularProgressIndicator`.
  final bool isLoading;

  final Color? backgroundColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor, // Tambahkan di constructor
  });

  @override
  Widget build(BuildContext context) {
    // Mengambil tema dari konteks untuk konsistensi.
    // Kita bisa menggunakan style dari tema atau mendefinisikannya langsung.
    final buttonStyle = Theme.of(context).elevatedButtonTheme.style;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;

    return SizedBox(
      // Mengatur lebar tombol agar memenuhi lebar kontainer induknya.
      width: double.infinity,
      child: ElevatedButton(
        style: buttonStyle,
        // Jika `isLoading`, `onPressed` akan di-set ke `null` untuk
        // menonaktifkan tombol secara otomatis.
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            // Jika `isLoading` true, tampilkan CircularProgressIndicator.
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: onPrimaryColor,
                  strokeWidth: 3,
                ),
              )
            // Jika tidak, tampilkan teks biasa.
            : Text(text),
      ),
    );
  }
}