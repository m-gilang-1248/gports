// lib/features/3_sc_details/view/field_details_screen.dart

// ... (semua impor tetap sama)
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gsports/config/router/route_names.dart';
import 'package:gsports/core/models/field_model.dart';
import 'package:gsports/core/models/sc_model.dart';
import 'package:gsports/core/utils/snackbar.dart';
import 'package:gsports/features/3_sc_details/controller/availability_controller.dart';
import 'package:gsports/features/3_sc_details/controller/sc_details_controller.dart';
import 'package:gsports/features/3_sc_details/view/widgets/availability_grid.dart';
import 'package:gsports/features/4_booking/view/booking_confirmation_screen.dart';
import 'package:gsports/shared_widgets/custom_button.dart';
import 'package:gsports/shared_widgets/error_display.dart';
import 'package:gsports/shared_widgets/loading_indicator.dart';
import 'package:intl/intl.dart';


// ... (provider selectedSlotProvider tidak berubah)
final selectedSlotProvider = StateProvider.autoDispose<TimeOfDay?>((ref) => null);


class FieldDetailsScreen extends ConsumerWidget {
  final String fieldId;
  const FieldDetailsScreen({super.key, required this.fieldId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scId = GoRouterState.of(context).pathParameters['scId']!;
    final asyncData = ref.watch(scDetailsDataProvider(scId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Lapangan'),
      ),
      body: asyncData.when(
        loading: () => const LoadingIndicator(),
        error: (err, st) => ErrorDisplay(message: err.toString()),
        data: (data) {
          final field = data.fields.firstWhere((f) => f.id == fieldId);
          final sc = data.scDetails;
          return _buildContentView(context, ref, sc, field);
        },
      ),
    );
  }

  Widget _buildContentView(BuildContext context, WidgetRef ref, SCModel sc, FieldModel field) {
    final theme = Theme.of(context);
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    // --- DIEDIT DI SINI ---
    void onBookNow() {
      final selectedSlot = ref.read(selectedSlotProvider);
      final params = AvailabilityParams(fieldId: field.id);
      final selectedDate = ref.read(availabilityControllerProvider(params).notifier).selectedDate;
      
      if (selectedSlot == null) {
        showSnackBar(context, 'Silakan pilih slot waktu terlebih dahulu.', isError: true);
        return;
      }

      final bookingParams = BookingConfirmationParams(
        sc: sc,
        field: field,
        selectedDate: selectedDate,
        selectedTime: selectedSlot,
        durationInHours: 1,
      );
      
      // [PERBAIKAN] Kita hanya perlu menyediakan path parameter `scId` karena
      // rute `bookingConfirmation` bersarang di bawah `scDetails`, bukan `fieldDetails`.
      // Path lengkapnya adalah: /home/sc/:scId/booking
      context.goNamed(
        RouteNames.bookingConfirmation,
        pathParameters: {'scId': sc.id}, // HANYA scId yang diperlukan
        extra: bookingParams,
      );
    }
    
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Anda mungkin ingin menampilkan galeri foto field di sini
                if (field.photosUrls.isNotEmpty)
                  SizedBox(
                    height: 250,
                    child: PageView.builder(
                      itemCount: field.photosUrls.length,
                      itemBuilder: (context, index) {
                        return CachedNetworkImage(
                          imageUrl: field.photosUrls[index],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => _buildImagePlaceholder(),
                          errorWidget: (context, url, error) => _buildImageError(),
                        );
                      },
                    ),
                  )
                else
                  _buildImagePlaceholder(),
                
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(field.name, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(field.description ?? 'Tidak ada deskripsi untuk lapangan ini.'),
                      const Divider(height: 32),
                      Text('Pilih Jadwal', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      _buildDatePicker(context, ref, field.id),
                      const SizedBox(height: 16),
                      AvailabilityGrid(
                        fieldId: field.id,
                        openTime: sc.openTime,
                        closeTime: sc.closeTime,
                        selectedSlot: ref.watch(selectedSlotProvider),
                        onSlotTap: (slot) {
                          ref.read(selectedSlotProvider.notifier).state = 
                            (ref.read(selectedSlotProvider) == slot) ? null : slot;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildBookingBottomBar(
          context: context,
          price: currencyFormatter.format(field.pricePerHour),
          onPressed: onBookNow,
        ),
      ],
    );
  }
  
  // ... (semua method helper lainnya tidak berubah)
  Widget _buildImagePlaceholder() {
    return Container(height: 250, color: Colors.grey.shade300);
  }
  Widget _buildImageError() {
    return Container(
      height: 250,
      color: Colors.grey.shade300,
      child: const Center(child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey)),
    );
  }
  Widget _buildDatePicker(BuildContext context, WidgetRef ref, String fieldId) {
    // ... (kode ini sudah benar)
    final params = AvailabilityParams(fieldId: fieldId);
    final asyncState = ref.watch(availabilityControllerProvider(params));
    return asyncState.when(
      data: (_) {
        final selectedDate = ref.watch(availabilityControllerProvider(params).notifier).selectedDate;
        return Center(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), textStyle: Theme.of(context).textTheme.titleSmall),
            icon: const Icon(Icons.calendar_today_outlined, size: 18),
            label: Text(DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(selectedDate)),
            onPressed: () async {
              final newDate = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 1)),
                lastDate: DateTime.now().add(const Duration(days: 30)),
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
  Widget _buildBookingBottomBar({required BuildContext context, required String price, required VoidCallback onPressed}) {
    // ... (kode ini sudah benar)
    return Container(
      padding: const EdgeInsets.all(16.0).copyWith(top: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Harga per jam', style: Theme.of(context).textTheme.bodySmall),
              Text(price, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.4,
            child: CustomButton(
              text: 'Pesan Sekarang',
              onPressed: onPressed,
            ),
          ),
        ],
      ),
    );
  }
}