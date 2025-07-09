// lib/features/6_sc_admin/view/profile/sc_admin_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gsports/core/models/sc_model.dart';
import 'package:gsports/core/providers/user_data_provider.dart';
import 'package:gsports/features/3_sc_details/controller/sc_details_controller.dart';
import 'package:gsports/features/6_sc_admin/controller/sc_admin_profile_controller.dart';
import 'package:gsports/shared_widgets/custom_button.dart';
import 'package:gsports/shared_widgets/custom_textfield.dart';
import 'package:gsports/shared_widgets/error_display.dart';
import 'package:gsports/shared_widgets/loading_indicator.dart';
import 'package:gsports/features/0_auth/controller/auth_controller.dart';

class SCAdminProfileScreen extends ConsumerWidget {
  const SCAdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider).value;
    if (user == null || user.assignedCenterId == null) {
      return const Scaffold(body: ErrorDisplay(message: 'Data admin tidak valid.'));
    }

    final asyncSC = ref.watch(scDetailsDataProvider(user.assignedCenterId!));

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil Sports Center')),
      body: asyncSC.when(
        loading: () => const LoadingIndicator(),
        error: (e, st) => ErrorDisplay(message: e.toString()),
        data: (data) => _ProfileForm(sc: data.scDetails),
      ),
    );
  }
}

// Memisahkan Form ke dalam StatefulWidget sendiri untuk mengelola state form.
class _ProfileForm extends ConsumerStatefulWidget {
  final SCModel sc;
  const _ProfileForm({required this.sc});

  @override
  ConsumerState<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends ConsumerState<_ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _phoneController;
  late TextEditingController _descriptionController;
  late TimeOfDay _openTime;
  late TimeOfDay _closeTime;

  @override
  void initState() {
    super.initState();
    final sc = widget.sc;
    _nameController = TextEditingController(text: sc.name);
    _addressController = TextEditingController(text: sc.address);
    _cityController = TextEditingController(text: sc.city);
    _phoneController = TextEditingController(text: sc.contactPhone ?? '');
    _descriptionController = TextEditingController(text: sc.description ?? '');
    _openTime = sc.openTime;
    _closeTime = sc.closeTime;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context, bool isOpeningTime) async {
    final initialTime = isOpeningTime ? _openTime : _closeTime;
    final newTime = await showTimePicker(context: context, initialTime: initialTime);
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

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      // Membuat objek SCModel baru dari data form
      final updatedSC = SCModel(
        id: widget.sc.id,
        name: _nameController.text,
        address: _addressController.text,
        city: _cityController.text,
        contactPhone: _phoneController.text,
        description: _descriptionController.text,
        openTime: _openTime,
        closeTime: _closeTime,
        // Properti lain diambil dari data original
        status: widget.sc.status,
        mainPhotoUrl: widget.sc.mainPhotoUrl,
        additionalPhotosUrls: widget.sc.additionalPhotosUrls,
        facilities: widget.sc.facilities,
      );

      ref.read(scAdminProfileControllerProvider.notifier).updateSCProfile(
        context: context,
        updatedSC: updatedSC,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(scAdminProfileControllerProvider);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(controller: _nameController, hintText: 'Nama Sports Center'),
            const SizedBox(height: 16),
            CustomTextField(controller: _addressController, hintText: 'Alamat Lengkap'),
            const SizedBox(height: 16),
            CustomTextField(controller: _cityController, hintText: 'Kota'),
            const SizedBox(height: 16),
            CustomTextField(controller: _phoneController, hintText: 'Nomor Telepon Kontak', keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            CustomTextField(controller: _descriptionController, hintText: 'Deskripsi', maxLines: 5),
            const SizedBox(height: 24),

            // Pemilih Jam Operasional
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectTime(context, true),
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Jam Buka'),
                      child: Text(_openTime.format(context), style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectTime(context, false),
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Jam Tutup'),
                      child: Text(_closeTime.format(context), style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // TODO: Fitur upload foto
            const SizedBox(height: 32),

            CustomButton(text: 'Simpan Perubahan', isLoading: isLoading, onPressed: _onSave),
          ],
        ),
      ),
    );
  }
}