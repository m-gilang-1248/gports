// lib/core/models/field_model.dart

import 'package:equatable/equatable.dart';

/// `FieldModel` merepresentasikan satu entitas lapangan olahraga.
/// Ini mencerminkan struktur dokumen di collection 'fields'.
class FieldModel extends Equatable {
  final String id;
  final String centerId; // FK ke SCModel
  final String name;
  final String sportType;
  final String? fieldType; // e.g., 'indoor', 'outdoor'
  final String? floorType;
  final double pricePerHour;
  final String? description;
  final List<String> photosUrls;
  final bool isActive;

  const FieldModel({
    required this.id,
    required this.centerId,
    required this.name,
    required this.sportType,
    this.fieldType,
    this.floorType,
    required this.pricePerHour,
    this.description,
    required this.photosUrls,
    required this.isActive,
  });

  /// Factory constructor untuk membuat instance `FieldModel` dari Map.
  factory FieldModel.fromJson(Map<String, dynamic> json) {
    return FieldModel(
      id: json['\$id'] as String,
      centerId: json['center_id'] as String,
      name: json['field_name'] as String,
      sportType: json['sport_type'] as String,
      fieldType: json['field_type'] as String?,
      floorType: json['floor_type'] as String?,
      // Pastikan konversi dari num (int/double) ke double
      pricePerHour: (json['price_per_hour'] as num).toDouble(),
      description: json['field_description'] as String?,
      photosUrls: List<String>.from(json['field_photos_urls'] ?? []),
      isActive: json['is_active'] as bool,
    );
  }
  
  /// Konversi ke Map untuk dikirim ke Appwrite.
  Map<String, dynamic> toJson() {
    return {
      'center_id': centerId,
      'field_name': name,
      'sport_type': sportType,
      'field_type': fieldType,
      'floor_type': floorType,
      'price_per_hour': pricePerHour,
      'field_description': description,
      'field_photos_urls': photosUrls,
      'is_active': isActive,
    };
  }

  @override
  List<Object?> get props => [
    id, centerId, name, sportType, fieldType, floorType,
    pricePerHour, description, photosUrls, isActive,
  ];
}