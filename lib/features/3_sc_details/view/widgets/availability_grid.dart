// lib/features/3_sc_details/view/widgets/availability_grid.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gsports/core/models/booking_model.dart';
import 'package:gsports/features/3_sc_details/controller/availability_controller.dart';
import 'package:gsports/features/4_booking/repository/booking_repository.dart';
import 'package:gsports/shared_widgets/error_display.dart';
import 'package:gsports/shared_widgets/loading_indicator.dart';

// --- PROVIDER BARU UNTUK STATE PILIHAN ---
/// `selectedSlotProvider` menyimpan state slot waktu yang sedang dipilih oleh pengguna.
///
/// Menggunakan `StateProvider<TimeOfDay?>` karena state-nya bisa berupa
/// `TimeOfDay` (jika ada yang dipilih) atau `null` (jika tidak ada yang dipilih).
/// `.autoDispose` memastikan state ini di-reset saat pengguna meninggalkan halaman,
/// sehingga pilihan tidak "nyangkut" untuk sesi berikutnya.
final selectedSlotProvider = StateProvider.autoDispose<TimeOfDay?>((ref) => null);


/// `AvailabilityGrid` adalah widget yang bertanggung jawab untuk menampilkan
/// grid jadwal ketersediaan slot waktu secara dinamis dan real-time.
class AvailabilityGrid extends ConsumerWidget {
  final String fieldId;
  final TimeOfDay openTime;
  final TimeOfDay closeTime;

  const AvailabilityGrid({
    super.key,
    required this.fieldId,
    required this.openTime,
    required this.closeTime,
  });

  // Method _generateTimeSlots dan _getSlotStatus tidak berubah.
  List<TimeOfDay> _generateTimeSlots(TimeOfDay open, TimeOfDay close) {
    final slots = <TimeOfDay>[];
    var currentTime = open;
    while (currentTime.hour < close.hour) {
      slots.add(currentTime);
      currentTime = currentTime.replacing(hour: currentTime.hour + 1);
    }
    return slots;
  }
  // Di dalam kelas AvailabilityGrid

  String _getSlotStatus(TimeOfDay slotTime, ScheduleData scheduleData) {
    // Cek apakah slot ini ada di dalam daftar blocked slots.
    final isBlocked = scheduleData.blockedSlots.any((blocked) {
      final start = TimeOfDay(hour: int.parse(blocked.startTime.split(':')[0]), minute: int.parse(blocked.startTime.split(':')[1]));
      final end = TimeOfDay(hour: int.parse(blocked.endTime.split(':')[0]), minute: int.parse(blocked.endTime.split(':')[1]));
      // Konversi ke menit untuk perbandingan yang mudah
      final slotInMinutes = slotTime.hour * 60 + slotTime.minute;
      final startInMinutes = start.hour * 60 + start.minute;
      final endInMinutes = end.hour * 60 + end.minute;
      // Slot dianggap terblokir jika berada di antara waktu mulai (inklusif) dan waktu selesai (eksklusif)
      return slotInMinutes >= startInMinutes && slotInMinutes < endInMinutes;
    });
    if (isBlocked) return 'Diblokir';

    // Cek apakah slot ini ada di dalam daftar booking yang valid.
    final isBooked = scheduleData.bookings.any((booking) {
      if (booking.status == BookingStatus.confirmed ||
          booking.status == BookingStatus.waitingForScConfirmation ||
          booking.status == BookingStatus.pendingPayment) {
        final start = TimeOfDay(hour: int.parse(booking.startTime.split(':')[0]), minute: int.parse(booking.startTime.split(':')[1]));
        final end = TimeOfDay(hour: int.parse(booking.endTime.split(':')[0]), minute: int.parse(booking.endTime.split(':')[1]));
        final slotInMinutes = slotTime.hour * 60 + slotTime.minute;
        final startInMinutes = start.hour * 60 + start.minute;
        final endInMinutes = end.hour * 60 + end.minute;
        return slotInMinutes >= startInMinutes && slotInMinutes < endInMinutes;
      }
      return false;
    });
    if (isBooked) return 'Dipesan';
    
    return 'Tersedia';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = AvailabilityParams(fieldId: fieldId);
    final asyncSchedule = ref.watch(availabilityControllerProvider(params));
    
    // --- PENAMBAHAN: Mengawasi provider pilihan ---
    final selectedSlot = ref.watch(selectedSlotProvider);

    return asyncSchedule.when(
      loading: () => const LoadingIndicator(),
      error: (error, stackTrace) => ErrorDisplay(
        message: error.toString(),
        onRetry: () => ref.invalidate(availabilityControllerProvider(params)),
      ),
      data: (scheduleData) {
        final timeSlots = _generateTimeSlots(openTime, closeTime);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 2.5,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: timeSlots.length,
          itemBuilder: (context, index) {
            final slotTime = timeSlots[index];
            final status = _getSlotStatus(slotTime, scheduleData);
            final bool isAvailable = status == 'Tersedia';
            
            // --- PENAMBAHAN: Cek apakah slot ini sedang dipilih ---
            final bool isSelected = selectedSlot == slotTime;

            // --- Logika Styling yang Diperbarui ---
            Color? bgColor = isSelected ? Theme.of(context).colorScheme.primary : null;
            Color? textColor = isSelected ? Theme.of(context).colorScheme.onPrimary : null;
            BorderSide borderSide = BorderSide(
              color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade400,
              width: isSelected ? 2.0 : 1.0,
            );

            if (status == 'Dipesan') {
              bgColor = Colors.red.withOpacity(0.1);
              textColor = Colors.red.shade800;
              borderSide = const BorderSide(color: Colors.transparent);
            } else if (status == 'Diblokir') {
              bgColor = Colors.grey.shade200;
              textColor = Colors.grey.shade600;
              borderSide = const BorderSide(color: Colors.transparent);
            }

            return OutlinedButton(
              onPressed: isAvailable
                  ? () {
                      // --- Logika Aksi yang Diperbarui ---
                      // `ref.read` digunakan di dalam callback.
                      // `.notifier` digunakan untuk mengakses instance Notifier-nya.
                      // `.state` digunakan untuk mengubah nilainya.
                      // Jika slot yang sama ditekan lagi, batalkan pilihan (set ke null).
                      ref.read(selectedSlotProvider.notifier).state = 
                          isSelected ? null : slotTime;
                    }
                  : null,
              style: OutlinedButton.styleFrom(
                backgroundColor: bgColor,
                foregroundColor: textColor,
                side: borderSide,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: EdgeInsets.zero,
              ),
              child: Text(slotTime.format(context)),
            );
          },
        );
      },
    );
  }
}