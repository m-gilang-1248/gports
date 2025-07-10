// lib/features/0_auth/repository/auth_repository.dart

import 'dart:io'; // <-- [BARU] Impor untuk kelas File

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as appwrite_models;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import 'package:gsports/core/constants/appwrite_constants.dart';
import 'package:gsports/core/failure.dart';
import 'package:gsports/core/models/user_model.dart';
import 'package:gsports/core/providers/appwrite_providers.dart';
import 'package:gsports/core/type_defs.dart';
import 'package:gsports/core/utils/logger.dart';

// --- 1. Provider untuk AuthRepository ---
// [DIEDIT] Tambahkan dependency `appwriteStorageProvider`
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final account = ref.watch(appwriteAccountProvider);
  final storage = ref.watch(appwriteStorageProvider); // <-- [BARU]
  return AuthRepository(account: account, storage: storage);
});

// --- 2. Kelas AuthRepository ---
class AuthRepository {
  final Account _account;
  final Storage _storage; // <-- [BARU] Tambahkan properti Storage

  AuthRepository({
    required Account account,
    required Storage storage, // <-- [BARU] Tambahkan di constructor
  })  : _account = account,
        _storage = storage;

  // ... (method getCurrentUserAccount tidak berubah)
  Future<appwrite_models.User?> getCurrentUserAccount() async {
    try {
      return await _account.get();
    } on AppwriteException {
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // ... (method signUp, login, logout tidak berubah)
  FutureEither<UserModel> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      await _account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );
      await _account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      await _account.updatePrefs(
        prefs: {'role': 'player'},
      );
      final user = await _account.get();
      return right(UserModel.fromAppwriteUser(user));
    } on AppwriteException catch (e, st) {
      return left(
          Failure(message: e.message ?? 'Sign up failed.', stackTrace: st));
    } catch (e, st) {
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
      return left(
          Failure(message: e.message ?? 'Login failed.', stackTrace: st));
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
      return left(
          Failure(message: e.message ?? 'Logout failed.', stackTrace: st));
    } catch (e, st) {
      logger.e("Unexpected error during logout: $e", stackTrace: st);
      return left(Failure(message: e.toString(), stackTrace: st));
    }
  }

  // ... (method updateUserProfile tidak berubah untuk saat ini)
  FutureEither<UserModel> updateUserProfile({
    required String name,
    required String? phone,
  }) async {
    try {
      final user = await _account.updateName(name: name);
      // Logika update phone bisa ditambahkan di sini jika diperlukan
      return right(UserModel.fromAppwriteUser(user));
    } on AppwriteException catch (e, st) {
      logger.e("AppwriteException during updateUserProfile: ${e.message}",
          stackTrace: st);
      return left(Failure(
          message: e.message ?? 'Failed to update profile.', stackTrace: st));
    } catch (e, st) {
      return left(Failure(message: e.toString(), stackTrace: st));
    }
  }

  // --- [BARU] METHOD UNTUK FOTO PROFIL ---

  /// Mengunggah foto profil dan mengembalikan URL-nya.
  FutureEither<String> uploadProfilePicture({
    required File image,
    required String userId,
  }) async {
    try {
      final fileId =
          '${AppwriteConstants.profilePicturesFolderPath}/$userId';
      
      // Hapus file lama jika ada, untuk menghindari penumpukan file
      try {
        await _storage.deleteFile(
          bucketId: AppwriteConstants.storageBucketId,
          fileId: fileId,
        );
      } catch (e) {
        // Abaikan error jika file tidak ada (ini adalah upload pertama)
        logger.w("No old profile picture to delete for user $userId. Proceeding to upload.");
      }

      final uploadedFile = await _storage.createFile(
        bucketId: AppwriteConstants.storageBucketId,
        fileId: fileId,
        file: InputFile.fromPath(path: image.path),
        permissions: [
          Permission.read(Role.any()),
          Permission.update(Role.user(userId)),
          Permission.delete(Role.user(userId)),
        ],
      );

      final imageUrl = _storage.getFileView(
        bucketId: AppwriteConstants.storageBucketId,
        fileId: uploadedFile.$id,
      );

      return right(imageUrl.toString());
    } on AppwriteException catch (e, st) {
      return left(Failure(
          message: e.message ?? 'Gagal mengunggah foto profil.',
          stackTrace: st));
    } catch (e, st) {
      return left(Failure(message: e.toString(), stackTrace: st));
    }
  }

  /// Menyimpan URL foto profil baru ke preferensi pengguna.
  FutureEitherVoid saveProfilePictureUrl({required String photoUrl}) async {
    try {
      // Ambil prefs yang ada, lalu tambahkan/update photoUrl
      final currentUser = await _account.get();
      final currentPrefs = currentUser.prefs.data;
      
      final updatedPrefs = {
        ...currentPrefs, // Salin semua prefs lama
        'photoUrl': photoUrl, // Tambah atau timpa dengan URL baru
      };
      
      await _account.updatePrefs(prefs: updatedPrefs);
      return right(null);

    } on AppwriteException catch (e, st) {
      return left(Failure(
          message: e.message ?? 'Gagal menyimpan URL foto profil.',
          stackTrace: st));
    } catch (e, st) {
      return left(Failure(message: e.toString(), stackTrace: st));
    }
  }
}