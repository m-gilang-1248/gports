// lib/features/6_sc_admin/view/schedule/sc_admin_schedule_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gsports/core/models/field_model.dart';
import 'package:gsports/core/models/sc_model.dart';
import 'package:gsports/core/providers/user_data_provider.dart';
import 'package:gsports/features/3_sc_details/controller/availability_controller.dart';
import 'package:gsports/features/3_sc_details/controller/sc_details_controller.dart';
import 'package:gsports/features/3_sc_details/view/widgets/availability_grid.dart';
import 'package:gsports/features/6_sc_admin/controller/sc_admin_schedule_controller.dart';
import 'package:gsports/features/0_auth/controller/auth_controller.dart';
// --- Impor Baru ---
import 'package:gsports/features/6_sc_admin/view/schedule/widgets/add_manual_booking_dialog.dart';
import 'package:gsports/features/6_sc_admin/view/schedule/widgets/block_slot_dialog.dart';
import 'package:gsports/shared_widgets/error_display.dart';
import 'package:gsports/shared_widgets/loading_indicator.dart';
import 'package:intl/intl.dart';

class SCAdminScheduleScreen extends ConsumerWidget {
  const SCAdminScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider).value;
    if (user == null || user.assignedCenterId == null) {
      return const Scaffold(body: ErrorDisplay(message: 'Data admin tidak valid.'));
    }

    final asyncSCData = ref.watch(scDetailsDataProvider(user.assignedCenterId!));

    return Scaffold(
      appBar: AppBar(title: const Text('Jadwal & Ketersediaan')),
      body: asyncSCData.when(
        loading: () => const LoadingIndicator(),
        error: (e, st) => ErrorDisplay(message: e.toString()),
        data: (scData) => _buildContentView(context, ref, scData.scDetails, scData.fields),
      ),
    );
  }

  Widget _buildContentView(BuildContext context, WidgetRef ref, SCModel sc, List<FieldModel> fields) {
    final selectedField = ref.watch(selectedAdminFieldProvider);
    final theme = Theme.of(context);

    if (selectedField == null && fields.isNotEmpty) {
      Future.microtask(() => ref.read(selectedAdminFieldProvider.notifier).state = fields.first);
      return const LoadingIndicator();
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pilih Lapangan', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          DropdownButtonFormField<FieldModel>(
            value: selectedField,
            isExpanded: true,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            hint: const Text('Pilih lapangan untuk dilihat jadwalnya'),
            items: fields.map((field) => DropdownMenuItem(value: field, child: Text(field.name))).toList(),
            onChanged: (field) {
              if (field != null) {
                // Saat field diganti, reset juga pilihan tanggal & slot di halaman pemain
                // Ini penting agar tidak ada state yang nyangkut.
                // ref.invalidate(selectedSlotProvider);
                ref.invalidate(availabilityControllerProvider(AvailabilityParams(fieldId: field.id)));
                ref.read(selectedAdminFieldProvider.notifier).state = field;
              }
            },
          ),
          const Divider(height: 32),
          if (selectedField != null) ...[
            _buildDatePicker(context, ref, selectedField.id),
            const SizedBox(height: 16),
            Text('Jadwal untuk ${selectedField.name}', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            AvailabilityGrid(
              fieldId: selectedField.id,
              openTime: sc.openTime,
              closeTime: sc.closeTime,
              selectedSlot: null, // Admin tidak perlu menyorot slot
              onSlotTap: (slot) {
                // Ambil tanggal yang dipilih saat ini dari controller
                final params = AvailabilityParams(fieldId: selectedField.id);
                final selectedDate = ref.read(availabilityControllerProvider(params).notifier).selectedDate;
                // Panggil dialog aksi dengan semua data yang diperlukan
                _showAdminActionDialog(context, selectedField, selectedDate, slot);
              },
            ),
          ] else
            const Center(child: Text('Tidak ada lapangan tersedia untuk dikelola.')),
        ],
      ),
    );
  }
  
  /// Menampilkan dialog aksi untuk admin saat slot tersedia ditekan.
  void _showAdminActionDialog(BuildContext context, FieldModel field, DateTime date, TimeOfDay slot) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Aksi untuk Slot ${slot.format(context)}'),
        contentPadding: const EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 0.0),
        actionsPadding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add_task_outlined),
              title: const Text('Tambah Booking Manual'),
              onTap: () {
                Navigator.of(dialogContext).pop(); // Tutup dialog aksi
                // Tampilkan dialog tambah booking
                showDialog(
                  context: context,
                  // Gunakan `barrierDismissible: false` agar dialog tidak bisa ditutup
                  // dengan tap di luar area dialog, mencegah kehilangan input.
                  barrierDismissible: false,
                  builder: (_) => AddManualBookingDialog(field: field, date: date, time: slot),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.block_outlined),
              title: const Text('Blokir Slot Ini'),
              onTap: () {
                Navigator.of(dialogContext).pop(); // Tutup dialog aksi
                // Tampilkan dialog blokir slot
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => BlockSlotDialog(field: field, date: date, time: slot),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Batal'))
        ],
      ),
    );
  }

  /// Helper untuk membangun widget pemilih tanggal.
  Widget _buildDatePicker(BuildContext context, WidgetRef ref, String fieldId) {
    final params = AvailabilityParams(fieldId: fieldId);
    final asyncState = ref.watch(availabilityControllerProvider(params));

    return asyncState.when(
      data: (_) {
        final selectedDate = ref.watch(availabilityControllerProvider(params).notifier).selectedDate;
        return Center(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              textStyle: Theme.of(context).textTheme.titleSmall,
            ),
            icon: const Icon(Icons.calendar_today_outlined, size: 18),
            label: Text(DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(selectedDate)),
            onPressed: () async {
              final newDate = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2023), // Admin bisa lihat ke belakang
                lastDate: DateTime.now().add(const Duration(days: 365)),
                locale: const Locale('id', 'ID'),
              );
              if (newDate != null) {
                ref.read(availabilityControllerProvider(params).notifier).changeDate(newDate);
              }
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Gagal memuat tanggal: ${e.toString()}')),
    );
  }
}

// Perlu mengimpor `selectedSlotProvider` dari `field_details_screen.dart`
// agar bisa di-invalidate.
// lib/features/3_sc_details/view/field_details_screen.dart
// final selectedSlotProvider = StateProvider.autoDispose<TimeOfDay?>((ref) => null);