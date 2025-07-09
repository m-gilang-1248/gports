// lib/features/1_home/repository/home_repository.dart

import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import 'package:gsports/core/constants/appwrite_constants.dart';
import 'package:gsports/core/failure.dart';
import 'package:gsports/core/models/sc_model.dart';
import 'package:gsports/core/providers/appwrite_providers.dart';
import 'package:gsports/core/type_defs.dart';
import 'package:gsports/core/utils/logger.dart';

// --- 1. Provider untuk HomeRepository ---
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  // Mengambil dependency (layanan Databases dari Appwrite).
  final databases = ref.watch(appwriteDatabaseProvider);
  return HomeRepository(databases: databases);
});


// --- 2. Kelas HomeRepository ---
class HomeRepository {
  final Databases _databases;

  HomeRepository({required Databases databases}) : _databases = databases;

  /// Method untuk mencari Sports Center berdasarkan kota.
  ///
  /// [city]: Nama kota yang akan dicari.
  ///
  /// Nanti, kita bisa menambahkan parameter lain seperti `sportType` jika
  /// kita sudah mengimplementasikan denormalisasi di backend.
  /// Untuk saat ini, kita hanya akan memfilter berdasarkan kota.
  FutureEither<List<SCModel>> searchSportCenters({
    required String city,
  }) async {
    try {
      // Membangun query untuk Appwrite.
      // Kita hanya akan mengambil SC yang statusnya 'active'.
      final queries = [
        Query.equal('sc_city', city),
        Query.equal('sc_status', 'active'),
      ];

      // Memanggil Appwrite untuk mengambil daftar dokumen dari collection 'sport_centers'.
      final documents = await _databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.sportCentersCollection,
        queries: queries,
      );

      // Mengonversi daftar dokumen mentah (List<Document>) menjadi List<SCModel>.
      // `map` akan mengiterasi setiap dokumen, `SCModel.fromJson` akan mengonversinya,
      // dan `toList()` akan mengumpulkannya kembali menjadi sebuah list.
      final scList = documents.documents
          .map((doc) => SCModel.fromJson(doc.data))
          .toList();

      logger.i("Found ${scList.length} sport centers in $city.");
      
      // Mengembalikan hasil yang sukses.
      return right(scList);

    } on AppwriteException catch (e, st) {
      logger.e("AppwriteException during searchSportCenters: ${e.message}", stackTrace: st);
      return left(Failure(message: e.message ?? 'Failed to search centers.', stackTrace: st));
    } catch (e, st) {
      logger.e("Unexpected error during searchSportCenters: $e", stackTrace: st);
      return left(Failure(message: e.toString(), stackTrace: st));
    }
  }

  // NOTE: Di masa depan, kita bisa menambahkan method lain di sini, seperti:
  // - getPopularSportCenters()
  // - getPromotions()
}