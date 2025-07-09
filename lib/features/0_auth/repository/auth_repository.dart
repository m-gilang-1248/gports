// lib/features/0_auth/repository/auth_repository.dart

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as appwrite_models;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import 'package:gsports/core/failure.dart';
import 'package:gsports/core/models/user_model.dart';
import 'package:gsports/core/providers/appwrite_providers.dart';
import 'package:gsports/core/type_defs.dart';
import 'package:gsports/core/utils/logger.dart';

// --- 1. Provider untuk AuthRepository ---
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final account = ref.watch(appwriteAccountProvider);
  return AuthRepository(account: account);
});

// --- 2. Kelas AuthRepository ---
class AuthRepository {
  final Account _account;

  AuthRepository({required Account account}) : _account = account;

  Future<appwrite_models.User?> getCurrentUserAccount() async {
    try {
      return await _account.get();
    } on AppwriteException {
      return null;
    } catch (e) {
      return null;
    }
  }

  // -- METHOD SIGNUP YANG DIPERBAIKI --
  FutureEitherVoid signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Langkah 1: Buat akun pengguna dengan data inti.
      // Parameter `preferences` sudah tidak ada di method ini.
      final user = await _account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );

      // Langkah 2 (Opsional tapi sangat dianjurkan): Langsung login setelah registrasi
      // agar kita bisa langsung memperbarui preferences.
      await _account.createEmailPasswordSession(
        email: email,
        password: password,
      );

      // Langkah 3: Perbarui preferences untuk pengguna yang baru dibuat.
      // Gunakan method `updatePrefs()`.
      await _account.updatePrefs(
        prefs: {
          'role': 'player',
          // kita bisa menambahkan data pref lain di sini jika perlu
        },
      );
      
      logger.i("User ${user.name} created successfully with role 'player'");
      return right(null);
      
    } on AppwriteException catch (e, st) {
      logger.e("AppwriteException during signUp: ${e.message}", stackTrace: st);
      return left(Failure(message: e.message ?? 'Sign up failed.', stackTrace: st));
    } catch (e, st) {
      logger.e("Unexpected error during signUp: $e", stackTrace: st);
      return left(Failure(message: e.toString(), stackTrace: st));
    }
  }

  FutureEither<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      await _account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      final user = await _account.get();
      final userModel = UserModel.fromAppwriteUser(user);
      return right(userModel);
    } on AppwriteException catch (e, st) {
      logger.e("AppwriteException during login: ${e.message}", stackTrace: st);
      return left(Failure(message: e.message ?? 'Login failed.', stackTrace: st));
    } catch (e, st) {
      logger.e("Unexpected error during login: $e", stackTrace: st);
      return left(Failure(message: e.toString(), stackTrace: st));
    }
  }

  FutureEitherVoid logout() async {
    try {
      await _account.deleteSession(sessionId: 'current');
      return right(null);
    } on AppwriteException catch (e, st) {
      logger.e("AppwriteException during logout: ${e.message}", stackTrace: st);
      return left(Failure(message: e.message ?? 'Logout failed.', stackTrace: st));
    } catch (e, st) {
      logger.e("Unexpected error during logout: $e", stackTrace: st);
      return left(Failure(message: e.toString(), stackTrace: st));
    }
  }
  /// Mengupdate data profil pengguna (nama dan telepon).
  FutureEither<UserModel> updateUserProfile({
    required String name,
    required String? phone,
  }) async {
    try {
      // Panggil Appwrite untuk update nama dan telepon.
      // Kita tidak bisa update `prefs` di sini secara langsung.
      final user = await _account.updateName(name: name);
      // Panggilan update telepon terpisah
      if (phone != null) {
        await _account.updatePhone(phone: phone, password: ''); // Password diperlukan
      }
      
      // Kembalikan data user yang sudah diupdate
      return right(UserModel.fromAppwriteUser(user));
    } on AppwriteException catch (e, st) {
      // NOTE: Update phone memerlukan password user saat ini, ini adalah
      // batasan keamanan dari Appwrite. Untuk MVP, kita bisa sederhanakan
      // atau meminta password. Di sini kita asumsikan gagal jika ada error.
      logger.e("AppwriteException during updateUserProfile: ${e.message}", stackTrace: st);
      return left(Failure(message: e.message ?? 'Failed to update profile.', stackTrace: st));
    } catch (e, st) {
      return left(Failure(message: e.toString(), stackTrace: st));
    }
  }
}