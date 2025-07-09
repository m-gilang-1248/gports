// lib/features/6_sc_admin/controller/sc_admin_action_controller.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gsports/core/models/blocked_slot_model.dart';
import 'package:gsports/core/models/booking_model.dart';
import 'package:gsports/core/utils/snackbar.dart';
import 'package:gsports/features/3_sc_details/controller/availability_controller.dart';
// --- PERBAIKAN 1: Impor BookingRepository ---
import 'package:gsports/features/4_booking/repository/booking_repository.dart';
import 'package:gsports/features/6_sc_admin/repository/sc_admin_repository.dart';

// --- PERBAIKAN 2: Perbarui cara provider dibuat ---
final scAdminActionControllerProvider =
    StateNotifierProvider.autoDispose<SCAdminActionController, bool>((ref) {
  // Controller ini sekarang butuh DUA repository.
  final scAdminRepository = ref.watch(scAdminRepositoryProvider);
  final bookingRepository = ref.watch(bookingRepositoryProvider);
  return SCAdminActionController(
    scAdminRepository: scAdminRepository,
    bookingRepository: bookingRepository, // Teruskan dependency baru
    ref: ref,
  );
});

class SCAdminActionController extends StateNotifier<bool> {
  final SCAdminRepository _scAdminRepository;
  // --- PERBAIKAN 3: Tambahkan BookingRepository sebagai dependency ---
  final BookingRepository _bookingRepository;
  final Ref _ref;

  SCAdminActionController({
    required SCAdminRepository scAdminRepository,
    required BookingRepository bookingRepository, // Tambahkan di constructor
    required Ref ref,
  })  : _scAdminRepository = scAdminRepository,
        _bookingRepository = bookingRepository, // Inisialisasi
        _ref = ref,
        super(false);

  void createManualBooking({
    required BuildContext context,
    required BookingModel booking,
  }) async {
    state = true;
    // --- PERBAIKAN 4: Panggil method dari repository yang benar ---
    final result = await _bookingRepository.createBooking(booking: booking);
    state = false;
    result.fold(
      (l) => showSnackBar(context, l.message, isError: true),
      (r) {
        _ref.invalidate(availabilityControllerProvider(AvailabilityParams(fieldId: booking.fieldId)));
        showSnackBar(context, 'Booking manual berhasil ditambahkan!');
        context.pop();
      },
    );
  }

  // Method createBlockedSlot sudah benar karena memanggil _scAdminRepository
  void createBlockedSlot({
    required BuildContext context,
    required BlockedSlotModel blockedSlot,
  }) async {
    state = true;
    final result = await _scAdminRepository.createBlockedSlot(blockedSlot: blockedSlot);
    state = false;
    result.fold(
      (l) => showSnackBar(context, l.message, isError: true),
      (r) {
        _ref.invalidate(availabilityControllerProvider(AvailabilityParams(fieldId: blockedSlot.fieldId)));
        showSnackBar(context, 'Slot berhasil diblokir!');
        context.pop();
      },
    );
  }
}