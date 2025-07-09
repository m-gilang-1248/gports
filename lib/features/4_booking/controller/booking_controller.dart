// lib/features/4_booking/controller/booking_controller.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gsports/config/router/route_names.dart';
import 'package:gsports/core/models/booking_model.dart';
import 'package:gsports/features/0_auth/controller/auth_controller.dart';
import 'package:gsports/core/utils/logger.dart';
import 'package:gsports/core/utils/snackbar.dart';
import 'package:gsports/features/4_booking/repository/booking_repository.dart';

// Provider untuk BookingController tetap sama
final bookingControllerProvider =
    StateNotifierProvider.autoDispose<BookingController, bool>((ref) {
  final bookingRepository = ref.watch(bookingRepositoryProvider);
  return BookingController(
    bookingRepository: bookingRepository,
    ref: ref,
  );
});

class BookingController extends StateNotifier<bool> {
  final BookingRepository _bookingRepository;
  final Ref _ref;

  BookingController({
    required BookingRepository bookingRepository,
    required Ref ref,
  })  : _bookingRepository = bookingRepository,
        _ref = ref,
        super(false);

  void createBooking({
    required BuildContext context,
    required BookingModel booking,
  }) async {
    final user = _ref.read(userProvider).value;

    if (user == null) {
      showSnackBar(context, 'Anda harus login untuk membuat pesanan.', isError: true);
      return;
    }

    try {
      state = true;
      logger.i('Attempting to create booking for user: ${user.uid}');

      final finalBooking = booking.copyWith(playerUserId: user.uid);
      
      // Tipe kembalian dari createBooking sekarang adalah FutureEither<BookingModel>
      final result = await _bookingRepository.createBooking(booking: finalBooking);

      result.fold(
        (failure) {
          logger.e('Booking creation failed: ${failure.message}');
          showSnackBar(context, failure.message, isError: true);
        },
        // --- PERUBAHAN UTAMA ADA DI SINI ---
        // Variabel 'newBookingModel' sekarang berisi data booking yang baru dibuat.
        (newBookingModel) {
          logger.i('Booking created successfully! ID: ${newBookingModel.id}');
          showSnackBar(context, 'Pesanan berhasil dibuat!');

          // Lakukan navigasi ke halaman status dengan mengirimkan
          // objek BookingModel yang baru melalui 'extra'.
          context.goNamed(
            RouteNames.bookingStatus,
            extra: newBookingModel,
          );
        },
      );
    } finally {
      // Pastikan state loading selalu kembali ke false, apa pun yang terjadi.
      state = false;
    }
  }
}