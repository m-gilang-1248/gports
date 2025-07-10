// lib/features/6_sc_admin/view/profile/sc_admin_profile_screen.dart

// ... (semua impor tetap sama)
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gsports/core/models/sc_model.dart';
import 'package:gsports/core/providers/user_data_provider.dart';
import 'package:gsports/features/0_auth/controller/auth_controller.dart';
import 'package:gsports/features/3_sc_details/controller/sc_details_controller.dart';
import 'package:gsports/features/6_sc_admin/controller/sc_admin_profile_controller.dart';
import 'package:gsports/shared_widgets/custom_button.dart';
import 'package:gsports/shared_widgets/custom_textfield.dart';
import 'package:gsports/shared_widgets/error_display.dart';
import 'package:gsports/shared_widgets/loading_indicator.dart';


// ... (SCAdminProfileScreen tidak berubah)
class SCAdminProfileScreen extends ConsumerWidget {
  const SCAdminProfileScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider).value;
    if (user == null || user.assignedCenterId == null) {
      return const Scaffold(
          body: ErrorDisplay(message: 'Data admin tidak valid.'));
    }
    final asyncSC = ref.watch(scDetailsDataProvider(user.assignedCenterId!));
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil Sports Center')),
      body: asyncSC.when(
        loading: () => const LoadingIndicator(),
        error: (e, st) => ErrorDisplay(
            message: e.toString(),
            onRetry: () =>
                ref.invalidate(scDetailsDataProvider(user.assignedCenterId!))),
        data: (data) => _ProfileForm(sc: data.scDetails),
      ),
    );
  }
}


class _ProfileForm extends ConsumerStatefulWidget {
  final SCModel sc;
  const _ProfileForm({required this.sc});
  @override
  ConsumerState<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends ConsumerState<_ProfileForm> {
  // ... (properti lain tidak berubah)
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _phoneController;
  late TextEditingController _descriptionController;
  late TimeOfDay _openTime;
  late TimeOfDay _closeTime;
  String? _mainPhotoUrl;
  late List<String> _additionalPhotosUrls;
  bool _isUploading = false;

  // --- [BARU] State untuk aksi hapus foto ---
  // Kita gunakan Map untuk melacak loading state per URL.
  final Map<String, bool> _isDeleting = {};


  @override
  void initState() {
    super.initState();
    // ... (initState tidak berubah)
    final sc = widget.sc;
    _nameController = TextEditingController(text: sc.name);
    _addressController = TextEditingController(text: sc.address);
    _cityController = TextEditingController(text: sc.city);
    _phoneController = TextEditingController(text: sc.contactPhone ?? '');
    _descriptionController = TextEditingController(text: sc.description ?? '');
    _openTime = sc.openTime;
    _closeTime = sc.closeTime;
    _mainPhotoUrl = sc.mainPhotoUrl;
    _additionalPhotosUrls = List<String>.from(sc.additionalPhotosUrls);
  }

  @override
  void dispose() {
    // ... (dispose tidak berubah)
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ... (method _selectTime dan _pickAndUploadImage tidak berubah)
  Future<void> _selectTime(BuildContext context, bool isOpeningTime) async {
    final initialTime = isOpeningTime ? _openTime : _closeTime;
    final newTime =
        await showTimePicker(context: context, initialTime: initialTime);
    if (newTime != null) {
      setState(() {
        if (isOpeningTime) {
          _openTime = newTime;
        } else {
          _closeTime = newTime;
        }
      });
    }
  }

  Future<void> _pickAndUploadImage({required bool isMainPhoto}) async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (pickedFile != null) {
      setState(() => _isUploading = true);
      final imageFile = File(pickedFile.path);
      final imageUrl = await ref
          .read(scAdminProfileControllerProvider.notifier)
          .uploadSCImage(context: context, image: imageFile);

      if (imageUrl != null) {
        setState(() {
          if (isMainPhoto) {
            _mainPhotoUrl = imageUrl;
          } else {
            _additionalPhotosUrls.add(imageUrl);
          }
        });
      }
      setState(() => _isUploading = false);
    }
  }

  // --- [BARU] Method untuk menghapus foto ---
  Future<void> _deletePhoto(String url, {bool isMainPhoto = false}) async {
    // Ekstrak fileId dari URL. Ini adalah bagian terakhir dari path.
    final fileId = Uri.parse(url).pathSegments.last;
    
    setState(() => _isDeleting[url] = true);
    
    final success = await ref
        .read(scAdminProfileControllerProvider.notifier)
        .deleteFile(context: context, fileId: fileId);
    
    if (success) {
      setState(() {
        if (isMainPhoto) {
          _mainPhotoUrl = null;
        } else {
          _additionalPhotosUrls.remove(url);
        }
      });
    }
    
    setState(() => _isDeleting.remove(url));
  }


  // ... (method _onSave tidak berubah)
  void _onSave() {
    if (_formKey.currentState!.validate()) {
      final updatedSC = widget.sc.copyWith(
        name: _nameController.text,
        address: _addressController.text,
        city: _cityController.text,
        contactPhone: _phoneController.text,
        description: _descriptionController.text,
        openTime: _openTime,
        closeTime: _closeTime,
        mainPhotoUrl: _mainPhotoUrl,
        additionalPhotosUrls: _additionalPhotosUrls,
      );

      ref
          .read(scAdminProfileControllerProvider.notifier)
          .updateSCProfile(context: context, updatedSC: updatedSC);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... (build method tidak berubah, hanya akan memanggil helper yang diupdate)
    final isLoading = ref.watch(scAdminProfileControllerProvider);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
                controller: _nameController, hintText: 'Nama Sports Center'),
            const SizedBox(height: 16),
            CustomTextField(
                controller: _addressController, hintText: 'Alamat Lengkap'),
            const SizedBox(height: 16),
            CustomTextField(controller: _cityController, hintText: 'Kota'),
            const SizedBox(height: 16),
            CustomTextField(
                controller: _phoneController,
                hintText: 'Nomor Telepon Kontak',
                keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            CustomTextField(
                controller: _descriptionController,
                hintText: 'Deskripsi',
                maxLines: 5),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectTime(context, true),
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Jam Buka'),
                      child: Text(_openTime.format(context),
                          style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectTime(context, false),
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Jam Tutup'),
                      child: Text(_closeTime.format(context),
                          style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 32),

            Text('Foto Utama', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildMainPhoto(),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: _isUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.add_a_photo_outlined),
              label: Text(_isUploading ? 'Mengunggah...' : 'Ganti Foto Utama'),
              onPressed: _isUploading
                  ? null
                  : () => _pickAndUploadImage(isMainPhoto: true),
            ),

            const Divider(height: 32),

            Text('Foto Galeri Tambahan', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildAdditionalPhotosGrid(),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: _isUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.add_photo_alternate_outlined),
              label: Text(_isUploading ? 'Mengunggah...' : 'Tambah Foto Galeri'),
              onPressed: _isUploading
                  ? null
                  : () => _pickAndUploadImage(isMainPhoto: false),
            ),

            const SizedBox(height: 32),
            CustomButton(
                text: 'Simpan Perubahan',
                isLoading: isLoading,
                onPressed: _onSave),
          ],
        ),
      ),
    );
  }

  // --- [DIEDIT] Helper untuk Foto Utama ---
  Widget _buildMainPhoto() {
    if (_mainPhotoUrl == null) {
      return const Text('Belum ada foto utama.');
    }
    final url = _mainPhotoUrl!;
    final isDeleting = _isDeleting[url] ?? false;

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: url, height: 200, width: double.infinity, fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: CircleAvatar(
            backgroundColor: Colors.black.withOpacity(0.6),
            child: isDeleting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.white, size: 20),
                    onPressed: () => _showDeleteConfirmation(url, isMainPhoto: true),
                  ),
          ),
        ),
      ],
    );
  }

  // --- [DIEDIT] Helper untuk Grid Foto Tambahan ---
  Widget _buildAdditionalPhotosGrid() {
    if (_additionalPhotosUrls.isEmpty) {
      return const Text('Belum ada foto tambahan.');
    }
    return GridView.builder(
      // ... (properti grid tidak berubah)
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _additionalPhotosUrls.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final url = _additionalPhotosUrls[index];
        final isDeleting = _isDeleting[url] ?? false;
        
        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(imageUrl: url, fit: BoxFit.cover),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: CircleAvatar(
                radius: 14,
                backgroundColor: Colors.black.withOpacity(0.6),
                child: isDeleting
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.close, color: Colors.white, size: 14),
                        onPressed: () => _showDeleteConfirmation(url),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  // --- [BARU] Helper untuk dialog konfirmasi hapus ---
  void _showDeleteConfirmation(String url, {bool isMainPhoto = false}) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Foto?'),
        content: const Text('Anda yakin ingin menghapus foto ini dari server?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _deletePhoto(url, isMainPhoto: isMainPhoto);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}