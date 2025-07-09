// lib/features/6_sc_admin/view/schedule/widgets/add_manual_booking_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gsports/core/models/booking_model.dart';
import 'package:gsports/core/models/field_model.dart';
import 'package:gsports/core/providers/user_data_provider.dart';
import 'package:gsports/features/6_sc_admin/controller/sc_admin_action_controller.dart';
import 'package:gsports/shared_widgets/custom_button.dart';
import 'package:gsports/shared_widgets/custom_textfield.dart';
import 'package:gsports/features/0_auth/controller/auth_controller.dart';

class AddManualBookingDialog extends ConsumerStatefulWidget {
  final FieldModel field;
  final DateTime date;
  final TimeOfDay time;

  const AddManualBookingDialog({
    super.key,
    required this.field,
    required this.date,
    required this.time,
  });

  @override
  ConsumerState<AddManualBookingDialog> createState() => _AddManualBookingDialogState();
}

class _AddManualBookingDialogState extends ConsumerState<AddManualBookingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _customerNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      final admin = ref.read(userProvider).value!;
      final startTime = widget.time;
      final endTime = startTime.replacing(hour: startTime.hour + 1);

      final newBooking = BookingModel(
        id: '', playerUserId: _customerNameController.text, // Simpan nama customer di sini
        centerId: widget.field.centerId, fieldId: widget.field.id,
        bookingDate: widget.date,
        startTime: '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
        endTime: '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
        durationHours: 1.0, totalPrice: widget.field.pricePerHour,
        status: BookingStatus.confirmed, // Booking manual langsung confirmed
        bookedBy: BookedByRole.scAdmin,
        playerNotes: _notesController.text,
        createdAt: DateTime.now(), updatedAt: DateTime.now(),
      );

      ref.read(scAdminActionControllerProvider.notifier).createManualBooking(
        context: context,
        booking: newBooking,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(scAdminActionControllerProvider);
    return AlertDialog(
      title: const Text('Tambah Booking Manual'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Untuk lapangan ${widget.field.name} pada jam ${widget.time.format(context)}'),
              const SizedBox(height: 16),
              CustomTextField(controller: _customerNameController, hintText: 'Nama Pemesan', validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
              const SizedBox(height: 16),
              CustomTextField(controller: _notesController, hintText: 'Catatan (Opsional)'),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Batal')),
        CustomButton(text: 'Simpan', isLoading: isLoading, onPressed: _onSave),
      ],
    );
  }
}