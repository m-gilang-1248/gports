// lib/features/6_sc_admin/view/fields/sc_admin_field_edit_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gsports/core/models/field_model.dart';
import 'package:gsports/core/providers/user_data_provider.dart';
import 'package:gsports/core/utils/validator.dart';
import 'package:gsports/features/6_sc_admin/controller/sc_admin_fields_controller.dart';
import 'package:gsports/shared_widgets/custom_button.dart';
import 'package:gsports/shared_widgets/custom_textfield.dart';
import 'package:gsports/features/0_auth/controller/auth_controller.dart';

class SCAdminFieldEditScreen extends ConsumerStatefulWidget {
  // Menerima FieldModel (opsional). Jika null, berarti mode 'Tambah'.
  // Jika ada isinya, berarti mode 'Edit'.
  final FieldModel? field;

  const SCAdminFieldEditScreen({super.key, this.field});

  @override
  ConsumerState<SCAdminFieldEditScreen> createState() => _SCAdminFieldEditScreenState();
}

class _SCAdminFieldEditScreenState extends ConsumerState<SCAdminFieldEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _sportTypeController;
  late TextEditingController _priceController;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    // Mengisi form dengan data yang ada jika dalam mode edit
    _nameController = TextEditingController(text: widget.field?.name ?? '');
    _sportTypeController = TextEditingController(text: widget.field?.sportType ?? '');
    _priceController = TextEditingController(text: widget.field?.pricePerHour.toString() ?? '');
    _isActive = widget.field?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sportTypeController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      final user = ref.read(userProvider).value;
      if (user == null || user.assignedCenterId == null) return;

      final fieldData = FieldModel(
        // Jika mode edit, gunakan ID yang ada. Jika mode tambah, ID tidak penting
        // karena akan di-generate oleh repository/Appwrite.
        id: widget.field?.id ?? '',
        centerId: user.assignedCenterId!,
        name: _nameController.text,
        sportType: _sportTypeController.text,
        pricePerHour: double.tryParse(_priceController.text) ?? 0,
        isActive: _isActive,
        photosUrls: widget.field?.photosUrls ?? [], // Ambil foto lama jika ada
      );

      final controller = ref.read(scAdminFieldsControllerProvider.notifier);
      if (widget.field != null) {
        // Mode Edit
        controller.updateField(context: context, field: fieldData);
      } else {
        // Mode Tambah
        controller.createField(context: context, field: fieldData);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(scAdminFieldsControllerProvider);
    final isEditMode = widget.field != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Lapangan' : 'Tambah Lapangan Baru'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(controller: _nameController, hintText: 'Nama Lapangan', validator: Validator.validateName),
              const SizedBox(height: 16),
              // TODO: Ganti dengan DropdownButtonFormField untuk pilihan olahraga
              CustomTextField(controller: _sportTypeController, hintText: 'Jenis Olahraga (cth: Futsal)'),
              const SizedBox(height: 16),
              CustomTextField(controller: _priceController, hintText: 'Harga per Jam', keyboardType: TextInputType.number, validator: (val) => (double.tryParse(val ?? '') == null) ? 'Masukkan angka yang valid' : null),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Status Aktif'),
                subtitle: Text(_isActive ? 'Lapangan akan tampil di pencarian' : 'Lapangan disembunyikan'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Simpan Lapangan',
                isLoading: isLoading,
                onPressed: _onSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}