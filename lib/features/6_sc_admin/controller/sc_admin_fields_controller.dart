// lib/features/6_sc_admin/controller/sc_admin_fields_controller.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gsports/config/router/route_names.dart';

import 'package:gsports/core/models/field_model.dart';
import 'package:gsports/core/models/user_model.dart';
import 'package:gsports/core/providers/user_data_provider.dart';
import 'package:gsports/core/utils/snackbar.dart';
import 'package:gsports/features/0_auth/controller/auth_controller.dart';
import 'package:gsports/features/3_sc_details/controller/sc_details_controller.dart';
import 'package:gsports/features/6_sc_admin/repository/sc_admin_repository.dart';

// ... (provider tidak berubah)
final adminFieldsProvider =
    FutureProvider.autoDispose.family<List<FieldModel>, String>((ref, scId) {
  final repo = ref.watch(scAdminRepositoryProvider);
  return repo.getFieldsForAdmin(scId: scId).then((result) => result.fold(
        (l) => throw l,
        (r) => r,
      ));
});

final scAdminFieldsControllerProvider =
    StateNotifierProvider.autoDispose<SCAdminFieldsController, bool>((ref) {
  return SCAdminFieldsController(
    scAdminRepository: ref.watch(scAdminRepositoryProvider),
    ref: ref,
  );
});

class SCAdminFieldsController extends StateNotifier<bool> {
  final SCAdminRepository _scAdminRepository;
  final Ref _ref;

  SCAdminFieldsController({
    required SCAdminRepository scAdminRepository,
    required Ref ref,
  })  : _scAdminRepository = scAdminRepository,
        _ref = ref,
        super(false);

  // ... (method createField dan updateField tidak berubah)
  void createField({required BuildContext context, required FieldModel field}) async {
    state = true;
    final result = await _scAdminRepository.createField(field: field);
    state = false;
    result.fold(
      (l) => showSnackBar(context, l.message, isError: true),
      (r) {
        showSnackBar(context, 'Lapangan berhasil ditambahkan!');
        _ref.invalidate(adminFieldsProvider(field.centerId));
        context.pop();
      },
    );
  }

  void updateField({required BuildContext context, required FieldModel field}) async {
    state = true;
    final result = await _scAdminRepository.updateField(field: field);
    state = false;
    result.fold(
      (l) => showSnackBar(context, l.message, isError: true),
      (r) {
        showSnackBar(context, 'Lapangan berhasil diperbarui!');
        _ref.invalidate(scDetailsDataProvider(field.centerId));
        _ref.invalidate(adminFieldsProvider(field.centerId));
        context.pop();
      },
    );
  }

  void deleteField({required BuildContext context, required FieldModel field}) async {
    state = true;
    // NOTE: Di sini kita asumsikan tidak ada booking yang terkait.
    // Di aplikasi nyata, Anda mungkin perlu memeriksa booking yang ada sebelum menghapus.
    final result = await _scAdminRepository.deleteField(fieldId: field.id);
    state = false;

    result.fold(
      (l) => showSnackBar(context, l.message, isError: true),
      (r) {
        showSnackBar(context, 'Lapangan berhasil dihapus!');
        // Invalidate provider agar daftar lapangan di-refresh
        _ref.invalidate(adminFieldsProvider(field.centerId));
        // Kembali ke halaman daftar lapangan setelah berhasil dihapus
        // `pop` 2x untuk keluar dari dialog konfirmasi dan layar edit.
        // Namun, cara yang lebih aman adalah navigasi langsung.
        context.goNamed(RouteNames.adminFieldList);
      },
    );  
}
  
  // ... (method uploadFieldImage tidak berubah)
  Future<String?> uploadFieldImage({
    required BuildContext context,
    required File image,
  }) async {
    final user = _ref.read(userProvider).value;
    if (user == null || user.assignedCenterId == null) {
      showSnackBar(context, 'Gagal mendapatkan data admin.', isError: true);
      return null;
    }
    
    final scData = await _ref.read(scDetailsDataProvider(user.assignedCenterId!).future);
    final teamId = scData.scDetails.id; // Ganti ini dengan sc.sc_admin_team_id
    
    if (teamId == null) {
       showSnackBar(context, 'Gagal mendapatkan konfigurasi tim SC.', isError: true);
       return null;
    }

    final result = await _scAdminRepository.uploadFieldImage(
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
  Future<void> deleteFieldImage({
    required BuildContext context,
    required String fileId,
  }) async {
    // Panggil metode 'deleteFile' yang sudah diganti namanya di repository.
    final result = await _scAdminRepository.deleteFile(fileId: fileId);
    result.fold(
      (failure) => showSnackBar(context, failure.message, isError: true),
      (r) => showSnackBar(context, 'Foto berhasil dihapus.'),
    );
  }
}