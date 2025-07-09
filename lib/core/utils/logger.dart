// lib/core/utils/logger.dart

import 'package:logger/logger.dart';

/// Sebuah instance global dari kelas `Logger` yang sudah dikonfigurasi.
///
/// Kita mendefinisikannya sebagai variabel global (top-level) agar bisa diakses
/// dengan mudah dari mana saja di dalam proyek tanpa perlu menginstansiasinya
/// berulang kali. Ini adalah pola yang umum untuk utilitas logging.
///
/// Konfigurasi `PrettyPrinter`:
/// - `methodCount`: Jumlah method dalam stack trace yang akan ditampilkan.
///   Berguna untuk melacak dari mana log dipanggil.
/// - `errorMethodCount`: Jumlah method dalam stack trace yang akan ditampilkan
///   khusus untuk log error. Biasanya kita ingin lebih detail di sini.
/// - `lineLength`: Panjang baris output.
/// - `colors`: Mengaktifkan output berwarna di konsol.
/// - `printEmojis`: Menampilkan emoji yang sesuai untuk setiap level log.
/// - `printTime`: Menampilkan timestamp saat log dibuat.
///
/// Level log default di `Logger` adalah `Level.verbose`, yang berarti semua
/// level log (verbose, debug, info, warning, error) akan ditampilkan.
/// Untuk build rilis, kita bisa mengubah levelnya menjadi `Level.nothing`
/// agar tidak ada log yang tercetak.
final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 1,
    errorMethodCount: 5,
    lineLength: 100,
    colors: true,
    printEmojis: true,
    printTime: false, // Bisa di set `true` jika ingin melihat waktu log
  ),
);