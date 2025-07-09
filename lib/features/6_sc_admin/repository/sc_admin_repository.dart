// lib/features/6_sc_admin/repository/sc_admin_repository.dart

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

// --- 1. Provider untuk SCAdminRepository ---
final scAdminRepositoryProvider = Provider<SCAdminRepository>((ref) {
  return SCAdminRepository(databases: ref.watch(appwriteDatabaseProvider));
});


// --- 2. Kelas SCAdminRepository ---
class SCAdminRepository {
  final Databases _databases;

  SCAdminRepository({required Databases databases}) : _databases = databases;

  // --- PROFIL SPORTS CENTER ---

  /// Mengupdate data profil Sports Center.
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
      logger.e("AppwriteException during updateSCProfile: ${e.message}", stackTrace: st);
      return left(Failure(message: e.message ?? 'Failed to update profile.', stackTrace: st));
    } catch (e, st) {
      logger.e("Unexpected error during updateSCProfile: $e", stackTrace: st);
      return left(Failure(message: e.toString(), stackTrace: st));
    }
  }

  // --- MANAJEMEN LAPANGAN (FIELDS) ---

  /// Mengambil semua lapangan (aktif & non-aktif) untuk satu SC.
  FutureEither<List<FieldModel>> getFieldsForAdmin({required String scId}) async {
    try {
      final documents = await _databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.fieldsCollection,
        queries: [Query.equal('center_id', scId)],
      );
      final fields = documents.documents.map((doc) => FieldModel.fromJson(doc.data)).toList();
      return right(fields);
    } on AppwriteException catch (e, st) {
      return left(Failure(message: e.message ?? 'Failed to get fields.', stackTrace: st));
    }
  }

  /// Membuat lapangan baru.
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
      return left(Failure(message: e.message ?? 'Failed to create field.', stackTrace: st));
    }
  }

  /// Mengupdate detail lapangan.
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
      return left(Failure(message: e.message ?? 'Failed to update field.', stackTrace: st));
    }
  }
  
  // --- MANAJEMEN BOOKING ---

  /// Mengambil semua booking untuk satu SC.
  FutureEither<List<BookingModel>> getAllBookingsForSC({required String scId}) async {
    try {
      final documents = await _databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.bookingsCollection,
        queries: [
          Query.equal('center_id', scId),
          Query.orderDesc('\$createdAt'),
        ],
      );
      final bookings = documents.documents.map((doc) => BookingModel.fromJson(doc.data)).toList();
      return right(bookings);
    } on AppwriteException catch (e, st) {
      return left(Failure(message: e.message ?? 'Failed to get bookings.', stackTrace: st));
    }
  }
  
  /// Mengupdate status sebuah booking.
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
      return left(Failure(message: e.message ?? 'Failed to update status.', stackTrace: st));
    }
  }

  // --- MANAJEMEN JADWAL BLOKIR ---
  
  /// Membuat slot waktu yang diblokir.
  FutureEitherVoid createBlockedSlot({required BlockedSlotModel blockedSlot}) async {
    try {
      await _databases.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.blockedSlotsCollection,
        documentId: ID.unique(),
        data: blockedSlot.toJson(),
      );
      return right(null);
    } on AppwriteException catch (e, st) {
      return left(Failure(message: e.message ?? 'Failed to block slot.', stackTrace: st));
    }
  }

  /// Menghapus slot waktu yang diblokir.
  FutureEitherVoid deleteBlockedSlot({required String blockedSlotId}) async {
    try {
      await _databases.deleteDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.blockedSlotsCollection,
        documentId: blockedSlotId,
      );
      return right(null);
    } on AppwriteException catch (e, st) {
      return left(Failure(message: e.message ?? 'Failed to unblock slot.', stackTrace: st));
    }
  }
}