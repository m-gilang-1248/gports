// lib/features/1_home/view/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gsports/features/0_auth/controller/auth_controller.dart';
import 'package:gsports/features/1_home/view/widgets/search_card.dart';
import 'package:gsports/shared_widgets/loading_indicator.dart'; // Akan kita buat

/// `HomeScreen` adalah halaman utama yang dilihat oleh pemain setelah login.
///
/// Halaman ini menampilkan sapaan kepada pengguna dan menyediakan fungsionalitas
/// pencarian utama untuk menemukan Sports Center.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mengawasi `userProvider` untuk mendapatkan data pengguna yang sedang login.
    final userAsyncValue = ref.watch(userProvider);
    final theme = Theme.of(context);

    return Scaffold(
      // AppBar yang menampilkan nama pengguna atau status loading.
      appBar: AppBar(
        title: userAsyncValue.when(
          data: (user) => Text(
            user != null ? 'Hai, ${user.name.split(' ')[0]}!' : 'Selamat Datang!',
            style: const TextStyle(fontWeight: FontWeight.normal),
          ),
          loading: () => const SizedBox.shrink(), // Tidak menampilkan apa-apa saat loading
          error: (e, st) => const Text('Error'),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Navigasi ke halaman notifikasi
            },
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
        // Menghilangkan bayangan default dari AppBar.
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        // Memungkinkan pengguna untuk refresh data (berguna di masa depan).
        onRefresh: () async {
          // `ref.refresh` akan memicu provider untuk mengambil data lagi.
          ref.refresh(userProvider);
          // Tambahkan refresh provider lain di sini jika perlu.
        },
        child: SingleChildScrollView(
          // `physics: AlwaysScrollableScrollPhysics()` memastikan RefreshIndicator
          // selalu berfungsi bahkan jika konten tidak melebihi layar.
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header Teks ---
              Text(
                'Mau main apa hari ini?',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
        
              // --- Kartu Pencarian ---
              const SearchCard(),
              const SizedBox(height: 32),
        
              // --- Bagian Opsional (Untuk Pengembangan Masa Depan) ---
              Text(
                'Populer di Dekatmu',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Placeholder untuk daftar SC populer.
              SizedBox(
                height: 150,
                child: Center(
                  child: Text(
                    'Fitur mendatang...',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}