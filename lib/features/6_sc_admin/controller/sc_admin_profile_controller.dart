// lib/features/6_sc_admin/controller/sc_admin_profile_controller.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gsports/core/models/sc_model.dart';
import 'package:gsports/core/utils/snackbar.dart';
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
        super(false); // state is isLoading

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
        // Invalidate provider detail agar data di dashboard atau halaman lain refresh
        _ref.invalidate(scDetailsDataProvider(updatedSC.id));
        showSnackBar(context, 'Profil Sports Center berhasil diperbarui!');
        context.pop(); // Kembali ke halaman sebelumnya
      },
    );
  }
}