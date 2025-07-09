// lib/features/4_booking/view/booking_status_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gsports/config/router/route_names.dart';
import 'package:gsports/core/models/booking_model.dart';
import 'package:gsports/shared_widgets/custom_button.dart';
import 'package:intl/intl.dart';

class BookingStatusScreen extends StatelessWidget {
  /// Objek BookingModel dari booking yang baru saja dibuat.
  /// Ini akan diterima melalui parameter `extra` dari GoRouter.
  final BookingModel booking;

  const BookingStatusScreen({
    super.key,
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Menghilangkan tombol kembali default agar pengguna
        // menggunakan tombol navigasi yang kita sediakan.
        automaticallyImplyLeading: false,
        title: const Text('Status Pesanan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Gunakan `switch` pada status booking untuk menampilkan UI yang sesuai.
            // Ini membuat kode lebih bersih dan mudah diperluas.
            ...switch (booking.status) {
              BookingStatus.waitingForScConfirmation =>
                _buildSuccessContent(context),
              BookingStatus.pendingPayment =>
                _buildPendingPaymentContent(context, booking),
              // Default case untuk status lain yang mungkin terjadi
              _ => _buildGenericStatusContent(context, booking),
            },

            const Spacer(), // Mendorong tombol ke bawah

            // Tombol Navigasi
            ElevatedButton(
              onPressed: () {
                // Navigasi ke halaman riwayat. `goNamed` akan mengganti
                // tumpukan navigasi, jadi pengguna tidak bisa kembali ke halaman ini.
                context.goNamed(RouteNames.history);
              },
              child: const Text('Lihat Riwayat Pesanan'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                // Kembali ke halaman home.
                context.goNamed(RouteNames.home);
              },
              child: const Text('Kembali ke Beranda'),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget helper untuk konten "Sukses" (Bayar di Tempat).
  List<Widget> _buildSuccessContent(BuildContext context) {
    return [
      const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
      const SizedBox(height: 24),
      Text(
        'Pesanan Berhasil Dibuat!',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
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

  /// Widget helper untuk konten "Menunggu Pembayaran" (Transfer Bank).
  List<Widget> _buildPendingPaymentContent(BuildContext context, BookingModel booking) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return [
      const Icon(Icons.hourglass_top_outlined, color: Colors.orange, size: 80),
      const SizedBox(height: 24),
      Text(
        'Selesaikan Pembayaran Anda',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
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
      // TODO: Tambahkan tombol "Upload Bukti Bayar" di sini untuk pengembangan selanjutnya.
      _buildBookingId(context, booking.id),
    ];
  }

  /// Widget helper untuk status generik lainnya.
  List<Widget> _buildGenericStatusContent(BuildContext context, BookingModel booking) {
    return [
      const Icon(Icons.info_outline, color: Colors.blue, size: 80),
      const SizedBox(height: 24),
      Text(
        'Status Pesanan',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
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

  /// Widget helper untuk menampilkan Booking ID.
  Widget _buildBookingId(BuildContext context, String bookingId) {
    return Text(
      'ID Pesanan: $bookingId',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
    );
  }
}