// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gsports/config/router/app_router.dart'; // Mengimpor provider GoRouter
import 'package:gsports/config/theme/app_theme.dart'; // Mengimpor tema aplikasi
import 'package:gsports/core/utils/logger.dart'; // Mengimpor logger kita

/// Fungsi `main` adalah titik masuk utama aplikasi Flutter.
Future<void> main() async {
  // Pastikan semua binding Flutter sudah siap sebelum menjalankan kode async.
  // Ini penting, terutama karena kita akan memuat file .env sebelum runApp().
  WidgetsFlutterBinding.ensureInitialized();

  // Memuat variabel lingkungan dari file .env.
  // Ini harus dilakukan sebelum runApp() agar variabelnya tersedia saat dibutuhkan.
  await dotenv.load(fileName: ".env");
  
  // Menjalankan aplikasi dengan membungkusnya dalam `ProviderScope`.
  // `ProviderScope` adalah widget dari Riverpod yang menyimpan state dari semua provider.
  // Semua widget di dalam `MyApp` akan dapat mengakses provider.
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

/// `MyApp` adalah widget root dari aplikasi.
///
/// Ini adalah `ConsumerWidget` dari Riverpod, yang memungkinkannya untuk
/// "mendengarkan" perubahan pada provider. Dalam kasus ini, kita menggunakannya
//  untuk mendapatkan instance GoRouter.
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 'ref.watch' digunakan untuk mendapatkan nilai dari provider dan
    // akan membuat widget ini membangun ulang jika nilai provider berubah.
    final router = ref.watch(goRouterProvider);
    
    // Mencatat log bahwa aplikasi telah berhasil diinisialisasi.
    logger.i("MyApp build called. Router has been initialized.");

    // MaterialApp.router adalah konstruktor yang digunakan saat kita
    // menyerahkan kontrol navigasi sepenuhnya ke sebuah router, seperti GoRouter.
    return MaterialApp.router(
      // Konfigurasi debug.
      debugShowCheckedModeBanner: false,

      // Judul aplikasi yang akan muncul di task manager perangkat.
      title: 'Gsports',

      // --- Konfigurasi Tema ---
      // Mengambil tema dari kelas AppTheme yang sudah kita definisikan.
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      // `ThemeMode.system` akan secara otomatis memilih tema terang atau gelap
      // berdasarkan pengaturan di sistem operasi perangkat pengguna.
      themeMode: ThemeMode.system,

      // --- Konfigurasi Router ---
      // Menyerahkan semua informasi rute ke instance GoRouter.
      routeInformationProvider: router.routeInformationProvider,
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
    );
  }
}