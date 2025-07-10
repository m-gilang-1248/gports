//baru dibuat saat lanjut di modalxiaomi
// lib/features/4_booking/controller/payment_controller.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gsports/config/router/route_names.dart';
import 'package:gsports/core/models/booking_model.dart';
import 'package:gsports/core/utils/snackbar.dart';
import 'package:gsports/features/4_booking/repository/booking_repository.dart';
import 'package:gsports/features/4_booking/view/booking_history_screen.dart';
import 'package:gsports/features/6_sc_admin/controller/sc_admin_bookings_controller.dart';

/// Provider untuk PaymentController.
/// Mengelola state `isLoading` untuk aksi upload bukti bayar.
final paymentControllerProvider =
    StateNotifierProvider.autoDispose<PaymentController, bool>((ref) {
  final bookingRepository = ref.watch(bookingRepositoryProvider);
  return PaymentController(
    bookingRepository: bookingRepository,
    ref: ref,
  );
});

/// Controller yang menangani logika bisnis terkait pembayaran,
/// seperti mengunggah bukti transfer.
class PaymentController extends StateNotifier<bool> {
  final BookingRepository _bookingRepository;
  final Ref _ref;

  PaymentController({
    required BookingRepository bookingRepository,
    required Ref ref,
  })  : _bookingRepository = bookingRepository,
        _ref = ref,
        super(false); // state adalah isLoading

  /// Mengelola seluruh alur upload bukti pembayaran.
  /// 1. Unggah file gambar ke storage.
  /// 2. Jika berhasil, simpan URL gambar ke dokumen booking yang relevan.
  Future<void> uploadPaymentProof({
    required BuildContext context,
    required File image,
    required BookingModel booking,
  }) async {
    state = true;
    try {
      // Langkah 1: Panggil repository untuk mengunggah file.
      final uploadResult = await _bookingRepository.uploadPaymentProof(
        image: image,
        booking: booking,
      );

      // Jika upload gagal, hentikan proses dan tampilkan error.
      final imageUrl = uploadResult.fold(
        (failure) {
          showSnackBar(context, failure.message, isError: true);
          return null;
        },
        (url) => url,
      );

      if (imageUrl == null) {
        state = false;
        return; // Hentikan jika upload gagal.
      }

      // Langkah 2: Jika upload berhasil, panggil repository untuk menyimpan URL ke dokumen.
      final linkResult = await _bookingRepository.linkPaymentProofToBooking(
        bookingId: booking.id,
        proofUrl: imageUrl,
      );

      state = false; // Matikan loading setelah semua proses selesai.

      linkResult.fold(
        (failure) => showSnackBar(context, failure.message, isError: true),
        (r) {
          // Langkah 3: Jika semua berhasil, beri feedback dan refresh UI.
          showSnackBar(context, 'Bukti pembayaran berhasil diunggah!');

          // Invalidate provider riwayat agar status booking ter-update.
          _ref.invalidate(bookingHistoryProvider);
          // Invalidate juga daftar booking admin, untuk jaga-jaga.
          _ref.invalidate(adminBookingsProvider(booking.centerId));

          // Arahkan pengguna ke halaman riwayat untuk melihat status baru.
          context.goNamed(RouteNames.history);
        },
      );
    } catch (e) {
      state = false;
      showSnackBar(context, 'Terjadi kesalahan tidak terduga: $e', isError: true);
    }
  }
}