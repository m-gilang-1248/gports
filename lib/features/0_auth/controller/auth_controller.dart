// lib/features/0_auth/controller/auth_controller.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:appwrite/models.dart' as appwrite_models; // Diperlukan untuk StreamProvider
import 'package:gsports/config/router/route_names.dart';
import 'package:gsports/core/models/user_model.dart';
import 'package:gsports/core/utils/snackbar.dart';
import 'package:gsports/features/0_auth/repository/auth_repository.dart';

// --- Provider ---

final authControllerProvider =
    StateNotifierProvider.autoDispose<AuthController, bool>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthController(authRepository: authRepository, ref: ref);
});

// Provider ini TIDAK PERLU DIUBAH
final authStateChangesProvider = StreamProvider<appwrite_models.User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  // Kode ini akan menjadi lebih reaktif jika kita menggunakan stream langsung
  // dari Appwrite, tapi untuk sekarang kita akan mengandalkan `ref.invalidate`
  // atau hot-reload untuk memicunya kembali.
  // Untuk membuatnya benar-benar reaktif, kita bisa membuat stream di repository
  // yang 'yield' setiap kali ada perubahan sesi.
  // Namun, untuk alur login/logout, pendekatan saat ini sudah cukup.
  return authRepository.getCurrentUserAccount().asStream();
});

// Provider ini TIDAK PERLU DIUBAH
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

  AuthController({
    required AuthRepository authRepository,
    required Ref ref,
  })  : _authRepository = authRepository,
        _ref = ref,
        super(false);

  /// Method signUp yang sudah diperbaiki
  void signUp({
    required String email,
    required String password,
    required String name,
    required BuildContext context,
  }) async {
    state = true;
    // --- PERBAIKAN: Tipe 'result' sekarang adalah Either<Failure, UserModel> ---
    final result = await _authRepository.signUp(
      email: email,
      password: password,
      name: name,
    );
    state = false;

    result.fold(
      (failure) => showSnackBar(context, failure.message, isError: true),
      (userModel) {
        // Invalidate provider agar GoRouter mendeteksi perubahan state
        _ref.invalidate(authStateChangesProvider);
        _ref.invalidate(userProvider);
        
        showSnackBar(context, 'Selamat datang, ${userModel.name}!');
        
        // Navigasi eksplisit untuk memastikan pengguna langsung pindah halaman
        context.goNamed(RouteNames.home);
      },
    );
  }

  /// Method login yang sudah diperbaiki
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
      (failure) => showSnackBar(context, failure.message, isError: true),
      (userModel) {
        // Invalidate provider untuk memicu GoRouter dan update UI
        _ref.invalidate(authStateChangesProvider);
        _ref.invalidate(userProvider);
        
        // Navigasi diserahkan ke GoRouter redirect.
        // Jika ingin navigasi eksplisit, bisa juga ditambahkan di sini.
        // context.goNamed(userModel.role == UserRole.scAdmin ? RouteNames.adminDashboard : RouteNames.home);
        showSnackBar(context, 'Selamat datang kembali, ${userModel.name}!');
          if (userModel.role == UserRole.scAdmin || userModel.role == UserRole.superAdmin) {
          context.goNamed(RouteNames.adminDashboard);
        } else {
          context.goNamed(RouteNames.home);
        }
      },
    );
  }

  /// Method logout yang sudah diperbaiki
  void logout(BuildContext context) async {
    final result = await _authRepository.logout();
    result.fold(
      (failure) => showSnackBar(context, failure.message, isError: true),
      (r) {
        // Invalidate provider agar GoRouter mendeteksi logout
        _ref.invalidate(authStateChangesProvider);
        _ref.invalidate(userProvider);
        // Navigasi ke login akan ditangani oleh GoRouter redirect
      },
    );
  }
}