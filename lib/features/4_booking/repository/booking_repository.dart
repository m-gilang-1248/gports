// lib/features/4_booking/repository/booking_repository.dart

import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import 'package:gsports/core/constants/appwrite_constants.dart';
import 'package:gsports/core/failure.dart';
import 'package:gsports/core/models/blocked_slot_model.dart';
import 'package:gsports/core/models/booking_model.dart';
import 'package:gsports/core/providers/appwrite_providers.dart';
import 'package:gsports/core/type_defs.dart';
import 'package:gsports/core/utils/logger.dart';

// --- Provider dan kelas ScheduleData tetap sama ---
final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository(
    databases: ref.watch(appwriteDatabaseProvider),
    realtime: ref.watch(appwriteRealtimeProvider),
    storage: ref.watch(appwriteStorageProvider),
  );
});

class ScheduleData {
  final List<BookingModel> bookings;
  final List<BlockedSlotModel> blockedSlots;
  ScheduleData({required this.bookings, required this.blockedSlots});
}

class BookingRepository {
  final Databases _databases;
  final Realtime _realtime;
  final Storage _storage;

  BookingRepository({
    required Databases databases,
    required Realtime realtime,
    required Storage storage,
  })  : _databases = databases,
        _realtime = realtime,
        _storage = storage;

  // ... (method lain tidak berubah)
  FutureEither<ScheduleData> getScheduleForDate({
    required String fieldId,
    required DateTime date,
  }) async {
    try {
      final dateString =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final results = await Future.wait([
        _databases.listDocuments(
            databaseId: AppwriteConstants.databaseId,
            collectionId: AppwriteConstants.bookingsCollection,
            queries: [
              Query.equal('field_id', fieldId),
              Query.equal('booking_date', dateString)
            ]),
        _databases.listDocuments(
            databaseId: AppwriteConstants.databaseId,
            collectionId: AppwriteConstants.blockedSlotsCollection,
            queries: [
              Query.equal('field_id', fieldId),
              Query.equal('block_date', dateString)
            ]),
      ]);
      final bookings = results[0]
          .documents
          .map((doc) => BookingModel.fromJson(doc.data))
          .toList();
      final blockedSlots = results[1]
          .documents
          .map((doc) => BlockedSlotModel.fromJson(doc.data))
          .toList();
      logger.i(
          "Fetched schedule for field $fieldId on $dateString. Bookings: ${bookings.length}, Blocked: ${blockedSlots.length}");
      return right(ScheduleData(bookings: bookings, blockedSlots: blockedSlots));
    } on AppwriteException catch (e, st) {
      logger.e("AppwriteException during getScheduleForDate: ${e.message}",
          stackTrace: st);
      return left(Failure(
          message: e.message ?? 'Failed to get schedule.', stackTrace: st));
    } catch (e, st) {
      logger.e("Unexpected error during getScheduleForDate: $e",
          stackTrace: st);
      return left(Failure(message: e.toString(), stackTrace: st));
    }
  }


  // --- METHOD createBooking DENGAN LOGGER TAMBAHAN ---
  FutureEither<BookingModel> createBooking({required BookingModel booking}) async {
    // --- [DEBUGGING LOG 1] Tampilkan data awal ---
    logger.d("▶️ Starting createBooking process...");
    logger.d("   Booking for Player ID: ${booking.playerUserId}");
    logger.d("   Target Center ID: ${booking.centerId}");
    logger.d("   Data to be sent: ${booking.toJson()}");

    try {
      // Langkah 1: Ambil ID tim admin dari dokumen Sports Center terkait.
      logger.d("   Fetching SC document to get admin team ID...");
      final scDocument = await _databases.getDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.sportCentersCollection,
        documentId: booking.centerId,
      );

      final adminTeamId = scDocument.data['sc_admin_team_id'] as String?;
      
      // --- [DEBUGGING LOG 2] Tampilkan hasil pengambilan teamId ---
      logger.d("   Found Admin Team ID: $adminTeamId");

      if (adminTeamId == null || adminTeamId.isEmpty) {
        logger.e("   FATAL: adminTeamId is null or empty. Aborting.");
        throw Exception(
            'Konfigurasi Sports Center tidak lengkap (tidak ada ID Tim Admin).');
      }

      // Langkah 2: Bangun daftar izin (permissions) dinamis.
      final List<String> permissions = [
        Permission.read(Role.user(booking.playerUserId)),
        Permission.read(Role.team(adminTeamId)),
        Permission.update(Role.team(adminTeamId)),
        Permission.delete(Role.team(adminTeamId)),
      ];
      
      // --- [DEBUGGING LOG 3] Tampilkan daftar izin yang akan dikirim ---
      logger.d("   Constructed Permissions: $permissions");

      // Langkah 3: Panggil createDocument dengan menyertakan izin yang baru dibuat.
      logger.d("   Calling createDocument on 'bookings' collection...");
      final document = await _databases.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.bookingsCollection,
        documentId: ID.unique(),
        data: booking.toJson(),
        permissions: permissions,
      );
      
      logger.i("✅ createBooking process successful! Document ID: ${document.$id}");
      return right(BookingModel.fromJson(document.data));

    } on AppwriteException catch (e, st) {
      // --- [DEBUGGING LOG 4] Tampilkan error Appwrite ---
      logger.e("   AppwriteException during createBooking: ${e.message}",
          stackTrace: st);
      logger.e("   Appwrite error details: ${e.response}"); // Ini sangat penting
      return left(Failure(
          message: e.message ?? 'Gagal membuat pesanan.', stackTrace: st));
    } catch (e, st) {
      // --- [DEBUGGING LOG 5] Tampilkan error tak terduga ---
      logger.e("   Unexpected error during createBooking: $e", stackTrace: st);
      return left(Failure(message: e.toString(), stackTrace: st));
    }
  }

  // ... (sisa method tidak berubah)
  FutureEither<List<BookingModel>> getBookingHistory(
      {required String userId}) async {
    try {
      final documents = await _databases.listDocuments(
          databaseId: AppwriteConstants.databaseId,
          collectionId: AppwriteConstants.bookingsCollection,
          queries: [
            Query.equal('player_user_id', userId),
            Query.orderDesc('\$createdAt')
          ]);
      final bookings = documents.documents
          .map((doc) => BookingModel.fromJson(doc.data))
          .toList();
      return right(bookings);
    } on AppwriteException catch (e, st) {
      logger.e("AppwriteException during getBookingHistory: ${e.message}",
          stackTrace: st);
      return left(
          Failure(message: e.message ?? 'Failed to get history.', stackTrace: st));
    } catch (e, st) {
      logger.e("Unexpected error during getBookingHistory: $e", stackTrace: st);
      return left(Failure(message: e.toString(), stackTrace: st));
    }
  }

  FutureEither<String> uploadPaymentProof({
    required File image,
    required BookingModel booking,
  }) async {
    try {
      final scDocument = await _databases.getDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.sportCentersCollection,
        documentId: booking.centerId,
      );
      final adminTeamId = scDocument.data['sc_admin_team_id'] as String?;
      if (adminTeamId == null || adminTeamId.isEmpty) {
        throw Exception('Konfigurasi Sports Center tidak lengkap.');
      }
      final fileId =
          '${AppwriteConstants.paymentProofsFolderPath}/${booking.id}';
      try {
        await _storage.deleteFile(
          bucketId: AppwriteConstants.storageBucketId,
          fileId: fileId,
        );
      } catch (e) {
        logger.w("No old payment proof to delete for booking ${booking.id}.");
      }
      final uploadedFile = await _storage.createFile(
        bucketId: AppwriteConstants.storageBucketId,
        fileId: fileId,
        file: InputFile.fromPath(path: image.path),
        permissions: [
          Permission.read(Role.user(booking.playerUserId)),
          Permission.read(Role.team(adminTeamId)),
          Permission.update(Role.team(adminTeamId)),
          Permission.delete(Role.team(adminTeamId)),
        ],
      );
      final imageUrl = _storage.getFileView(
        bucketId: AppwriteConstants.storageBucketId,
        fileId: uploadedFile.$id,
      );
      return right(imageUrl.toString());
    } on AppwriteException catch (e, st) {
      return left(Failure(
          message: e.message ?? 'Gagal mengunggah bukti bayar.',
          stackTrace: st));
    } catch (e, st) {
      return left(Failure(message: e.toString(), stackTrace: st));
    }
  }

  FutureEitherVoid linkPaymentProofToBooking({
    required String bookingId,
    required String proofUrl,
  }) async {
    try {
      await _databases.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.bookingsCollection,
        documentId: bookingId,
        data: {
          'payment_proof_url': proofUrl,
          'booking_status':
              BookingStatus.pendingPayment.name,
        },
      );
      return right(null);
    } on AppwriteException catch (e, st) {
      return left(Failure(
          message: e.message ?? 'Gagal menyimpan URL bukti bayar.',
          stackTrace: st));
    } catch (e, st) {
      return left(Failure(message: e.toString(), stackTrace: st));
    }
  }

  Stream<RealtimeMessage> getBookingUpdates() {
    return _realtime.subscribe([AppwriteConstants.bookingsChannel()]).stream;
  }

  Stream<RealtimeMessage> getBlockedSlotUpdates() {
    return _realtime.subscribe([AppwriteConstants.blockedSlotsChannel()]).stream;
  }
}