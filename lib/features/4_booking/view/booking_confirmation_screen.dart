// lib/features/4_booking/view/booking_confirmation_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gsports/core/models/booking_model.dart';
import 'package:gsports/core/models/field_model.dart';
import 'package:gsports/core/models/sc_model.dart';
import 'package:gsports/features/4_booking/controller/booking_controller.dart';
import 'package:gsports/shared_widgets/custom_button.dart';
import 'package:intl/intl.dart';

// --- 1. Kelas Parameter untuk Navigasi ---
/// `BookingConfirmationParams` adalah kelas untuk membungkus semua data
/// yang diperlukan oleh halaman konfirmasi. Ini dikirim via `extra` di GoRouter.
class BookingConfirmationParams {
  final SCModel sc;
  final FieldModel field;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final int durationInHours; // Durasi dalam jam

  BookingConfirmationParams({
    required this.sc,
    required this.field,
    required this.selectedDate,
    required this.selectedTime,
    this.durationInHours = 1, // Default durasi 1 jam
  });
}


// --- 2. Halaman UI ---
class BookingConfirmationScreen extends ConsumerWidget {
  final BookingConfirmationParams params;

  const BookingConfirmationScreen({
    super.key,
    required this.params,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final timeFormatter = DateFormat('HH:mm');
    final dateFormatter = DateFormat('EEEE, d MMMM yyyy', 'id_ID');

    // Menghitung detail waktu dan harga
    final startTime = params.selectedTime;
    final endTime = startTime.replacing(hour: startTime.hour + params.durationInHours);
    final totalPrice = params.field.pricePerHour * params.durationInHours;

    // Mengawasi state isLoading dari controller
    final isLoading = ref.watch(bookingControllerProvider);

    void onConfirmBooking() {
      // Membuat objek BookingModel yang akan dikirim ke controller.
      // Beberapa field (seperti ID, createdAt, dll) akan di-generate oleh backend
      // atau diisi oleh repository, jadi kita bisa beri nilai dummy di sini.
      final newBooking = BookingModel(
        id: '', // Akan di-generate oleh Appwrite
        playerUserId: '', // Akan diisi oleh controller
        centerId: params.sc.id,
        fieldId: params.field.id,
        bookingDate: params.selectedDate,
        startTime: '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
        endTime: '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
        durationHours: params.durationInHours.toDouble(),
        totalPrice: totalPrice,
        status: BookingStatus.waitingForScConfirmation, // Status awal
        bookedBy: BookedByRole.player,
        createdAt: DateTime.now(), // Nilai sementara
        updatedAt: DateTime.now(), // Nilai sementara
      );
      
      ref.read(bookingControllerProvider.notifier).createBooking(
        context: context,
        booking: newBooking,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Konfirmasi Pesanan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ringkasan Pesanan', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            // Kartu Detail Lokasi & Lapangan
            _buildInfoCard(
              theme: theme,
              children: [
                _buildInfoRow(Icons.business_outlined, params.sc.name, textTheme),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.sports_soccer_outlined, params.field.name, textTheme),
              ],
            ),
            const SizedBox(height: 16),

            // Kartu Detail Jadwal
            _buildInfoCard(
              theme: theme,
              children: [
                _buildInfoRow(Icons.calendar_today_outlined, dateFormatter.format(params.selectedDate), textTheme),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.access_time_outlined, '${timeFormatter.format(DateTime(0,0,0,startTime.hour, startTime.minute))} - ${timeFormatter.format(DateTime(0,0,0,endTime.hour, endTime.minute))}', textTheme),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.timelapse_outlined, '${params.durationInHours} Jam', textTheme),
              ],
            ),
            const SizedBox(height: 16),

            // Kartu Rincian Biaya
            _buildInfoCard(
              theme: theme,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Harga per Jam', style: textTheme.bodyLarge),
                    Text(currencyFormatter.format(params.field.pricePerHour), style: textTheme.bodyLarge),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Pembayaran', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Text(
                      currencyFormatter.format(totalPrice),
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      // Bottom bar untuk tombol konfirmasi
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CustomButton(
          text: 'Pesan Sekarang',
          isLoading: isLoading,
          onPressed: onConfirmBooking,
        ),
      ),
    );
  }

  // Widget helper untuk membuat kartu informasi
  Widget _buildInfoCard({required ThemeData theme, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(children: children),
    );
  }

  // Widget helper untuk membuat baris info (ikon + teks)
  Widget _buildInfoRow(IconData icon, String text, TextTheme textTheme) {
    return Row(
      children: [
        Icon(icon, size: 20, color: textTheme.bodySmall?.color),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: textTheme.bodyLarge)),
      ],
    );
  }
}