// lib/features/3_sc_details/view/sc_details_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gsports/core/models/sc_model.dart';
import 'package:gsports/features/3_sc_details/controller/sc_details_controller.dart';
import 'package:gsports/features/3_sc_details/view/widgets/field_list_tile.dart';
import 'package:gsports/shared_widgets/error_display.dart';
import 'package:gsports/shared_widgets/loading_indicator.dart';

class SCDetailsScreen extends ConsumerWidget {
  final String scId;

  const SCDetailsScreen({super.key, required this.scId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mengawasi provider dengan ID SC yang relevan.
    final asyncData = ref.watch(scDetailsDataProvider(scId));

    return Scaffold(
      body: asyncData.when(
        loading: () => const LoadingIndicator(),
        error: (err, st) => ErrorDisplay(message: err.toString()),
        data: (data) => _buildContentView(context, data),
      ),
    );
  }

  /// Widget helper untuk membangun konten utama halaman.
  /// Ini dipisahkan agar method `build` utama tetap bersih.
  Widget _buildContentView(BuildContext context, SCDetailsData data) {
    final sc = data.scDetails;
    final fields = data.fields;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return CustomScrollView(
      slivers: [
        // --- AppBar yang bisa collapse dengan gambar ---
        SliverAppBar(
          expandedHeight: 250.0,
          floating: false,
          pinned: true,
          stretch: true,
          backgroundColor: theme.colorScheme.surface,
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            title: Text(
              sc.name,
              style: TextStyle(
                color: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
                fontSize: 16.0,
              ),
            ),
            background: CachedNetworkImage(
              imageUrl: sc.mainPhotoUrl ?? '',
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => Container(
                color: Colors.grey,
                child: const Icon(Icons.business, size: 100, color: Colors.white),
              ),
            ),
            stretchModes: const [StretchMode.zoomBackground],
          ),
        ),

        // --- Konten di bawah AppBar ---
        SliverList(
          delegate: SliverChildListDelegate([
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama Besar & Alamat
                  Text(sc.name, style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.location_on_outlined, '${sc.address}, ${sc.city}', textTheme),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.access_time_outlined, 'Buka: ${sc.openTime.format(context)} - ${sc.closeTime.format(context)}', textTheme),
                  const SizedBox(height: 8),
                  if (sc.contactPhone != null)
                     _buildInfoRow(Icons.phone_outlined, sc.contactPhone!, textTheme),
                  
                  const Divider(height: 48),

                  // Deskripsi
                  Text('Tentang Lokasi', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    sc.description ?? 'Tidak ada deskripsi.',
                    style: textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),

                  const Divider(height: 48),

                  // Daftar Lapangan
                  Text('Pilihan Lapangan', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  if (fields.isEmpty)
                    const Text('Saat ini belum ada lapangan yang tersedia.')
                  else
                    // Menggunakan ListView.builder di dalam Column tidak bisa,
                    // jadi kita map list menjadi widget.
                    ...fields.map((field) => FieldListTile(field: field)).toList(),
                ],
              ),
            ),
          ]),
        ),
      ],
    );
  }

  /// Widget helper untuk baris informasi (ikon + teks).
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