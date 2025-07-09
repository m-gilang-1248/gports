// lib/features/1_home/controller/home_controller.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gsports/config/router/route_names.dart';
import 'package:gsports/core/utils/snackbar.dart';

// --- 1. Provider untuk HomeController ---
// Kita hanya menggunakan `Provider` biasa karena controller ini tidak
// secara langsung mengelola sebuah state yang kompleks yang perlu 'diawasi'
// oleh UI secara terus-menerus. Ia lebih berfungsi sebagai penyedia method.
final homeControllerProvider = Provider.autoDispose<HomeController>((ref) {
  // Controller ini tidak memiliki dependency ke repository karena aksi utamanya
  // adalah navigasi. Logika pengambilan data akan ada di controller halaman berikutnya.
  return HomeController(ref: ref);
});


// --- 2. Kelas HomeController ---
class HomeController {
  final Ref _ref;

  HomeController({required Ref ref}) : _ref = ref;

  /// Method yang akan dipanggil dari `HomeScreen` saat pengguna menekan
  /// tombol cari.
  ///
  /// Tugasnya adalah mengambil input dari UI, memvalidasinya, dan kemudian
  /// melakukan navigasi ke halaman hasil pencarian (`SCListScreen`)
  /// sambil membawa parameter pencarian.
  void search({
    required BuildContext context,
    required String city,
    required String sport, // Untuk saat ini mungkin belum digunakan di query
  }) {
    // Validasi input sederhana.
    if (city.trim().isEmpty) {
      showSnackBar(context, 'Kota atau lokasi tidak boleh kosong.', isError: true);
      return; // Hentikan eksekusi jika tidak valid.
    }
    
    if (sport.trim().isEmpty) {
      showSnackBar(context, 'Jenis olahraga tidak boleh kosong.', isError: true);
      return;
    }

    // Jika valid, lakukan navigasi menggunakan GoRouter.
    // Kita akan menavigasi ke rute `searchResults` dan mengirimkan
    // parameter pencarian sebagai `queryParameters`.
    // Contoh URL yang akan dihasilkan: /home/search?city=Jakarta&sport=futsal
    context.goNamed(
      RouteNames.searchResults,
      queryParameters: {
        'city': city.trim(),
        'sport': sport.trim(),
      },
    );
  }
  
  // NOTE: Di masa depan, kita bisa menambahkan fungsi lain di sini, seperti:
  // void getPromotions() { ... }
  // void getPopularSCs() { ... }
}