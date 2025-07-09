// lib/features/2_sc_list/view/widgets/sc_list_item_card.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gsports/config/router/route_names.dart';
import 'package:gsports/core/models/sc_model.dart';
import 'package:shimmer/shimmer.dart'; // Untuk efek loading gambar

/// `SCListItemCard` adalah widget yang menampilkan ringkasan informasi
/// dari satu Sports Center dalam bentuk kartu.
///
/// Widget ini dirancang untuk digunakan dalam daftar, seperti di halaman
/// hasil pencarian.
class SCListItemCard extends StatelessWidget {
  /// Data Sports Center yang akan ditampilkan.
  final SCModel sc;

  const SCListItemCard({
    super.key,
    required this.sc,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Card(
      // Menggunakan `clipBehavior` untuk memastikan gambar di dalam
      // kartu tidak keluar dari sudut yang rounded.
      clipBehavior: Clip.antiAlias,
      // Menggunakan `InkWell` untuk memberikan efek ripple saat di-tap
      // dan menangani navigasi.
      child: InkWell(
        onTap: () {
          // Navigasi ke halaman detail SC dengan mengirimkan ID SC
          // sebagai path parameter.
          context.goNamed(
            RouteNames.scDetails,
            pathParameters: {'scId': sc.id},
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Bagian Gambar ---
            // Menggunakan `CachedNetworkImage` untuk efisiensi loading dan caching.
            CachedNetworkImage(
              imageUrl: sc.mainPhotoUrl ?? '', // Gunakan URL dari model
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              // Placeholder yang ditampilkan saat gambar sedang di-download.
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  color: Colors.white,
                ),
              ),
              // Widget yang ditampilkan jika terjadi error saat memuat gambar.
              errorWidget: (context, url, error) => Container(
                height: 150,
                color: Colors.grey.shade200,
                child: const Icon(
                  Icons.image_not_supported_outlined,
                  color: Colors.grey,
                  size: 50,
                ),
              ),
            ),

            // --- Bagian Teks Informasi ---
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama Sports Center
                  Text(
                    sc.name,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Alamat Singkat
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${sc.address}, ${sc.city}',
                          style: textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Informasi Tambahan (Contoh: Jam Buka)
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_outlined,
                        size: 16,
                        color: textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Buka: ${sc.openTime.format(context)} - ${sc.closeTime.format(context)}',
                        style: textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}