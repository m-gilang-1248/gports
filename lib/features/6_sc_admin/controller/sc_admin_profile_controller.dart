// lib/features/6_sc_admin/controller/sc_admin_profile_controller.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gsports/core/models/sc_model.dart';
import 'package:gsports/core/models/user_model.dart';
import 'package:gsports/core/providers/user_data_provider.dart';
import 'package:gsports/core/utils/snackbar.dart';
import 'package:gsports/features/0_auth/controller/auth_controller.dart';
import 'package:gsports/features/3_sc_details/controller/sc_details_controller.dart';
import 'package:gsports/features/6_sc_admin/repository/sc_admin_repository.dart';

final scAdminProfileControllerProvider =
    StateNotifierProvider.autoDispose<SCAdminProfileController, bool>((ref) {
  return SCAdminProfileController(
    scAdminRepository: ref.watch(scAdminRepositoryProvider),
    ref: ref,
  );
});

class SCAdminProfileController extends StateNotifier<bool> {
  final SCAdminRepository _scAdminRepository;
  final Ref _ref;

  SCAdminProfileController({
    required SCAdminRepository scAdminRepository,
    required Ref ref,
  })  : _scAdminRepository = scAdminRepository,
        _ref = ref,
        super(false); // state adalah isLoading untuk aksi utama (simpan profil)

  void updateSCProfile({
    required BuildContext context,
    required SCModel updatedSC,
  }) async {
    state = true;
    final result = await _scAdminRepository.updateSCProfile(sc: updatedSC);
    state = false;

    result.fold(
      (l) => showSnackBar(context, l.message, isError: true),
      (r) {
        _ref.invalidate(scDetailsDataProvider(updatedSC.id));
        showSnackBar(context, 'Profil Sports Center berhasil diperbarui!');
        context.pop();
      },
    );
  }

  Future<String?> uploadSCImage({
    required BuildContext context,
    required File image,
  }) async {
    final user = _ref.read(userProvider).value;
    if (user == null || user.assignedCenterId == null) {
      showSnackBar(context, 'Gagal mendapatkan data admin.', isError: true);
      return null;
    }
    
    // Asumsi kita perlu teamId. Cara mendapatkannya harus dipastikan.
    // Untuk contoh ini, kita asumsikan teamId bisa didapat dari suatu tempat.
    // Placeholder:
    final scData = await _ref.read(scDetailsDataProvider(user.assignedCenterId!).future);
    final teamId = scData.scDetails.id; // GANTI INI dengan `sc.sc_admin_team_id` yang sebenarnya.

    if (teamId == null) {
      showSnackBar(context, 'Gagal mendapatkan konfigurasi tim SC.', isError: true);
      return null;
    }

    final result = await _scAdminRepository.uploadSCImage(
      image: image,
      teamId: teamId,
    );
    
    return result.fold(
      (failure) {
        showSnackBar(context, failure.message, isError: true);
        return null;
      },
      (imageUrl) {
        showSnackBar(context, 'Foto berhasil diunggah!');
        return imageUrl;
      },
    );
  }

  // --- [DIEDIT] Method untuk hapus foto ---
  /// Mengelola proses hapus foto dan mengembalikan true jika berhasil.
  /// Tidak lagi mengatur state loading global dari notifier ini.
  Future<bool> deleteFile({
    required BuildContext context,
    required String fileId,
  }) async {
    // Panggil repository untuk menghapus file.
    final result = await _scAdminRepository.deleteFile(fileId: fileId);

    // Kembalikan hasilnya ke UI.
    return result.fold(
      (failure) {
        showSnackBar(context, failure.message, isError: true);
        return false; // Gagal
      },
      (r) {
        showSnackBar(context, 'Foto berhasil dihapus.');
        return true; // Sukses
      },
    );
  }
}