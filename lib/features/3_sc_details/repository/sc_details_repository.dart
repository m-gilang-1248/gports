// lib/features/3_sc_details/repository/sc_details_repository.dart

import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import 'package:gsports/core/constants/appwrite_constants.dart';
import 'package:gsports/core/failure.dart';
import 'package:gsports/core/models/field_model.dart';
import 'package:gsports/core/models/sc_model.dart';
import 'package:gsports/core/providers/appwrite_providers.dart';
import 'package:gsports/core/type_defs.dart';
import 'package:gsports/core/utils/logger.dart';

// --- 1. Provider untuk SCDetailsRepository ---
final scDetailsRepositoryProvider = Provider<SCDetailsRepository>((ref) {
  final databases = ref.watch(appwriteDatabaseProvider);
  return SCDetailsRepository(databases: databases);
});


// --- 2. Kelas SCDetailsRepository ---
class SCDetailsRepository {
  final Databases _databases;

  SCDetailsRepository({required Databases databases}) : _databases = databases;

  /// Method untuk mengambil detail satu Sports Center berdasarkan ID.
  ///
  /// [scId]: ID unik dari dokumen Sports Center yang ingin diambil.
  FutureEither<SCModel> getSCDetails({required String scId}) async {
    try {
      // Memanggil Appwrite untuk mengambil satu dokumen spesifik.
      final document = await _databases.getDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.sportCentersCollection,
        documentId: scId,
      );

      // Mengonversi data dokumen menjadi objek SCModel.
      final scModel = SCModel.fromJson(document.data);
      
      logger.i("Successfully fetched details for SC: ${scModel.name}");
      return right(scModel);

    } on AppwriteException catch (e, st) {
      logger.e("AppwriteException during getSCDetails: ${e.message}", stackTrace: st);
      return left(Failure(message: e.message ?? 'Failed to get SC details.', stackTrace: st));
    } catch (e, st) {
      logger.e("Unexpected error during getSCDetails: $e", stackTrace: st);
      return left(Failure(message: e.toString(), stackTrace: st));
    }
  }

  /// Method untuk mengambil daftar semua lapangan yang dimiliki oleh
  /// sebuah Sports Center.
  ///
  /// [scId]: ID dari Sports Center yang lapangannya ingin kita ambil.
  ///         Ini digunakan untuk memfilter di collection 'fields'.
  FutureEither<List<FieldModel>> getFieldsForSC({required String scId}) async {
    try {
      // Membangun query untuk memfilter lapangan berdasarkan 'center_id'.
      // Kita juga hanya mengambil lapangan yang statusnya aktif.
      final queries = [
        Query.equal('center_id', scId),
        Query.equal('is_active', true),
      ];

      // Memanggil Appwrite untuk mengambil daftar dokumen dari collection 'fields'.
      final documents = await _databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.fieldsCollection,
        queries: queries,
      );

      // Mengonversi List<Document> menjadi List<FieldModel>.
      final fieldList = documents.documents
          .map((doc) => FieldModel.fromJson(doc.data))
          .toList();

      logger.i("Found ${fieldList.length} active fields for SC ID: $scId.");
      return right(fieldList);
      
    } on AppwriteException catch (e, st) {
      logger.e("AppwriteException during getFieldsForSC: ${e.message}", stackTrace: st);
      return left(Failure(message: e.message ?? 'Failed to get fields.', stackTrace: st));
    } catch (e, st) {
      logger.e("Unexpected error during getFieldsForSC: $e", stackTrace: st);
      return left(Failure(message: e.toString(), stackTrace: st));
    }
  }
}