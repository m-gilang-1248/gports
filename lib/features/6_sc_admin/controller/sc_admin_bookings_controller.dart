// lib/features/6_sc_admin/controller/sc_admin_bookings_controller.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gsports/core/models/booking_model.dart';
import 'package:gsports/core/utils/snackbar.dart';
import 'package:gsports/features/6_sc_admin/repository/sc_admin_repository.dart';

// --- Provider untuk daftar booking ---
// FutureProvider.family untuk mengambil daftar booking berdasarkan ID Sports Center.
final adminBookingsProvider =
    FutureProvider.autoDispose.family<List<BookingModel>, String>((ref, scId) {
  final repo = ref.watch(scAdminRepositoryProvider);
  // Mengambil data dan menangani Either di dalam provider
  return repo.getAllBookingsForSC(scId: scId).then((result) => result.fold(
        (l) => throw l, // Lempar failure agar .when bisa menangkap error
        (r) => r,
      ));
});

// --- Provider untuk controller aksi (Update Status) ---
final scAdminBookingsControllerProvider =
    StateNotifierProvider.autoDispose<SCAdminBookingsController, bool>((ref) {
  return SCAdminBookingsController(
    scAdminRepository: ref.watch(scAdminRepositoryProvider),
    ref: ref,
  );
});

// --- Kelas Controller ---
class SCAdminBookingsController extends StateNotifier<bool> {
  final SCAdminRepository _scAdminRepository;
  final Ref _ref;

  SCAdminBookingsController({
    required SCAdminRepository scAdminRepository,
    required Ref ref,
  })  : _scAdminRepository = scAdminRepository,
        _ref = ref,
        super(false); // state adalah isLoading

  /// Mengupdate status booking dan menangani feedback UI.
  void updateBookingStatus({
    required BuildContext context,
    required String bookingId,
    required String scId, // Diperlukan untuk invalidate provider yang benar
    required BookingStatus newStatus,
  }) async {
    state = true;
    final result = await _scAdminRepository.updateBookingStatus(
      bookingId: bookingId,
      newStatus: newStatus,
    );
    state = false;

    result.fold(
      (l) => showSnackBar(context, l.message, isError: true),
      (r) {
        showSnackBar(context, 'Status booking berhasil diperbarui!');
        // Invalidate provider daftar booking agar list-nya refresh
        _ref.invalidate(adminBookingsProvider(scId));
        // Kembali ke halaman daftar setelah berhasil
        context.pop();
      },
    );
  }
}