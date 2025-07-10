// lib/features/6_sc_admin/view/fields/sc_admin_field_edit_screen.dart

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // <-- [BARU]
import 'package:image_picker/image_picker.dart';

import 'package:gsports/config/router/route_names.dart'; // <-- [BARU]
import 'package:gsports/core/models/field_model.dart';
import 'package:gsports/core/providers/user_data_provider.dart';
import 'package:gsports/core/utils/snackbar.dart';
import 'package:gsports/core/utils/validator.dart';
import 'package:gsports/features/0_auth/controller/auth_controller.dart';
import 'package:gsports/features/6_sc_admin/controller/sc_admin_fields_controller.dart';
import 'package:gsports/shared_widgets/custom_button.dart';
import 'package:gsports/shared_widgets/custom_textfield.dart';

class SCAdminFieldEditScreen extends ConsumerStatefulWidget {
  final FieldModel? field;

  const SCAdminFieldEditScreen({super.key, this.field});

  @override
  ConsumerState<SCAdminFieldEditScreen> createState() =>
      _SCAdminFieldEditScreenState();
}

class _SCAdminFieldEditScreenState extends ConsumerState<SCAdminFieldEditScreen> {
  // ... (semua properti state tidak berubah)
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _sportTypeController;
  late TextEditingController _priceController;
  late bool _isActive;
  late List<String> _photoUrls;
  bool _isUploading = false;
  
  // ... (initState dan dispose tidak berubah)
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.field?.name ?? '');
    _sportTypeController =
        TextEditingController(text: widget.field?.sportType ?? '');
    _priceController =
        TextEditingController(text: widget.field?.pricePerHour.toString() ?? '');
    _isActive = widget.field?.isActive ?? true;
    _photoUrls = List<String>.from(widget.field?.photosUrls ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sportTypeController.dispose();
    _priceController.dispose();
    super.dispose();
  }
  
  // ... (method _pickAndUploadImage dan _onSave tidak berubah)
  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() => _isUploading = true);
      final imageFile = File(pickedFile.path);
      final imageUrl = await ref
          .read(scAdminFieldsControllerProvider.notifier)
          .uploadFieldImage(context: context, image: imageFile);

      if (imageUrl != null) {
        setState(() {
          _photoUrls.add(imageUrl);
        });
      }
      setState(() => _isUploading = false);
    }
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      final user = ref.read(userProvider).value;
      if (user == null || user.assignedCenterId == null) return;

      final fieldData = FieldModel(
        id: widget.field?.id ?? '',
        centerId: user.assignedCenterId!,
        name: _nameController.text.trim(),
        sportType: _sportTypeController.text.trim(),
        pricePerHour: double.tryParse(_priceController.text) ?? 0,
        isActive: _isActive,
        photosUrls: _photoUrls,
      );

      final controller = ref.read(scAdminFieldsControllerProvider.notifier);
      if (widget.field != null) {
        controller.updateField(context: context, field: fieldData);
      } else {
        controller.createField(context: context, field: fieldData);
      }
    }
  }

  // --- [BARU] Method untuk menampilkan dialog konfirmasi dan menghapus lapangan ---
  void _onDelete() {
    // Pastikan kita dalam mode edit
    if (widget.field == null) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Lapangan?'),
        content: Text('Anda yakin ingin menghapus "${widget.field!.name}" secara permanen? Aksi ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              // Tutup dialog, lalu panggil controller untuk menghapus.
              Navigator.of(dialogContext).pop();
              ref.read(scAdminFieldsControllerProvider.notifier).deleteField(
                context: context,
                field: widget.field!,
              );
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(scAdminFieldsControllerProvider);
    final isEditMode = widget.field != null;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Lapangan' : 'Tambah Lapangan Baru'),
        // --- [BARU] Tambahkan tombol hapus di AppBar jika mode edit ---
        actions: [
          if (isEditMode)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: isLoading ? null : _onDelete,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ... (semua field form tidak berubah)
              CustomTextField(
                  controller: _nameController,
                  hintText: 'Nama Lapangan',
                  validator: Validator.validateName),
              const SizedBox(height: 16),
              CustomTextField(
                  controller: _sportTypeController,
                  hintText: 'Jenis Olahraga (cth: Futsal)'),
              const SizedBox(height: 16),
              CustomTextField(
                  controller: _priceController,
                  hintText: 'Harga per Jam',
                  keyboardType: TextInputType.number,
                  validator: (val) =>
                      (double.tryParse(val ?? '') == null)
                          ? 'Masukkan angka yang valid'
                          : null),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Status Aktif'),
                subtitle: Text(_isActive
                    ? 'Lapangan akan tampil di pencarian'
                    : 'Lapangan disembunyikan'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
              const Divider(height: 32),
              Text('Foto Lapangan', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              _buildPhotoGrid(), // Anda perlu mengimplementasikan ini dari kode sebelumnya
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: _isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.add_a_photo_outlined),
                label: Text(_isUploading ? 'Mengunggah...' : 'Tambah Foto'),
                onPressed: _isUploading ? null : _pickAndUploadImage,
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

  // ... (method _buildPhotoGrid tidak berubah)
  Widget _buildPhotoGrid() {
    if (_photoUrls.isEmpty) {
      return const Text('Belum ada foto yang ditambahkan.');
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _photoUrls.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final url = _photoUrls[index];
        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: url, fit: BoxFit.cover,
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
            Positioned(
              top: 4, right: 4,
              child: CircleAvatar(
                radius: 14,
                backgroundColor: Colors.black.withOpacity(0.6),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.close, color: Colors.white, size: 14),
                  onPressed: () { /* Hapus foto dari state & storage */ },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}