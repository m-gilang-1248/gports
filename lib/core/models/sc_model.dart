// lib/core/models/sc_model.dart

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

// Enum SCStatus tidak berubah
enum SCStatus {
  pendingApproval,
  active,
  inactive,
  suspended,
  unknown,
}

class SCModel extends Equatable {
  final String id;
  final String name;
  final String address;
  final String city;
  final String? contactPhone;
  final String? contactEmail;
  final String? description;
  final TimeOfDay openTime;
  final TimeOfDay closeTime;
  final String? mainPhotoUrl;
  final List<String> additionalPhotosUrls;
  final List<String> facilities;
  final SCStatus status;
  
  // [TAMBAHAN PENTING] Tambahkan properti teamId jika belum ada
  // Ini diperlukan untuk logika izin file.
  final String? scAdminTeamId; 

  const SCModel({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    this.contactPhone,
    this.contactEmail,
    this.description,
    required this.openTime,
    required this.closeTime,
    this.mainPhotoUrl,
    required this.additionalPhotosUrls,
    required this.facilities,
    required this.status,
    this.scAdminTeamId, // Tambahkan di constructor
  });

  // --- [BARU] Tambahkan metode copyWith di sini ---
  SCModel copyWith({
    String? id,
    String? name,
    String? address,
    String? city,
    String? contactPhone,
    String? contactEmail,
    String? description,
    TimeOfDay? openTime,
    TimeOfDay? closeTime,
    String? mainPhotoUrl,
    List<String>? additionalPhotosUrls,
    List<String>? facilities,
    SCStatus? status,
    String? scAdminTeamId,
  }) {
    return SCModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      contactPhone: contactPhone ?? this.contactPhone,
      contactEmail: contactEmail ?? this.contactEmail,
      description: description ?? this.description,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      mainPhotoUrl: mainPhotoUrl ?? this.mainPhotoUrl,
      additionalPhotosUrls: additionalPhotosUrls ?? this.additionalPhotosUrls,
      facilities: facilities ?? this.facilities,
      status: status ?? this.status,
      scAdminTeamId: scAdminTeamId ?? this.scAdminTeamId,
    );
  }


  factory SCModel.fromJson(Map<String, dynamic> json) {
    TimeOfDay parseTime(String timeStr) {
      try {
        final parts = timeStr.split(':');
        return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      } catch (e) {
        return const TimeOfDay(hour: 0, minute: 0);
      }
    }

    return SCModel(
      id: json['\$id'] as String,
      name: json['sc_name'] as String,
      address: json['sc_address'] as String,
      city: json['sc_city'] as String,
      contactPhone: json['sc_contact_phone'] as String?,
      contactEmail: json['sc_contact_email'] as String?,
      description: json['sc_description'] as String?,
      openTime: parseTime(json['sc_operating_hours_open'] as String),
      closeTime: parseTime(json['sc_operating_hours_close'] as String),
      mainPhotoUrl: json['sc_main_photo_url'] as String?,
      additionalPhotosUrls: List<String>.from(json['sc_additional_photos_urls'] ?? []),
      facilities: List<String>.from(json['sc_facilities'] ?? []),
      status: _mapStringToSCStatus(json['sc_status'] as String),
      scAdminTeamId: json['sc_admin_team_id'] as String?, // Baca dari JSON
    );
  }
  
  Map<String, dynamic> toJson() {
    String formatTime(TimeOfDay time) {
      final hour = time.hour.toString().padLeft(2, '0');
      final minute = time.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }

    return {
      'sc_name': name,
      'sc_address': address,
      'sc_city': city,
      'sc_contact_phone': contactPhone,
      'sc_contact_email': contactEmail,
      'sc_description': description,
      'sc_operating_hours_open': formatTime(openTime),
      'sc_operating_hours_close': formatTime(closeTime),
      'sc_main_photo_url': mainPhotoUrl,
      'sc_additional_photos_urls': additionalPhotosUrls,
      'sc_facilities': facilities,
      'sc_status': status.name,
      'sc_admin_team_id': scAdminTeamId, // Kirim ke JSON
    };
  }
  
  static SCStatus _mapStringToSCStatus(String status) {
    return SCStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == status.toLowerCase(),
      orElse: () => SCStatus.unknown,
    );
  }

  @override
  List<Object?> get props => [
    id, name, address, city, contactPhone, contactEmail, description,
    openTime, closeTime, mainPhotoUrl, additionalPhotosUrls, facilities, status,
    scAdminTeamId, // Tambahkan ke props
  ];
}