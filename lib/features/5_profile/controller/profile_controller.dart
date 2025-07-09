// lib/features/5_profile/controller/profile_controller.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gsports/core/utils/snackbar.dart';
import 'package:gsports/features/0_auth/controller/auth_controller.dart';
import 'package:gsports/features/0_auth/repository/auth_repository.dart';

final profileControllerProvider =
    StateNotifierProvider.autoDispose<ProfileController, bool>((ref) {
  return ProfileController(
    authRepository: ref.watch(authRepositoryProvider),
    ref: ref,
  );
});

class ProfileController extends StateNotifier<bool> {
  final AuthRepository _authRepository;
  final Ref _ref;

  ProfileController({
    required AuthRepository authRepository,
    required Ref ref,
  })  : _authRepository = authRepository,
        _ref = ref,
        super(false); // state is isLoading

  void updateUserProfile({
    required BuildContext context,
    required String name,
    required String? phone,
  }) async {
    state = true;
    // Untuk update nomor telepon, kita perlu password. Kita sederhanakan dengan mengosongkannya.
    // Ini mungkin akan gagal jika konfigurasi Appwrite memerlukan password.
    // Fokus utama kita adalah update nama.
    final result = await _authRepository.updateUserProfile(name: name, phone: phone);
    state = false;

    result.fold(
      (l) => showSnackBar(context, l.message, isError: true),
      (user) {
        // Invalidate userProvider agar semua bagian UI yang menampilkan
        // data pengguna (seperti AppBar) ikut ter-update.
        _ref.invalidate(userProvider);
        showSnackBar(context, 'Profil berhasil diperbarui!');
        context.pop(); // Kembali ke halaman profil
      },
    );
  }
}