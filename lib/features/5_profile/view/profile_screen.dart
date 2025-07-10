// lib/features/5_profile/view/profile_screen.dart

import 'package:cached_network_image/cached_network_image.dart'; // <-- [BARU] Impor
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gsports/config/router/route_names.dart';
import 'package:gsports/features/0_auth/controller/auth_controller.dart';
import 'package:gsports/shared_widgets/error_display.dart';
import 'package:gsports/shared_widgets/loading_indicator.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Kita watch `userProvider` yang sekarang berisi `photoUrl`
    final userAsync = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Akun Saya'),
      ),
      body: userAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, st) => ErrorDisplay(message: e.toString()),
        data: (user) {
          if (user == null) {
            return const ErrorDisplay(message: 'Gagal memuat data pengguna.');
          }
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // --- Header Profil [DIEDIT] ---
              Row(
                children: [
                  // Gunakan CircleAvatar dengan background image dari network
                  CircleAvatar(
                    radius: 40,
                    // Tampilkan placeholder jika URL foto tidak ada atau sedang loading
                    backgroundImage: (user.photoUrl != null)
                        ? CachedNetworkImageProvider(user.photoUrl!)
                        : null,
                    child: (user.photoUrl == null)
                        // Tampilkan ikon hanya jika tidak ada foto
                        ? const Icon(Icons.person, size: 40)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  // Bagian nama dan email tidak berubah
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        Text(user.email,
                            style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 48),

              // --- Menu (Tidak ada perubahan di sini) ---
              _buildMenuTile(
                context,
                title: 'Edit Profil',
                icon: Icons.edit_outlined,
                onTap: () => context.goNamed(RouteNames.editProfile, extra: user),
              ),
              _buildMenuTile(
                context,
                title: 'Ubah Kata Sandi',
                icon: Icons.lock_outline,
                onTap: () { /* TODO: Implementasi Ubah Kata Sandi */ },
              ),
              _buildMenuTile(
                context,
                title: 'Bantuan & FAQ',
                icon: Icons.help_outline,
                onTap: () { /* TODO: Navigasi ke Halaman Bantuan */ },
              ),
              _buildMenuTile(
                context,
                title: 'Tentang Aplikasi',
                icon: Icons.info_outline,
                onTap: () { /* TODO: Navigasi ke Halaman Tentang */ },
              ),
              const Divider(height: 32),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: () =>
                    ref.read(authControllerProvider.notifier).logout(context),
              ),
            ],
          );
        },
      ),
    );
  }

  // Method helper tidak berubah
  Widget _buildMenuTile(BuildContext context,
      {required String title,
      required IconData icon,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}