// lib/features/3_sc_details/controller/availability_controller.dart

// --- SEMUA IMPORT HARUS DI ATAS ---
import 'dart:async';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart'; // Import untuk anotasi @riverpod
import 'package:gsports/core/utils/logger.dart';
import 'package:gsports/features/4_booking/repository/booking_repository.dart';

// --- PART DIRECTIVE SETELAH SEMUA IMPORT ---
part 'availability_controller.g.dart';

// --- 1. Kelas Parameter untuk Controller ---
class AvailabilityParams {
  final String fieldId;
  
  AvailabilityParams({required this.fieldId});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AvailabilityParams && other.fieldId == fieldId;
  }

  @override
  int get hashCode => fieldId.hashCode;
}

// --- 2. Controller dengan AsyncNotifier ---
/// Anotasi `@riverpod` akan men-generate provider untuk kita secara otomatis.
/// Providernya akan bernama `availabilityControllerProvider`.
/// `keepAlive: true` bisa ditambahkan jika kita ingin state-nya tidak di-dispose
/// saat tidak digunakan, tapi untuk jadwal lebih baik di-dispose.
@riverpod
class AvailabilityController extends _$AvailabilityController {
  
  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  /// Method `build` sekarang menjadi inti dari AsyncNotifier.
  /// Ia akan dipanggil untuk menghasilkan state awal.
  @override
  Future<ScheduleData> build(AvailabilityParams arg) async {
    _setupRealtimeListener(arg.fieldId);

    logger.i('Building AvailabilityController for field: ${arg.fieldId} on $_selectedDate');
    final bookingRepository = ref.watch(bookingRepositoryProvider);
    final result = await bookingRepository.getScheduleForDate(
      fieldId: arg.fieldId,
      date: _selectedDate,
    );
    
    // Menggunakan pattern matching pada Either
    return switch (result) {
      Right(value: final scheduleData) => scheduleData,
      Left(value: final failure) => throw failure,
    };
  }

  void _setupRealtimeListener(String fieldId) {
    final bookingRepository = ref.read(bookingRepositoryProvider);
    
    final bookingSub = bookingRepository.getBookingUpdates().listen((message) {
      if (message.events.any((event) => event.contains('documents.*.create') ||
          event.contains('documents.*.update') ||
          event.contains('documents.*.delete'))) {
        if (message.payload['field_id'] == fieldId) {
          logger.i('Realtime update received for bookings. Invalidating schedule...');
          // `ref.invalidateSelf()` adalah cara untuk memicu `build` lagi.
          ref.invalidateSelf();
        }
      }
    });
    
    final blockedSlotSub = bookingRepository.getBlockedSlotUpdates().listen((message) {
       if (message.events.any((event) => event.contains('documents.*.create') ||
          event.contains('documents.*.update') ||
          event.contains('documents.*.delete'))) {
        if (message.payload['field_id'] == fieldId) {
          logger.i('Realtime update received for blocked slots. Invalidating schedule...');
          ref.invalidateSelf();
        }
      }
    });

    ref.onDispose(() {
      logger.d('Disposing AvailabilityController subscriptions.');
      bookingSub.cancel();
      blockedSlotSub.cancel();
    });
  }

  /// Method untuk memilih tanggal baru.
  Future<void> changeDate(DateTime newDate) async {
    // Update state tanggal internal
    _selectedDate = newDate;
    
    // Set state Notifier menjadi loading sementara data baru diambil.
    state = const AsyncValue.loading();
    
    // Panggil `ref.invalidateSelf()` untuk memicu `build` lagi dengan tanggal baru.
    // `state = await AsyncValue.guard(...)` adalah cara aman untuk melakukan ini.
    state = await AsyncValue.guard(() => build(arg));
  }
}