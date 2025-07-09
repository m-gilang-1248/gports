// lib/features/6_sc_admin/view/bookings/sc_admin_booking_details_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gsports/core/models/booking_model.dart';
import 'package:gsports/features/6_sc_admin/controller/sc_admin_bookings_controller.dart';
import 'package:gsports/shared_widgets/custom_button.dart';
import 'package:intl/intl.dart';

class SCAdminBookingDetailsScreen extends ConsumerWidget {
  final BookingModel booking;

  const SCAdminBookingDetailsScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(scAdminBookingsControllerProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pesanan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoSection('Info Booking', {
              'Booking ID': booking.id,
              'Status': booking.status.name,
              'Dipesan pada': DateFormat.yMMMd('id_ID').add_jm().format(booking.createdAt),
            }),
            _buildInfoSection('Info Jadwal', {
              'Lapangan ID': booking.fieldId,
              'Tanggal Main': DateFormat.yMMMMEEEEd('id_ID').format(booking.bookingDate),
              'Waktu': '${booking.startTime} - ${booking.endTime}',
              'Durasi': '${booking.durationHours} Jam',
            }),
            _buildInfoSection('Info Pemesan', {'User ID': booking.playerUserId}),
            _buildInfoSection('Info Pembayaran', {
              'Total Harga': NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(booking.totalPrice),
              'Metode Bayar': booking.paymentMethod ?? 'N/A',
            }),
          ],
        ),
      ),
      bottomNavigationBar: _buildActionButtons(context, ref, isLoading),
    );
  }

  Widget _buildInfoSection(String title, Map<String, String> data) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(height: 20),
            ...data.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key, style: const TextStyle(color: Colors.grey)),
                  Expanded(child: Text(entry.value, textAlign: TextAlign.end)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget? _buildActionButtons(BuildContext context, WidgetRef ref, bool isLoading) {
    final controller = ref.read(scAdminBookingsControllerProvider.notifier);

    void updateStatus(BookingStatus newStatus) {
      controller.updateBookingStatus(
        context: context,
        bookingId: booking.id,
        scId: booking.centerId,
        newStatus: newStatus,
      );
    }

    List<Widget> buttons = [];
    
    // Logika tombol berdasarkan status saat ini
    switch (booking.status) {
      case BookingStatus.waitingForScConfirmation:
      case BookingStatus.pendingPayment:
        buttons = [
          Expanded(child: CustomButton(text: 'Tolak', isLoading: isLoading, onPressed: () => updateStatus(BookingStatus.cancelledBySc), backgroundColor: Colors.red)),
          const SizedBox(width: 12),
          Expanded(child: CustomButton(text: 'Konfirmasi', isLoading: isLoading, onPressed: () => updateStatus(BookingStatus.confirmed))),
        ];
        break;
      case BookingStatus.confirmed:
        buttons = [
          Expanded(child: CustomButton(text: 'Tandai Selesai', isLoading: isLoading, onPressed: () => updateStatus(BookingStatus.completed))),
        ];
        break;
      default:
        // Tidak ada aksi untuk status lain seperti cancelled atau completed
        return null;
    }
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(children: buttons),
    );
  }
}

// Tambahkan parameter backgroundColor ke CustomButton jika belum ada
// di file `shared_widgets/custom_button.dart`
// style: ElevatedButton.styleFrom(backgroundColor: backgroundColor ?? AppColors.lightPrimary, ...)