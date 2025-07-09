// lib/features/6_sc_admin/view/schedule/widgets/block_slot_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gsports/core/models/blocked_slot_model.dart';
import 'package:gsports/core/models/field_model.dart';
import 'package:gsports/core/providers/user_data_provider.dart';
import 'package:gsports/features/6_sc_admin/controller/sc_admin_action_controller.dart';
import 'package:gsports/shared_widgets/custom_button.dart';
import 'package:gsports/shared_widgets/custom_textfield.dart';
import 'package:gsports/features/0_auth/controller/auth_controller.dart';

class BlockSlotDialog extends ConsumerStatefulWidget {
  final FieldModel field;
  final DateTime date;
  final TimeOfDay time;

  const BlockSlotDialog({
    super.key,
    required this.field,
    required this.date,
    required this.time,
  });

  @override
  ConsumerState<BlockSlotDialog> createState() => _BlockSlotDialogState();
}

class _BlockSlotDialogState extends ConsumerState<BlockSlotDialog> {
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _onSave() {
    final admin = ref.read(userProvider).value!;
    final startTime = widget.time;
    // Untuk MVP, durasi blokir selalu 1 jam.
    final endTime = startTime.replacing(hour: startTime.hour + 1);

    final newBlockedSlot = BlockedSlotModel(
      id: '', centerId: widget.field.centerId, fieldId: widget.field.id,
      blockDate: widget.date,
      startTime: '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
      endTime: '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
      reason: _reasonController.text,
      blockedByUserId: admin.uid,
      createdAt: DateTime.now(),
    );

    ref.read(scAdminActionControllerProvider.notifier).createBlockedSlot(
      context: context,
      blockedSlot: newBlockedSlot,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(scAdminActionControllerProvider);
    return AlertDialog(
      title: const Text('Blokir Slot Waktu'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Blokir lapangan ${widget.field.name} pada jam ${widget.time.format(context)}?'),
            const SizedBox(height: 16),
            CustomTextField(controller: _reasonController, hintText: 'Alasan (Opsional)'),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Batal')),
        CustomButton(text: 'Blokir', isLoading: isLoading, onPressed: _onSave, backgroundColor: Colors.orange),
      ],
    );
  }
}