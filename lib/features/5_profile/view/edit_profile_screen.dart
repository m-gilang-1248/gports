// lib/features/5_profile/view/edit_profile_screen.dart

import 'dart:io'; // <-- [BARU]

import 'package:cached_network_image/cached_network_image.dart'; // <-- [BARU]
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart'; // <-- [BARU]

import 'package:gsports/core/models/user_model.dart';
import 'package:gsports/core/utils/validator.dart';
import 'package:gsports/features/5_profile/controller/profile_controller.dart';
import 'package:gsports/shared_widgets/custom_button.dart';
import 'package:gsports/shared_widgets/custom_textfield.dart';
import 'package:gsports/features/0_auth/controller/auth_controller.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final UserModel user;
  const EditProfileScreen({super.key, required this.user});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  // --- [BARU] State untuk upload foto ---
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _phoneController = TextEditingController(text: widget.user.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // --- [BARU] Fungsi untuk memilih dan mengunggah foto profil ---
  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() => _isUploadingPhoto = true);
      final imageFile = File(pickedFile.path);

      await ref
          .read(profileControllerProvider.notifier)
          .updateProfilePicture(context: context, image: imageFile);
      
      // Tidak perlu pop karena kita tetap di halaman ini.
      // Invalidate provider sudah ditangani di controller.

      setState(() => _isUploadingPhoto = false);
    }
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      ref.read(profileControllerProvider.notifier).updateUserProfile(
            context: context,
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim().isNotEmpty
                ? _phoneController.text.trim()
                : null,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    // isLoading adalah untuk aksi simpan, _isUploadingPhoto untuk upload
    final isLoading = ref.watch(profileControllerProvider);
    // Kita juga perlu me-watch userProvider agar foto profil di layar ini
    // ikut ter-update secara real-time setelah diubah.
    final currentUser = ref.watch(userProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- [BARU] UI untuk foto profil ---
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: (currentUser?.photoUrl != null)
                          ? CachedNetworkImageProvider(currentUser!.photoUrl!)
                          : null,
                      child: (currentUser?.photoUrl == null)
                          ? const Icon(Icons.person, size: 60)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        child: IconButton(
                          icon: _isUploadingPhoto
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.edit,
                                  color: Colors.white, size: 20),
                          onPressed: _isUploadingPhoto ? null : _pickAndUploadImage,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              CustomTextField(
                  controller: _nameController,
                  hintText: 'Nama Lengkap',
                  validator: Validator.validateName),
              const SizedBox(height: 16),
              CustomTextField(
                  controller: _phoneController,
                  hintText: 'Nomor Telepon (Opsional)',
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 32),
              CustomButton(
                  text: 'Simpan Perubahan',
                  isLoading: isLoading,
                  onPressed: _onSave),
            ],
          ),
        ),
      ),
    );
  }
}