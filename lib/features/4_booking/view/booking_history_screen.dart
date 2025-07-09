// lib/features/4_booking/view/booking_history_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gsports/core/models/booking_model.dart';
import 'package:gsports/core/providers/user_data_provider.dart';
import 'package:gsports/features/4_booking/repository/booking_repository.dart';
import 'package:gsports/shared_widgets/error_display.dart';
import 'package:gsports/shared_widgets/loading_indicator.dart';
import 'package:intl/intl.dart';
import 'package:gsports/features/0_auth/controller/auth_controller.dart';

// --- 1. Provider untuk data Riwayat Booking ---
/// `bookingHistoryProvider` adalah `FutureProvider` yang mengambil daftar
/// riwayat booking untuk pengguna yang sedang login.
///
/// Ia bergantung pada `userProvider` untuk mendapatkan ID pengguna.
final bookingHistoryProvider = FutureProvider.autoDispose<List<BookingModel>>((ref) async {
  // Ambil data pengguna yang sedang login.
  final user = ref.watch(userProvider).value;
  if (user == null) {
    // Jika tidak ada user, kembalikan daftar kosong. Seharusnya tidak terjadi
    // karena halaman ini diproteksi oleh router.
    return [];
  }
  
  // Ambil repository dan panggil method-nya.
  final bookingRepository = ref.watch(bookingRepositoryProvider);
  final result = await bookingRepository.getBookingHistory(userId: user.uid);
  
  // Kembalikan hasilnya atau lempar error.
  return result.fold(
    (failure) => throw failure,
    (bookings) => bookings,
  );
});


// --- 2. Halaman UI ---
class BookingHistoryScreen extends ConsumerWidget {
  const BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mengawasi provider riwayat booking.
    final asyncHistory = ref.watch(bookingHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pesanan'),
      ),
      body: RefreshIndicator(
        // Menambahkan kemampuan untuk refresh daftar riwayat.
        onRefresh: () async => ref.invalidate(bookingHistoryProvider),
        child: asyncHistory.when(
          loading: () => const LoadingIndicator(),
          error: (error, stack) => ErrorDisplay(
            message: error.toString(),
            onRetry: () => ref.invalidate(bookingHistoryProvider),
          ),
          data: (bookings) {
            // Jika tidak ada riwayat booking.
            if (bookings.isEmpty) {
              return const Center(
                child: Text(
                  'Anda belum pernah membuat pesanan.',
                  style: TextStyle(fontSize: 16),
                ),
              );
            }
            
            // Jika ada riwayat, tampilkan dalam ListView.
            return ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return _BookingHistoryCard(booking: booking);
              },
            );
          },
        ),
      ),
    );
  }
}


// --- 3. Widget Kustom untuk Kartu Riwayat ---
class _BookingHistoryCard extends StatelessWidget {
  final BookingModel booking;

  const _BookingHistoryCard({required this.booking});

  // Helper untuk mendapatkan warna dan teks status yang sesuai.
  (Color, String) _getStatusInfo(BookingStatus status, BuildContext context) {
    switch (status) {
      case BookingStatus.confirmed:
        return (Colors.green, 'Terkonfirmasi');
      case BookingStatus.pendingPayment:
        return (Colors.orange, 'Menunggu Pembayaran');
      case BookingStatus.waitingForScConfirmation:
        return (Colors.blue, 'Menunggu Konfirmasi');
      case BookingStatus.cancelledByPlayer:
      case BookingStatus.cancelledBySc:
        return (Colors.red, 'Dibatalkan');
      case BookingStatus.completed:
        return (Theme.of(context).disabledColor, 'Selesai');
      default:
        return (Colors.grey, status.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final (statusColor, statusText) = _getStatusInfo(booking.status, context);
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFormatter = DateFormat('d MMMM yyyy', 'id_ID');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          // TODO: Navigasi ke halaman detail riwayat (UI-P12)
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Baris atas: Info Lapangan dan Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      // TODO: Kita perlu cara untuk mendapatkan nama lapangan/SC dari ID.
                      // Untuk sekarang, tampilkan ID-nya saja.
                      'Booking di Lapangan ID: ${booking.fieldId}',
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusText,
                      style: textTheme.bodySmall?.copyWith(color: statusColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Baris bawah: Info Tanggal dan Harga
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Jadwal Main', style: textTheme.bodySmall),
                      Text(
                        '${dateFormatter.format(booking.bookingDate)}, ${booking.startTime}',
                        style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Total Harga', style: textTheme.bodySmall),
                      Text(
                        currencyFormatter.format(booking.totalPrice),
                        style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}