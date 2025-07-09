// lib/features/0_auth/controller/auth_controller.dart

import 'package:appwrite/models.dart' as appwrite_models;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gsports/core/models/user_model.dart';
import 'package:gsports/core/utils/snackbar.dart';
import 'package:gsports/features/0_auth/repository/auth_repository.dart';

// --- Provider ---

/// Provider untuk AuthController.
/// Menggunakan `StateNotifierProvider` karena `AuthController` mengelola state (isLoading).
/// `autoDispose` akan secara otomatis membersihkan state controller saat tidak lagi digunakan.
final authControllerProvider =
    StateNotifierProvider.autoDispose<AuthController, bool>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthController(authRepository: authRepository, ref: ref);
});

/// Provider untuk mendapatkan status autentikasi real-time (login/logout).
/// `authStateChangesProvider` akan memberitahu aplikasi setiap kali status login berubah.
/// Ini sangat penting untuk `GoRouter` agar bisa melakukan redirect secara otomatis.
final authStateChangesProvider = StreamProvider<appwrite_models.User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  // `getCurrentUserAccount` akan diperiksa secara berkala oleh StreamProvider
  // atau kita bisa membuatnya menjadi stream nyata dari Appwrite Realtime.
  // Untuk kesederhanaan, kita akan memanggilnya kembali saat ada perubahan.
  // NOTE: Pendekatan yang lebih canggih adalah menggunakan Appwrite Realtime
  // untuk subscribe ke 'account' channel.
  return authRepository.getCurrentUserAccount().asStream();
});

/// Provider untuk mendapatkan data UserModel dari pengguna yang sedang login.
/// `userProvider` akan mengambil data dari `authStateChangesProvider` dan
/// mengubahnya menjadi `UserModel` kita. Ini akan menjadi sumber data pengguna
/// utama di seluruh aplikasi.
final userProvider = FutureProvider<UserModel?>((ref) async {
  final account = await ref.watch(authStateChangesProvider.future);
  if (account != null) {
    return UserModel.fromAppwriteUser(account);
  }
  return null;
});


// --- Controller Class ---

class AuthController extends StateNotifier<bool> {
  final AuthRepository _authRepository;
  final Ref _ref;

  /// Constructor.
  /// `state = false` berarti state awal `isLoading` adalah `false`.
  AuthController({
    required AuthRepository authRepository,
    required Ref ref,
  })  : _authRepository = authRepository,
        _ref = ref,
        super(false);

  /// Method yang dipanggil dari UI untuk proses sign up.
  void signUp({
    required String email,
    required String password,
    required String name,
    required BuildContext context,
  }) async {
    // 1. Set state `isLoading` menjadi `true`
    state = true;
    final result = await _authRepository.signUp(
      email: email,
      password: password,
      name: name,
    );
    // 3. Setelah selesai, set state `isLoading` kembali menjadi `false`
    state = false;

    // 4. Tangani hasilnya (sukses atau gagal)
    result.fold(
      // Jika gagal (Left), tampilkan pesan error.
      (failure) => showSnackBar(context, failure.message),
      // Jika sukses (Right), tampilkan pesan sukses dan mungkin navigasi.
      // Navigasi akan ditangani oleh GoRouter secara otomatis karena
      // authStateChangesProvider akan mendeteksi perubahan.
      (r) {
        showSnackBar(context, 'Account created successfully! Please log in.');
      },
    );
  }

  /// Method yang dipanggil dari UI untuk proses login.
  void login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    state = true;
    final result = await _authRepository.login(
      email: email,
      password: password,
    );
    state = false;

    result.fold(
      (failure) => showSnackBar(context, failure.message),
      // Jika login sukses, kita tidak perlu melakukan apa-apa di sini.
      // `GoRouter` akan mendengarkan perubahan pada `authStateChangesProvider`
      // dan secara otomatis mengarahkan pengguna ke halaman yang benar.
      (userModel) {
        // Log atau aksi lain bisa ditambahkan di sini jika perlu.
      },
    );
  }

  /// Method yang dipanggil dari UI untuk proses logout.
  void logout(BuildContext context) async {
    final result = await _authRepository.logout();
    result.fold(
      (failure) => showSnackBar(context, failure.message),
      // Jika logout sukses, GoRouter akan otomatis mengarahkan ke halaman login.
      (r) {
        // Bisa tambahkan pesan sukses jika perlu.
      },
    );
  }
}