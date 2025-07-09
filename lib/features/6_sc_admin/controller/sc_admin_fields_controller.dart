// lib/features/6_sc_admin/controller/sc_admin_fields_controller.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gsports/core/models/field_model.dart';
import 'package:gsports/core/utils/snackbar.dart';
import 'package:gsports/features/6_sc_admin/repository/sc_admin_repository.dart';

// --- Provider untuk daftar lapangan ---
final adminFieldsProvider =
    FutureProvider.autoDispose.family<List<FieldModel>, String>((ref, scId) {
  final repo = ref.watch(scAdminRepositoryProvider);
  return repo.getFieldsForAdmin(scId: scId).then((result) => result.fold(
        (l) => throw l,
        (r) => r,
      ));
});

// --- Provider untuk controller aksi (Create/Update) ---
final scAdminFieldsControllerProvider =
    StateNotifierProvider.autoDispose<SCAdminFieldsController, bool>((ref) {
  return SCAdminFieldsController(
    scAdminRepository: ref.watch(scAdminRepositoryProvider),
    ref: ref,
  );
});

// --- Kelas Controller ---
class SCAdminFieldsController extends StateNotifier<bool> {
  final SCAdminRepository _scAdminRepository;
  final Ref _ref;

  SCAdminFieldsController({
    required SCAdminRepository scAdminRepository,
    required Ref ref,
  })  : _scAdminRepository = scAdminRepository,
        _ref = ref,
        super(false); // state adalah isLoading

  void createField({required BuildContext context, required FieldModel field}) async {
    state = true;
    final result = await _scAdminRepository.createField(field: field);
    state = false;
    result.fold(
      (l) => showSnackBar(context, l.message, isError: true),
      (r) {
        showSnackBar(context, 'Lapangan berhasil ditambahkan!');
        // Invalidate provider agar daftar di halaman sebelumnya diperbarui
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
        _ref.invalidate(adminFieldsProvider(field.centerId));
        context.pop();
      },
    );
  }
}