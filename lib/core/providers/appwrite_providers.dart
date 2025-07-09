// lib/core/providers/appwrite_providers.dart

import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/appwrite_constants.dart'; // Mengimpor konstanta kita

/// Provider untuk Appwrite `Client`.
///
/// Ini adalah provider paling dasar yang membuat koneksi ke project Appwrite.
/// Provider lain akan bergantung (watch) pada provider ini.
///
/// `Provider` adalah tipe provider yang paling sederhana dari Riverpod,
/// cocok untuk objek yang tidak akan berubah setelah dibuat (immutable).
final appwriteClientProvider = Provider<Client>((ref) {
  // Membuat instance baru dari Client.
  final client = Client();

  // Mengatur konfigurasi client menggunakan konstanta yang sudah kita definisikan.
  // Ini memastikan semua konfigurasi terpusat di `appwrite_constants.dart`.
  return client
      .setEndpoint(AppwriteConstants.endPoint)
      .setProject(AppwriteConstants.projectId)
      // Baris di bawah ini penting jika Anda melakukan development dengan Appwrite
      // yang di-host secara lokal (self-hosted) dan menggunakan sertifikat SSL
      // yang self-signed. Untuk Appwrite Cloud, ini bisa di-set `false` atau dihapus.
      // Namun, aman untuk membiarkannya `true` selama development.
      .setSelfSigned(status: true);
});

/// Provider untuk layanan Appwrite `Account`.
///
/// Provider ini bergantung pada `appwriteClientProvider`. Riverpod secara
/// otomatis akan memastikan bahwa `appwriteClientProvider` sudah siap
/// sebelum membuat `Account`.
final appwriteAccountProvider = Provider<Account>((ref) {
  // 'ref.watch' digunakan untuk mendapatkan nilai dari provider lain.
  final client = ref.watch(appwriteClientProvider);
  return Account(client);
});

/// Provider untuk layanan Appwrite `Databases`.
final appwriteDatabaseProvider = Provider<Databases>((ref) {
  final client = ref.watch(appwriteClientProvider);
  return Databases(client);
});

/// Provider untuk layanan Appwrite `Storage`.
final appwriteStorageProvider = Provider<Storage>((ref) {
  final client = ref.watch(appwriteClientProvider);
  return Storage(client);
});

/// Provider untuk layanan Appwrite `Realtime`.
final appwriteRealtimeProvider = Provider<Realtime>((ref) {
  final client = ref.watch(appwriteClientProvider);
  return Realtime(client);
});