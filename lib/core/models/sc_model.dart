// lib/core/models/sc_model.dart

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Enum untuk status Sports Center.
enum SCStatus {
  pendingApproval,
  active,
  inactive,
  suspended,
  unknown,
}

/// `SCModel` merepresentasikan satu entitas Sports Center (tenant).
/// Ini mencerminkan struktur dokumen di collection 'sport_centers'.
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
  });

  /// Factory constructor untuk membuat instance `SCModel` dari Map (data JSON
  /// dari Appwrite). Ini adalah titik konversi utama dari data mentah.
  factory SCModel.fromJson(Map<String, dynamic> json) {
    // Helper function untuk parsing string 'HH:MM' menjadi TimeOfDay
    TimeOfDay parseTime(String timeStr) {
      try {
        final parts = timeStr.split(':');
        return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      } catch (e) {
        // Fallback jika format salah
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
      // Mengonversi List<dynamic> menjadi List<String>
      additionalPhotosUrls: List<String>.from(json['sc_additional_photos_urls'] ?? []),
      facilities: List<String>.from(json['sc_facilities'] ?? []),
      status: _mapStringToSCStatus(json['sc_status'] as String),
    );
  }
  
  /// Konversi ke Map untuk dikirim ke Appwrite.
  /// Berguna saat membuat atau memperbarui dokumen.
  Map<String, dynamic> toJson() {
    // Helper function untuk format TimeOfDay ke 'HH:MM'
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
      'sc_status': status.name, // Menggunakan .name dari enum untuk mendapatkan string
    };
  }
  
  /// Helper untuk map string status ke enum.
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
  ];
}