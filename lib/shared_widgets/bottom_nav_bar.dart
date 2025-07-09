// lib/shared_widgets/bottom_nav_bar.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// `BottomNavBarShell` adalah widget yang berfungsi sebagai "cangkang" atau
/// layout utama untuk halaman-halaman yang menggunakan `BottomNavigationBar`.
///
/// Widget ini digunakan bersama dengan `StatefulShellRoute` dari GoRouter
/// untuk menciptakan navigasi bertab yang persisten (state di setiap tab
/// tidak hilang saat berpindah).
class BottomNavBarShell extends StatelessWidget {
  /// `navigationShell` adalah objek yang disediakan oleh `StatefulShellRoute`.
  /// Ia berisi konten dari branch rute yang sedang aktif dan menyediakan
  /// method `goBranch` untuk berpindah antar tab.
  final StatefulNavigationShell navigationShell;

  const BottomNavBarShell({
    super.key,
    required this.navigationShell,
  });

  /// Method yang akan dipanggil saat item di `BottomNavigationBar` di-tap.
  void _onTap(int index) {
    // `goBranch` akan menavigasi ke branch yang sesuai dengan index.
    //
    // `initialLocation: true` berarti jika kita kembali ke sebuah tab,
    // ia akan menampilkan halaman awal dari tab tersebut, bukan halaman
    // terakhir yang kita kunjungi di dalam tab itu.
    // Set ke `false` jika Anda ingin state navigasi di dalam tab tetap ada.
    // Untuk kebanyakan kasus, `true` adalah perilaku yang lebih diharapkan.
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body dari Scaffold akan diisi oleh konten dari branch rute
      // yang sedang aktif, yang disediakan oleh `navigationShell`.
      body: navigationShell,

      // --- Bottom Navigation Bar ---
      bottomNavigationBar: BottomNavigationBar(
        // `currentIndex` memberitahu `BottomNavigationBar` item mana yang
        // harus di-highlight sebagai aktif.
        currentIndex: navigationShell.currentIndex,
        onTap: _onTap,
        
        // Tipe `fixed` memastikan semua item selalu terlihat dan memiliki
        // lebar yang sama, cocok untuk 3-4 item.
        type: BottomNavigationBarType.fixed,
        
        // Items adalah daftar dari tab yang akan ditampilkan.
        // Urutannya HARUS sama dengan urutan `branches` di `StatefulShellRoute`.
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Akun',
          ),
        ],
      ),
    );
  }
}