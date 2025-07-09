// lib/features/6_sc_admin/view/dashboard/sc_admin_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gsports/config/router/route_names.dart';
import 'package:gsports/core/models/user_model.dart';
import 'package:gsports/core/providers/user_data_provider.dart';
import 'package:gsports/features/0_auth/controller/auth_controller.dart';
import 'package:gsports/features/3_sc_details/controller/sc_details_controller.dart';
import 'package:gsports/shared_widgets/error_display.dart';
import 'package:gsports/shared_widgets/loading_indicator.dart';

class SCAdminDashboardScreen extends ConsumerWidget {
  const SCAdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ambil data pengguna yang sedang login untuk mendapatkan assignedCenterId
    final userAsync = ref.watch(userProvider);
    
    // Jika data user belum siap, tampilkan loading.
    if (userAsync.isLoading) {
      return const Scaffold(body: LoadingIndicator());
    }
    // Jika ada error saat mengambil data user.
    if (userAsync.hasError) {
      return Scaffold(body: ErrorDisplay(message: userAsync.error.toString()));
    }
    
    final user = userAsync.value;
    // Pengaman jika user null atau tidak memiliki assignedCenterId.
    if (user == null || user.assignedCenterId == null) {
      return const Scaffold(body: ErrorDisplay(message: 'Data admin tidak valid.'));
    }

    // Ambil data detail SC menggunakan provider yang sudah ada.
    final scAsync = ref.watch(scDetailsDataProvider(user.assignedCenterId!));

    return Scaffold(
      appBar: AppBar(
        title: scAsync.when(
          data: (data) => Text(data.scDetails.name),
          loading: () => const Text('Memuat...'),
          error: (e, st) => const Text('Dashboard'),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Navigasi ke halaman notifikasi admin
            },
            icon: const Icon(Icons.notifications_outlined),
          ),
          // Tombol Logout
          IconButton(
            onPressed: () {
              ref.read(authControllerProvider.notifier).logout(context);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Kartu Ringkasan ---
            _buildSummaryCards(context),
            const SizedBox(height: 24),

            // --- Menu Navigasi Utama ---
            _buildNavigationMenu(context),
          ],
        ),
      ),
    );
  }

  /// Widget helper untuk membangun kartu-kartu ringkasan.
  Widget _buildSummaryCards(BuildContext context) {
    // Untuk MVP, kita gunakan data statis.
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: const [
        _SummaryCard(
          title: 'Booking Hari Ini',
          value: '12', // Data dummy
          icon: Icons.calendar_today,
          color: Colors.blue,
        ),
        _SummaryCard(
          title: 'Pendapatan Hari Ini',
          value: 'Rp 1.2jt', // Data dummy
          icon: Icons.monetization_on,
          color: Colors.green,
        ),
      ],
    );
  }

  /// Widget helper untuk membangun menu navigasi utama.
  Widget _buildNavigationMenu(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Menu Manajemen',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _MenuTile(
          title: 'Manajemen Lapangan',
          subtitle: 'Tambah, edit, atau nonaktifkan lapangan',
          icon: Icons.sports_soccer_outlined,
          onTap: () {
            context.goNamed(RouteNames.adminFieldList);
          },
        ),
        _MenuTile(
          title: 'Daftar Pemesanan',
          subtitle: 'Lihat dan kelola semua pesanan masuk',
          icon: Icons.list_alt_rounded,
          onTap: () {
            context.goNamed(RouteNames.adminBookingList);
          },
        ),
        _MenuTile(
          title: 'Jadwal & Ketersediaan',
          subtitle: 'Blokir slot atau tambah pesanan manual',
          icon: Icons.calendar_month_outlined,
          onTap: () {
            context.goNamed(RouteNames.adminSchedule);
          },
        ),
        _MenuTile(
          title: 'Profil Sports Center',
          subtitle: 'Ubah informasi dan foto lokasi Anda',
          icon: Icons.store_mall_directory_outlined,
          onTap: () {
            context.goNamed(RouteNames.adminProfile);
          },
        ),
      ],
    );
  }
}

// --- Widget Kustom Internal ---

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.1),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 28, color: color),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: color)),
                Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color)),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _MenuTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}