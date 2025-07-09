// lib/shared_widgets/error_display.dart

import 'package:flutter/material.dart';

/// `ErrorDisplay` adalah widget standar untuk menampilkan pesan error
/// secara konsisten di seluruh aplikasi.
///
/// Ia menampilkan ikon, judul, pesan error yang detail, dan sebuah
/// tombol opsional untuk mencoba lagi aksi yang gagal.
class ErrorDisplay extends StatelessWidget {
  /// Pesan error yang akan ditampilkan. Biasanya `error.toString()`.
  final String message;
  
  /// Callback opsional yang akan dieksekusi saat tombol "Coba Lagi" ditekan.
  /// Jika `null`, tombol tidak akan ditampilkan.
  final VoidCallback? onRetry;

  const ErrorDisplay({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: theme.colorScheme.error,
              size: 64,
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Terjadi Kesalahan',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              // Menampilkan pesan error yang diterima.
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
            
            // Hanya tampilkan tombol jika callback `onRetry` disediakan.
            if (onRetry != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  // Gunakan warna error untuk tombol retry agar konsisten
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}