// lib/features/5_profile/controller/profile_controller.dart

import 'dart:io'; // <-- [BARU] Impor untuk kelas File

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
        super(false); // state adalah isLoading

  // ... (method updateUserProfile tidak berubah secara fungsional)
  void updateUserProfile({
    required BuildContext context,
    required String name,
    required String? phone,
  }) async {
    state = true;
    // Logika untuk update telepon yang memerlukan password akan ditangani di UI (menampilkan dialog)
    // atau di-skip jika password tidak disediakan, tergantung pada UX yang diinginkan.
    final result = await _authRepository.updateUserProfile(name: name, phone: phone);
    state = false;

    result.fold(
      (l) => showSnackBar(context, l.message, isError: true),
      (user) {
        _ref.invalidate(userProvider);
        showSnackBar(context, 'Profil berhasil diperbarui!');
        context.pop();
      },
    );
  }

  // --- [BARU] Method untuk mengelola alur upload foto profil ---
  /// Mengelola seluruh alur perubahan foto profil: upload file,
  /// kemudian simpan URL ke preferensi pengguna.
  Future<void> updateProfilePicture({
    required BuildContext context,
    required File image,
  }) async {
    state = true; // Set loading state

    // 1. Dapatkan ID pengguna saat ini.
    final user = _ref.read(userProvider).value;
    if (user == null) {
      showSnackBar(context, 'Gagal mendapatkan data pengguna.', isError: true);
      state = false;
      return;
    }

    // 2. Panggil repository untuk mengunggah file.
    final uploadResult = await _authRepository.uploadProfilePicture(
      image: image,
      userId: user.uid,
    );

    // 3. Jika upload gagal, hentikan proses dan tampilkan error.
    final imageUrl = uploadResult.fold(
      (failure) {
        showSnackBar(context, failure.message, isError: true);
        return null; // Kembalikan null untuk menandakan kegagalan.
      },
      (url) => url, // Kembalikan URL jika berhasil.
    );

    if (imageUrl == null) {
      state = false;
      return; // Hentikan jika upload gagal.
    }

    // 4. Jika upload berhasil, simpan URL baru ke preferensi pengguna.
    final saveResult = await _authRepository.saveProfilePictureUrl(photoUrl: imageUrl);

    state = false; // Matikan loading state setelah semua proses selesai.

    saveResult.fold(
      (failure) => showSnackBar(context, failure.message, isError: true),
      (r) {
        // 5. Jika semua berhasil, invalidate userProvider dan beri feedback.
        _ref.invalidate(userProvider);
        showSnackBar(context, 'Foto profil berhasil diperbarui!');
      },
    );
  }
}