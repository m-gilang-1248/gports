// lib/features/2_sc_list/controller/sc_list_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gsports/core/models/sc_model.dart';
import 'package:gsports/features/1_home/repository/home_repository.dart';

// --- 1. Kelas Parameter Pencarian (Best Practice) ---
// Membuat kelas khusus untuk parameter membuat kode lebih bersih,
// lebih mudah dibaca, dan lebih mudah diperluas di masa depan.
// Kita juga meng-override `==` dan `hashCode` agar Riverpod bisa
// mem-cache hasilnya dengan benar (tidak membuat request baru jika parameternya sama).
class SearchParams {
  final String city;
  final String sport;

  SearchParams({required this.city, required this.sport});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchParams && other.city == city && other.sport == sport;
  }

  @override
  int get hashCode => city.hashCode ^ sport.hashCode;
}


// --- 2. Provider untuk Hasil Pencarian ---
/// `scListProvider` adalah `FutureProvider.family`.
///
/// 'FutureProvider': karena ia akan mengambil data secara asynchronous.
/// '.family': karena ia memerlukan parameter eksternal (`SearchParams`)
///            untuk melakukan tugasnya.
///
/// Tipe data yang dikembalikan adalah `List<SCModel>`.
///
/// UI akan 'mengawasi' provider ini dengan memberikan parameter pencarian.
/// Contoh di UI: `ref.watch(scListProvider(SearchParams(city: 'Jakarta', sport: 'futsal')))`
///
/// Riverpod secara otomatis akan mem-cache hasilnya. Jika UI meminta data
/// dengan `SearchParams` yang sama lagi, Riverpod akan mengembalikan data
/// dari cache daripada membuat panggilan API baru.
final scListProvider =
    FutureProvider.autoDispose.family<List<SCModel>, SearchParams>((ref, params) {
  
  // Mengambil dependency (HomeRepository) dari provider lain.
  final homeRepository = ref.watch(homeRepositoryProvider);

  // Memanggil method `searchSportCenters` dari repository dengan parameter
  // yang diterima oleh family provider.
  // Method ini mengembalikan Future<Either<Failure, List<SCModel>>>,
  // jadi kita perlu menanganinya.
  final result = homeRepository.searchSportCenters(
    city: params.city,
    // Note: Parameter 'sport' mungkin belum digunakan di repository,
    // tapi kita sudah siapkan di sini untuk masa depan.
  );

  // Menggunakan `then` untuk memproses hasil dari Future<Either>.
  return result.then(
    (either) => either.fold(
      // Jika hasilnya adalah Left (Failure), kita 'melempar' error
      // agar FutureProvider masuk ke state error.
      (failure) => throw failure,
      // Jika hasilnya adalah Right (Success), kita kembalikan datanya.
      (scList) => scList,
    ),
  );
});