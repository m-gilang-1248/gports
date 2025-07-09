// lib/core/models/user_model.dart

import 'package:appwrite/models.dart' as appwrite_models;
import 'package:equatable/equatable.dart';

/// Enum untuk merepresentasikan peran pengguna secara type-safe.
/// Menggunakan enum lebih aman daripada menggunakan string mentah ("player", "sc_admin").
enum UserRole {
  player,
  pendingScAdmin,
  scAdmin,
  superAdmin,
  unknown,
}

/// Kelas `UserModel` adalah representasi data dari seorang pengguna dalam aplikasi.
/// Ini mencerminkan struktur dokumen di collection 'users' di Appwrite.
///
/// Meng-extend `Equatable` memungkinkan perbandingan objek yang efisien,
/// yang berguna untuk Riverpod agar tidak membangun ulang widget tanpa perlu.
class UserModel extends Equatable {
  /// ID unik pengguna, diambil dari `$id` dokumen Appwrite.
  final String uid;

  /// Nama lengkap pengguna.
  final String name;

  /// Alamat email pengguna, digunakan untuk login.
  final String email;

  /// Nomor telepon pengguna (opsional).
  final String? phone;

  /// Peran pengguna dalam sistem, dikonversi ke enum `UserRole`.
  final UserRole role;

  /// ID dari Sports Center yang dikelola (hanya relevan jika `role` adalah `scAdmin`).
  final String? assignedCenterId;

  /// Status verifikasi email dari Appwrite.
  final bool isEmailVerified;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.assignedCenterId,
    required this.isEmailVerified,
  });

  /// Constructor kosong untuk representasi pengguna yang tidak ada atau
  /// sebagai state awal sebelum data dimuat.
  const UserModel.empty()
      : uid = '',
        name = '',
        email = '',
        phone = null,
        role = UserRole.unknown,
        assignedCenterId = null,
        isEmailVerified = false;

  /// `copyWith` method untuk membuat salinan objek dengan nilai yang diperbarui.
  /// Ini penting untuk state management yang immutable.
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    String? assignedCenterId,
    bool? isEmailVerified,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      assignedCenterId: assignedCenterId ?? this.assignedCenterId,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }

  /// Factory constructor untuk membuat instance `UserModel` dari objek `User`
  /// yang berasal dari Appwrite SDK (`appwrite/models.dart`).
  ///
  /// Ini adalah titik konversi utama dari data mentah Appwrite ke model aplikasi kita.
  factory UserModel.fromAppwriteUser(appwrite_models.User user) {
    // Mengambil peran dari `prefs`. Jika tidak ada, default ke 'player'.
    final roleString = user.prefs.data['role'] ?? 'player';

    return UserModel(
      uid: user.$id,
      name: user.name,
      email: user.email,
      phone: user.phone.isNotEmpty ? user.phone : null,
      isEmailVerified: user.emailVerification,
      // Mengambil `assignedCenterId` dari prefs jika ada.
      assignedCenterId: user.prefs.data['assignedCenterId'],
      // Mengonversi string peran menjadi enum `UserRole`.
      role: _mapStringToUserRole(roleString),
    );
  }

  /// Helper method untuk mengonversi string peran menjadi enum `UserRole`.
  static UserRole _mapStringToUserRole(String roleString) {
    switch (roleString) {
      case 'player':
        return UserRole.player;
      case 'pending_sc_admin':
        return UserRole.pendingScAdmin;
      case 'sc_admin':
        return UserRole.scAdmin;
      case 'super_admin':
        return UserRole.superAdmin;
      default:
        return UserRole.unknown;
    }
  }

  /// `props` dari `Equatable` untuk perbandingan objek.
  @override
  List<Object?> get props {
    return [
      uid,
      name,
      email,
      phone,
      role,
      assignedCenterId,
      isEmailVerified,
    ];
  }

  // NOTE:
  // Method `toJson` tidak selalu diperlukan untuk model ini jika kita tidak
  // secara langsung mengirim seluruh objek untuk diupdate. Seringkali kita hanya
  // mengirim field spesifik (misal: hanya 'name' dan 'phone' saat update profil).
  // Namun, jika diperlukan, implementasinya akan seperti ini:
  /*
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      // Kita tidak biasanya mengupdate uid, email, role, dll dari klien.
    };
  }
  */
}