// lib/features/2_sc_list/view/sc_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gsports/features/2_sc_list/controller/sc_list_controller.dart';
import 'package:gsports/features/2_sc_list/view/widgets/sc_list_item_card.dart';
import 'package:gsports/shared_widgets/error_display.dart';
import 'package:shimmer/shimmer.dart';

/// `SearchResultsScreen` menampilkan daftar Sports Center yang sesuai
/// dengan kriteria pencarian yang dikirim dari halaman sebelumnya.
class SearchResultsScreen extends ConsumerWidget {
  /// Parameter pencarian yang diterima dari GoRouter.
  final String city;
  final String sport;

  const SearchResultsScreen({
    super.key,
    required this.city,
    required this.sport,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Membuat instance SearchParams dari parameter yang diterima.
    final searchParams = SearchParams(city: city, sport: sport);
    
    // Mengawasi `scListProvider` dengan parameter pencarian.
    // Riverpod akan secara otomatis mengambil data atau mengembalikan dari cache.
    final scListAsyncValue = ref.watch(scListProvider(searchParams));

    return Scaffold(
      appBar: AppBar(
        title: Text('Hasil di "$city"'),
      ),
      body: scListAsyncValue.when(
        // --- 1. State Loading ---
        // Menampilkan efek shimmer sebagai placeholder saat data dimuat.
        loading: () => _buildLoadingShimmer(),
        
        // --- 2. State Error ---
        // Menampilkan widget error jika terjadi kegagalan.
        error: (error, stackTrace) => ErrorDisplay(
          message: error.toString(),
          // Kita bisa menambahkan tombol untuk mencoba lagi.
          onRetry: () => ref.invalidate(scListProvider(searchParams)),
        ),
        
        // --- 3. State Data ---
        // Menampilkan daftar hasil jika data berhasil didapat.
        data: (scList) {
          // Kasus jika daftar hasilnya kosong.
          if (scList.isEmpty) {
            return const Center(
              child: Text(
                'Oops! Tidak ada lapangan ditemukan.\nCoba cari di kota atau lokasi lain.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          // Kasus jika ada hasil.
          // Menggunakan `ListView.builder` untuk efisiensi.
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            itemCount: scList.length,
            itemBuilder: (context, index) {
              final sc = scList[index];
              return SCListItemCard(sc: sc);
            },
          );
        },
      ),
    );
  }

  /// Widget helper untuk membangun tampilan loading skeleton (shimmer).
  Widget _buildLoadingShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      itemCount: 5, // Tampilkan 5 placeholder shimmer
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 150,
                width: double.infinity,
                color: Colors.white,
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 24, width: 200, color: Colors.white),
                    const SizedBox(height: 8),
                    Container(height: 16, width: double.infinity, color: Colors.white),
                    const SizedBox(height: 8),
                    Container(height: 16, width: 150, color: Colors.white),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}