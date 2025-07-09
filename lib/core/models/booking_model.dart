// lib/core/models/booking_model.dart

import 'package:equatable/equatable.dart';

/// Enum untuk status pemesanan (booking).
enum BookingStatus {
  pendingPayment,
  confirmed,
  cancelledByPlayer,
  cancelledBySc,
  completed,
  paymentRejected,
  waitingForScConfirmation, // Untuk metode bayar di tempat
  unknown,
}

/// Enum untuk peran pembuat booking.
enum BookedByRole {
  player,
  scAdmin,
  unknown,
}

/// `BookingModel` merepresentasikan satu transaksi pemesanan lapangan.
/// Ini mencerminkan struktur dokumen di collection 'bookings'.
class BookingModel extends Equatable {
  final String id;
  final String playerUserId;
  final String centerId;
  final String fieldId;
  final DateTime bookingDate; // Menggunakan DateTime untuk kemudahan manipulasi
  final String startTime; // 'HH:MM'
  final String endTime; // 'HH:MM'
  final double durationHours;
  final double totalPrice;
  final BookingStatus status;
  final String? paymentMethod;
  final String? paymentProofUrl;
  final String? playerNotes;
  final String? scNotes;
  final BookedByRole bookedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BookingModel({
    required this.id,
    required this.playerUserId,
    required this.centerId,
    required this.fieldId,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.durationHours,
    required this.totalPrice,
    required this.status,
    this.paymentMethod,
    this.paymentProofUrl,
    this.playerNotes,
    this.scNotes,
    required this.bookedBy,
    required this.createdAt,
    required this.updatedAt,
  });

   BookingModel copyWith({
    String? id,
    String? playerUserId,
    String? centerId,
    String? fieldId,
    DateTime? bookingDate,
    String? startTime,
    String? endTime,
    double? durationHours,
    double? totalPrice,
    BookingStatus? status,
    String? paymentMethod,
    String? paymentProofUrl,
    String? playerNotes,
    String? scNotes,
    BookedByRole? bookedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      playerUserId: playerUserId ?? this.playerUserId,
      centerId: centerId ?? this.centerId,
      fieldId: fieldId ?? this.fieldId,
      bookingDate: bookingDate ?? this.bookingDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationHours: durationHours ?? this.durationHours,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentProofUrl: paymentProofUrl ?? this.paymentProofUrl,
      playerNotes: playerNotes ?? this.playerNotes,
      scNotes: scNotes ?? this.scNotes,
      bookedBy: bookedBy ?? this.bookedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Factory constructor untuk membuat instance `BookingModel` dari Map (JSON).
  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['\$id'] as String,
      playerUserId: json['player_user_id'] as String,
      centerId: json['center_id'] as String,
      fieldId: json['field_id'] as String,
      // Konversi string 'YYYY-MM-DD' menjadi DateTime
      bookingDate: DateTime.parse(json['booking_date'] as String),
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      durationHours: (json['duration_hours'] as num).toDouble(),
      totalPrice: (json['total_price'] as num).toDouble(),
      status: _mapStringToBookingStatus(json['booking_status'] as String),
      paymentMethod: json['payment_method'] as String?,
      paymentProofUrl: json['payment_proof_url'] as String?,
      playerNotes: json['player_notes'] as String?,
      scNotes: json['sc_notes'] as String?,
      bookedBy: _mapStringToBookedByRole(json['booked_by_role'] as String),
      // Konversi string timestamp ISO 8601 dari Appwrite menjadi DateTime
      createdAt: DateTime.parse(json['\$createdAt'] as String),
      updatedAt: DateTime.parse(json['\$updatedAt'] as String),
    );
  }

  /// Konversi ke Map untuk dikirim ke Appwrite.
  Map<String, dynamic> toJson() {
    return {
      'player_user_id': playerUserId,
      'center_id': centerId,
      'field_id': fieldId,
      // Konversi DateTime menjadi string format 'YYYY-MM-DD'
      'booking_date': '${bookingDate.year}-${bookingDate.month.toString().padLeft(2, '0')}-${bookingDate.day.toString().padLeft(2, '0')}',
      'start_time': startTime,
      'end_time': endTime,
      'duration_hours': durationHours,
      'total_price': totalPrice,
      'booking_status': status.name,
      'payment_method': paymentMethod,
      'payment_proof_url': paymentProofUrl,
      'player_notes': playerNotes,
      'sc_notes': scNotes,
      'booked_by_role': bookedBy.name,
    };
  }

  // Helper mappers
  static BookingStatus _mapStringToBookingStatus(String status) {
    return BookingStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == status.toLowerCase(),
      orElse: () => BookingStatus.unknown,
    );
  }

  static BookedByRole _mapStringToBookedByRole(String role) {
    return BookedByRole.values.firstWhere(
      (e) => e.name.toLowerCase() == role.toLowerCase(),
      orElse: () => BookedByRole.unknown,
    );
  }

  @override
  List<Object?> get props => [
    id, playerUserId, centerId, fieldId, bookingDate, startTime, endTime,
    durationHours, totalPrice, status, paymentMethod, paymentProofUrl,
    playerNotes, scNotes, bookedBy, createdAt, updatedAt,
  ];
}