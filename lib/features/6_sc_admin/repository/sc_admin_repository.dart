// lib/features/6_sc_admin/repository/sc_admin_repository.dart

import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import 'package:gsports/core/constants/appwrite_constants.dart';
import 'package:gsports/core/failure.dart';
import 'package:gsports/core/models/booking_model.dart';
import 'package:gsports/core/models/blocked_slot_model.dart';
import 'package:gsports/core/models/field_model.dart';
import 'package:gsports/core/models/sc_model.dart';
import 'package:gsports/core/providers/appwrite_providers.dart';
import 'package:gsports/core/type_defs.dart';
import 'package:gsports/core/utils/logger.dart';

// --- Provider tidak berubah ---
final scAdminRepositoryProvider = Provider<SCAdminRepository>((ref) {
  return SCAdminRepository(
    databases: ref.watch(appwriteDatabaseProvider),
    storage: ref.watch(appwriteStorageProvider),
  );
});

// --- Kelas Repository dengan penambahan method baru ---
class SCAdminRepository {
  final Databases _databases;
  final Storage _storage;

  SCAdminRepository({
    required Databases databases,
    required Storage storage,
  })  : _databases = databases,
        _storage = storage;

  // --- PROFIL SPORTS CENTER ---

  // ... (method updateSCProfile tidak berubah)
  FutureEitherVoid updateSCProfile({required SCModel sc}) async {
    try {
      await _databases.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.sportCentersCollection,
        documentId: sc.id,
        data: sc.toJson(),
      );
      return right(null);
    } on AppwriteException catch (e, st) {
      logger.e("AppwriteException during updateSCProfile: ${e.message}",
          stackTrace: st);
      return left(Failure(
          message: e.message ?? 'Failed to update profile.', stackTrace: st));
    } catch (e, st) {
      logger.e("Unexpected error during updateSCProfile: $e", stackTrace: st);
      return left(Failure(message: e.toString(), stackTrace: st));
    }
  }

  // --- MANAJEMEN FOTO ---
  // Kita gabungkan semua metode terkait foto di sini.

  /// [BARU] Mengunggah satu file gambar untuk sebuah SPORTS CENTER dan mengembalikan URL publiknya.
  FutureEither<String> uploadSCImage({
    required File image,
    required String teamId,
  }) async {
    try {
      // 1. Gunakan folder virtual 'sc_images'.
      final fileId =
          '${AppwriteConstants.scImagesFolderPath}/${ID.unique()}';

      // 2. Unggah file dengan izin yang sama seperti foto lapangan.
      final uploadedFile = await _storage.createFile(
        bucketId: AppwriteConstants.storageBucketId,
        fileId: fileId,
        file: InputFile.fromPath(path: image.path, filename: fileId),
        permissions: [
          Permission.read(Role.any()), 
          Permission.update(Role.team(teamId)),
          Permission.delete(Role.team(teamId)),
        ],
      );

      // 3. Buat URL publik.
      final imageUrl = _storage.getFileView(
        bucketId: AppwriteConstants.storageBucketId,
        fileId: uploadedFile.$id,
      );
      
      logger.i("Successfully uploaded SC image: ${imageUrl.toString()}");
      return right(imageUrl.toString());

    } on AppwriteException catch (e, st) {
      return left(Failure(
          message: e.message ?? 'Gagal mengunggah foto SC.', stackTrace: st));
    } catch (e, st) {
      return left(Failure(message: e.toString(), stackTrace: st));
    }
  }


  /// Mengunggah satu file gambar untuk sebuah LAPANGAN dan mengembalikan URL publiknya.
  FutureEither<String> uploadFieldImage({
    required File image,
    required String teamId,
  }) async {
    try {
      final fileId =
          '${AppwriteConstants.fieldImagesFolderPath}/${ID.unique()}';

      final uploadedFile = await _storage.createFile(
        bucketId: AppwriteConstants.storageBucketId,
        fileId: fileId,
        file: InputFile.fromPath(path: image.path, filename: fileId),
        permissions: [
          Permission.read(Role.any()),
          Permission.update(Role.team(teamId)),
          Permission.delete(Role.team(teamId)),
        ],
      );

      final imageUrl = _storage.getFileView(
        bucketId: AppwriteConstants.storageBucketId,
        fileId: uploadedFile.$id,
      );
      
      logger.i("Successfully uploaded field image: ${imageUrl.toString()}");
      return right(imageUrl.toString());

    } on AppwriteException catch (e, st) {
      return left(Failure(
          message: e.message ?? 'Gagal mengunggah foto.', stackTrace: st));
    } catch (e, st) {
      return left(Failure(message: e.toString(), stackTrace: st));
    }
  }

  /// Menghapus satu file gambar dari Appwrite Storage berdasarkan ID-nya.
  FutureEitherVoid deleteFile({required String fileId}) async {
    try {
      await _storage.deleteFile(
        bucketId: AppwriteConstants.storageBucketId,
        fileId: fileId,
      );
      return right(null);
    } on AppwriteException catch (e, st) {
      return left(Failure(
          message: e.message ?? 'Gagal menghapus foto.', stackTrace: st));
    }
  }


  // --- MANAJEMEN LAPANGAN (FIELDS) ---

  // ... (semua method di sini tidak berubah)
  FutureEither<List<FieldModel>> getFieldsForAdmin({required String scId}) async {
    try {
      final documents = await _databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.fieldsCollection,
        queries: [Query.equal('center_id', scId)],
      );
      final fields =
          documents.documents.map((doc) => FieldModel.fromJson(doc.data)).toList();
      return right(fields);
    } on AppwriteException catch (e, st) {
      return left(
          Failure(message: e.message ?? 'Failed to get fields.', stackTrace: st));
    }
  }

  FutureEitherVoid createField({required FieldModel field}) async {
    try {
      await _databases.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.fieldsCollection,
        documentId: ID.unique(),
        data: field.toJson(),
      );
      return right(null);
    } on AppwriteException catch (e, st) {
      return left(Failure(
          message: e.message ?? 'Failed to create field.', stackTrace: st));
    }
  }

  FutureEitherVoid updateField({required FieldModel field}) async {
    try {
      await _databases.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.fieldsCollection,
        documentId: field.id,
        data: field.toJson(),
      );
      return right(null);
    } on AppwriteException catch (e, st) {
      return left(Failure(
          message: e.message ?? 'Failed to update field.', stackTrace: st));
    }
  }

  FutureEitherVoid deleteField({required String fieldId}) async {
    try {
      // NOTE: Ini hanya menghapus dokumen field.
      // Foto-foto yang terkait di Storage tidak akan terhapus secara otomatis.
      // Untuk MVP, ini sudah cukup. Di masa depan, Anda perlu mengambil
      // field dulu, loop melalui `photosUrls`, ekstrak fileId, dan hapus satu per satu.
      await _databases.deleteDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.fieldsCollection,
        documentId: fieldId,
      );
      return right(null);
    } on AppwriteException catch (e, st) {
      return left(Failure(
          message: e.message ?? 'Gagal menghapus lapangan.', stackTrace: st));
    } catch (e, st) {
      return left(Failure(message: e.toString(), stackTrace: st));
    }
  }
  
  // --- MANAJEMEN BOOKING ---

  // ... (semua method di bawah ini tidak berubah)
  FutureEither<List<BookingModel>> getAllBookingsForSC(
      {required String scId}) async {
    try {
      final documents = await _databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.bookingsCollection,
        queries: [
          Query.equal('center_id', scId),
          Query.orderDesc('\$createdAt'),
        ],
      );
      final bookings = documents.documents
          .map((doc) => BookingModel.fromJson(doc.data))
          .toList();
      return right(bookings);
    } on AppwriteException catch (e, st) {
      return left(Failure(
          message: e.message ?? 'Failed to get bookings.', stackTrace: st));
    }
  }
  
  FutureEitherVoid updateBookingStatus({
    required String bookingId,
    required BookingStatus newStatus,
  }) async {
    try {
      await _databases.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.bookingsCollection,
        documentId: bookingId,
        data: {'booking_status': newStatus.name},
      );
      return right(null);
    } on AppwriteException catch (e, st) {
      return left(Failure(
          message: e.message ?? 'Failed to update status.', stackTrace: st));
    }
  }

  // --- MANAJEMEN JADWAL BLOKIR ---
  
  // ... (semua method di bawah ini tidak berubah)
  FutureEitherVoid createBlockedSlot(
      {required BlockedSlotModel blockedSlot}) async {
    try {
      await _databases.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.blockedSlotsCollection,
        documentId: ID.unique(),
        data: blockedSlot.toJson(),
      );
      return right(null);
    } on AppwriteException catch (e, st) {
      return left(Failure(
          message: e.message ?? 'Failed to block slot.', stackTrace: st));
    }
  }

  FutureEitherVoid deleteBlockedSlot({required String blockedSlotId}) async {
    try {
      await _databases.deleteDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.blockedSlotsCollection,
        documentId: blockedSlotId,
      );
      return right(null);
    } on AppwriteException catch (e, st) {
      return left(Failure(
          message: e.message ?? 'Failed to unblock slot.', stackTrace: st));
    }
  }
}