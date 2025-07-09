// lib/core/models/blocked_slot_model.dart

import 'package:equatable/equatable.dart';

/// `BlockedSlotModel` merepresentasikan satu slot waktu yang diblokir oleh admin.
/// Ini mencerminkan struktur dokumen di collection 'blocked_slots'.
class BlockedSlotModel extends Equatable {
  final String id;
  final String centerId;
  final String fieldId;
  final DateTime blockDate;
  final String startTime; // 'HH:MM'
  final String endTime; // 'HH:MM'
  final String? reason;
  final String blockedByUserId;
  final DateTime createdAt;

  const BlockedSlotModel({
    required this.id,
    required this.centerId,
    required this.fieldId,
    required this.blockDate,
    required this.startTime,
    required this.endTime,
    this.reason,
    required this.blockedByUserId,
    required this.createdAt,
  });

  /// Factory constructor untuk membuat instance `BlockedSlotModel` dari Map (JSON).
  factory BlockedSlotModel.fromJson(Map<String, dynamic> json) {
    return BlockedSlotModel(
      id: json['\$id'] as String,
      centerId: json['center_id'] as String,
      fieldId: json['field_id'] as String,
      blockDate: DateTime.parse(json['block_date'] as String),
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      reason: json['reason'] as String?,
      blockedByUserId: json['blocked_by_user_id'] as String,
      createdAt: DateTime.parse(json['\$createdAt'] as String),
    );
  }

  /// Konversi ke Map untuk dikirim ke Appwrite.
  Map<String, dynamic> toJson() {
    return {
      'center_id': centerId,
      'field_id': fieldId,
      'block_date': '${blockDate.year}-${blockDate.month.toString().padLeft(2, '0')}-${blockDate.day.toString().padLeft(2, '0')}',
      'start_time': startTime,
      'end_time': endTime,
      'reason': reason,
      'blocked_by_user_id': blockedByUserId,
    };
  }
  
  @override
  List<Object?> get props => [
    id, centerId, fieldId, blockDate, startTime, endTime, reason,
    blockedByUserId, createdAt,
  ];
}