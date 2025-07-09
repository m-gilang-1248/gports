// lib/features/0_auth/controller/auth_controller.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appwrite/models.dart' as appwrite_models;
import 'package:gsports/core/models/user_model.dart';
import 'package:gsports/core/utils/snackbar.dart';
import 'package:gsports/features/0_auth/repository/auth_repository.dart';

// --- Provider ---

final authControllerProvider =
    StateNotifierProvider.autoDispose<AuthController, bool>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthController(authRepository: authRepository, ref: ref);
});

/// Provider ini sangat penting untuk GoRouter.
/// Ia memberitahu seluruh aplikasi tentang status sesi saat ini.
final authStateChangesProvider = StreamProvider<appwrite_models.User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.getCurrentUserAccount().asStream();
});

/// Provider ini mengubah data mentah dari Appwrite menjadi UserModel kita yang bersih.
/// GoRouter akan mengawasinya untuk membuat keputusan berbasis peran.
final userProvider = FutureProvider<UserModel?>((ref) async {
  // Mengawasi perubahan sesi
  final account = await ref.watch(authStateChangesProvider.future);
  if (account != null) {
    // Jika ada sesi, konversi menjadi UserModel
    return UserModel.fromAppwriteUser(account);
  }
  // Jika tidak ada sesi, kembalikan null
  return null;
});


// --- Controller Class ---

class AuthController extends StateNotifier<bool> {
  final AuthRepository _authRepository;
  final Ref _ref;

  AuthController({
    required AuthRepository authRepository,
    required Ref ref,
  })  : _authRepository = authRepository,
        _ref = ref,
        super(false);

  /// Method signUp yang bersih.
  /// Tugasnya hanya memanggil repository dan memberitahu UI.
  void signUp({
    required String email,
    required String password,
    required String name,
    required BuildContext context,
  }) async {
    state = true; // Tampilkan loading
    final result = await _authRepository.signUp(
      email: email,
      password: password,
      name: name,
    );
    state = false; // Sembunyikan loading

    result.fold(
      (failure) => showSnackBar(context, failure.message, isError: true),
      (userModel) {
        // --- PERUBAHAN ---
        // 1. Invalidate provider agar GoRouter tahu state berubah.
        _ref.invalidate(authStateChangesProvider);
        _ref.invalidate(userProvider);
        // 2. Beri feedback ke pengguna.
        showSnackBar(context, 'Selamat datang, ${userModel.name}!');
        // 3. TIDAK ADA NAVIGASI. Biarkan GoRouter redirect yang bekerja.
      },
    );
  }

  /// Method login yang bersih.
  void login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    state = true; // Tampilkan loading
    final result = await _authRepository.login(
      email: email,
      password: password,
    );
    state = false; // Sembunyikan loading

    result.fold(
      (failure) => showSnackBar(context, failure.message, isError: true),
      (userModel) {
        // --- PERUBAHAN ---
        // 1. Invalidate provider agar GoRouter tahu state berubah.
        _ref.invalidate(authStateChangesProvider);
        _ref.invalidate(userProvider);
        // 2. Beri feedback ke pengguna.
        showSnackBar(context, 'Selamat datang kembali, ${userModel.name}!');
        // 3. TIDAK ADA NAVIGASI. Biarkan GoRouter redirect yang bekerja.
      },
    );
  }

  /// Method logout yang bersih.
  void logout(BuildContext context) async {
    final result = await _authRepository.logout();
    result.fold(
      (failure) => showSnackBar(context, failure.message, isError: true),
      (r) {
        // --- PERUBAHAN ---
        // 1. Invalidate provider agar GoRouter tahu state berubah.
        _ref.invalidate(authStateChangesProvider);
        _ref.invalidate(userProvider);
        // 2. Navigasi ke halaman login akan ditangani sepenuhnya oleh GoRouter redirect.
      },
    );
  }
}