// lib/features/6_sc_admin/controller/sc_admin_schedule_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gsports/core/models/field_model.dart';

// Provider untuk menyimpan field yang sedang dipilih di dropdown.
// Menggunakan StateProvider karena state-nya sederhana (hanya satu FieldModel atau null).
final selectedAdminFieldProvider = StateProvider<FieldModel?>((ref) => null);