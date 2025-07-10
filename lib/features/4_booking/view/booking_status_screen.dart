// lib/features/4_booking/view/booking_status_screen.dart

import 'dart:io'; // <-- [BARU]

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // <-- [BARU]
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart'; // <-- [BARU]

import 'package:gsports/config/router/route_names.dart';
import 'package:gsports/core/models/booking_model.dart';
import 'package:gsports/features/4_booking/controller/payment_controller.dart'; // <-- [BARU]
import 'package:gsports/shared_widgets/custom_button.dart';
import 'package:intl/intl.dart';

// --- [DIEDIT] Ubah menjadi ConsumerWidget ---
class BookingStatusScreen extends ConsumerWidget {
  final BookingModel booking;

  const BookingStatusScreen({
    super.key,
    required this.booking,
  });

  // --- [BARU] Method untuk memilih dan mengunggah gambar ---
  void _pickAndUploadProof(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      // Jika ada file yang dipilih, panggil controller untuk memulai proses upload.
      ref.read(paymentControllerProvider.notifier).uploadPaymentProof(
            context: context,
            image: File(pickedFile.path),
            booking: booking,
          );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Status Pesanan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- [DIEDIT] Kirim ref ke helper method agar bisa me-watch state ---
            ...switch (booking.status) {
              BookingStatus.pendingPayment =>
                _buildPendingPaymentContent(context, ref, booking),
              BookingStatus.waitingForScConfirmation =>
                _buildSuccessContent(context),
              _ => _buildGenericStatusContent(context, booking),
            },
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                context.goNamed(RouteNames.history);
              },
              child: const Text('Lihat Riwayat Pesanan'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                context.goNamed(RouteNames.home);
              },
              child: const Text('Kembali ke Beranda'),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSuccessContent(BuildContext context) {
    return [
      const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
      const SizedBox(height: 24),
      Text(
        'Pesanan Berhasil Dibuat!',
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .headlineSmall
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 12),
      Text(
        'Pesanan Anda sedang menunggu konfirmasi dari pihak Sports Center. Silakan lakukan pembayaran di lokasi.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      const SizedBox(height: 16),
      _buildBookingId(context, booking.id),
    ];
  }

  // --- [DIEDIT] Helper method sekarang menerima WidgetRef ---
  List<Widget> _buildPendingPaymentContent(
      BuildContext context, WidgetRef ref, BookingModel booking) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    // Watch loading state dari payment controller
    final isLoading = ref.watch(paymentControllerProvider);

    return [
      const Icon(Icons.hourglass_top_outlined, color: Colors.orange, size: 80),
      const SizedBox(height: 24),
      Text(
        'Selesaikan Pembayaran Anda',
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .headlineSmall
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 12),
      Text(
        'Silakan transfer sejumlah:',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      Text(
        currencyFormatter.format(booking.totalPrice),
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
      const SizedBox(height: 16),
      const Text(
        'Ke rekening [Nama Bank] [No. Rekening] a/n [Nama Pemilik]. Batas waktu pembayaran adalah 1 jam dari sekarang.',
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 24),
      // --- [BARU] Tombol Upload Bukti Bayar ---
      CustomButton(
        text: 'Upload Bukti Bayar',
        isLoading: isLoading,
        onPressed: () => _pickAndUploadProof(context, ref),
      ),
      const SizedBox(height: 24),
      _buildBookingId(context, booking.id),
    ];
  }

  List<Widget> _buildGenericStatusContent(
      BuildContext context, BookingModel booking) {
    return [
      const Icon(Icons.info_outline, color: Colors.blue, size: 80),
      const SizedBox(height: 24),
      Text(
        'Status Pesanan',
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .headlineSmall
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 12),
      Text(
        'Status pesanan Anda saat ini adalah: ${booking.status.name}',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      const SizedBox(height: 16),
      _buildBookingId(context, booking.id),
    ];
  }

  Widget _buildBookingId(BuildContext context, String bookingId) {
    return Text(
      'ID Pesanan: $bookingId',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
    );
  }
}