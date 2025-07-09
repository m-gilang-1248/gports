// lib/features/6_sc_admin/view/fields/sc_admin_field_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gsports/config/router/route_names.dart';
import 'package:gsports/core/models/field_model.dart';
import 'package:gsports/core/providers/user_data_provider.dart';
import 'package:gsports/features/6_sc_admin/controller/sc_admin_fields_controller.dart';
import 'package:gsports/shared_widgets/error_display.dart';
import 'package:gsports/shared_widgets/loading_indicator.dart';
import 'package:gsports/features/0_auth/controller/auth_controller.dart';

class SCAdminFieldListScreen extends ConsumerWidget {
  const SCAdminFieldListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider).value;

    if (user == null || user.assignedCenterId == null) {
      return const Scaffold(body: ErrorDisplay(message: 'Data admin tidak ditemukan.'));
    }

    final asyncFields = ref.watch(adminFieldsProvider(user.assignedCenterId!));

    return Scaffold(
      appBar: AppBar(title: const Text('Manajemen Lapangan')),
      body: asyncFields.when(
        loading: () => const LoadingIndicator(),
        error: (e, st) => ErrorDisplay(message: e.toString(), onRetry: () => ref.invalidate(adminFieldsProvider(user.assignedCenterId!))),
        data: (fields) {
          if (fields.isEmpty) {
            return const Center(child: Text('Anda belum memiliki lapangan. Tekan + untuk menambah.'));
          }
          return ListView.builder(
            itemCount: fields.length,
            itemBuilder: (context, index) {
              final field = fields[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  title: Text(field.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(field.sportType),
                  trailing: Text(field.isActive ? 'Aktif' : 'Non-Aktif', style: TextStyle(color: field.isActive ? Colors.green : Colors.red)),
                  onTap: () {
                    // Navigasi ke halaman edit dengan membawa data lapangan
                    context.goNamed(RouteNames.adminFieldEdit, extra: field);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigasi ke halaman edit tanpa membawa data (mode tambah)
          context.goNamed(RouteNames.adminFieldEdit);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}