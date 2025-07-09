// lib/features/4_booking/repository/booking_repository.dart

import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gsports/core/constants/appwrite_constants.dart';
import 'package:gsports/core/failure.dart';
import 'package:gsports/core/models/booking_model.dart';
import 'package:gsports/core/models/blocked_slot_model.dart';
import 'package:gsports/core/providers/appwrite_providers.dart';
import 'package:gsports/core/type_defs.dart';
import 'package:gsports/core/utils/logger.dart';

// --- Provider dan kelas ScheduleData tetap sama ---
final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository(
    databases: ref.watch(appwriteDatabaseProvider),
    realtime: ref.watch(appwriteRealtimeProvider),
  );
});

class ScheduleData {
  final List<BookingModel> bookings;
  final List<BlockedSlotModel> blockedSlots;
  ScheduleData({required this.bookings, required this.blockedSlots});
}
// ---

class BookingRepository {
  final Databases _databases;
  final Realtime _realtime;

  BookingRepository({
    required Databases databases,
    required Realtime realtime,
  })  : _databases = databases,
        _realtime = realtime;

  FutureEither<ScheduleData> getScheduleForDate({
    required String fieldId,
    required DateTime date,
  }) async {
    // ... (implementasi method ini tidak berubah)
    try {
      final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final results = await Future.wait([
        _databases.listDocuments(databaseId: AppwriteConstants.databaseId, collectionId: AppwriteConstants.bookingsCollection, queries: [ Query.equal('field_id', fieldId), Query.equal('booking_date', dateString) ]),
        _databases.listDocuments(databaseId: AppwriteConstants.databaseId, collectionId: AppwriteConstants.blockedSlotsCollection, queries: [ Query.equal('field_id', fieldId), Query.equal('block_date', dateString) ]),
      ]);
      final bookings = results[0].documents.map((doc) => BookingModel.fromJson(doc.data)).toList();
      final blockedSlots = results[1].documents.map((doc) => BlockedSlotModel.fromJson(doc.data)).toList();
      logger.i("Fetched schedule for field $fieldId on $dateString. Bookings: ${bookings.length}, Blocked: ${blockedSlots.length}");
      return right(ScheduleData(bookings: bookings, blockedSlots: blockedSlots));
    } on AppwriteException catch (e, st) {
      logger.e("AppwriteException during getScheduleForDate: ${e.message}", stackTrace: st);
      return left(Failure(message: e.message ?? 'Failed to get schedule.', stackTrace: st));
    } catch (e, st) {
      logger.e("Unexpected error during getScheduleForDate: $e", stackTrace: st);
      return left(Failure(message: e.toString(), stackTrace: st));
    }
  }

  // --- METHOD createBooking YANG DIPERBARUI ---
  /// Method untuk membuat dokumen booking baru.
  /// Sekarang mengembalikan `BookingModel` yang baru dibuat jika berhasil.
  FutureEither<BookingModel> createBooking({required BookingModel booking}) async {
    try {
      // Panggil createDocument dan simpan hasilnya ke dalam variabel.
      final document = await _databases.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.bookingsCollection,
        documentId: ID.unique(),
        data: booking.toJson(),
      );
      
      // Jika berhasil, konversi data dari dokumen yang dikembalikan
      // menjadi BookingModel dan kirimkan sebagai hasil yang sukses (Right).
      return right(BookingModel.fromJson(document.data));

    } on AppwriteException catch (e, st) {
      logger.e("AppwriteException during createBooking: ${e.message}", stackTrace: st);
      return left(Failure(message: e.message ?? 'Failed to create booking.', stackTrace: st));
    } catch (e, st) {
      logger.e("Unexpected error during createBooking: $e", stackTrace: st);
      return left(Failure(message: e.toString(), stackTrace: st));
    }
  }

  FutureEither<List<BookingModel>> getBookingHistory({required String userId}) async {
    // ... (implementasi method ini tidak berubah)
    try {
      final documents = await _databases.listDocuments(databaseId: AppwriteConstants.databaseId, collectionId: AppwriteConstants.bookingsCollection, queries: [ Query.equal('player_user_id', userId), Query.orderDesc('\$createdAt') ]);
      final bookings = documents.documents.map((doc) => BookingModel.fromJson(doc.data)).toList();
      return right(bookings);
    } on AppwriteException catch (e, st) {
      logger.e("AppwriteException during getBookingHistory: ${e.message}", stackTrace: st);
      return left(Failure(message: e.message ?? 'Failed to get history.', stackTrace: st));
    } catch (e, st) {
      logger.e("Unexpected error during getBookingHistory: $e", stackTrace: st);
      return left(Failure(message: e.toString(), stackTrace: st));
    }
  }

  // --- Method Realtime tidak berubah ---
  Stream<RealtimeMessage> getBookingUpdates() {
    return _realtime.subscribe([AppwriteConstants.bookingsChannel()]).stream;
  }

  Stream<RealtimeMessage> getBlockedSlotUpdates() {
    return _realtime.subscribe([AppwriteConstants.blockedSlotsChannel()]).stream;
  }
}