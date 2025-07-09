// // lib/core/providers/user_data_provider.dart

// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import 'package:gsports/core/models/user_model.dart';
// import 'package:gsports/features/0_auth/controller/auth_controller.dart';

// /// Provider untuk mendapatkan data `UserModel` dari pengguna yang sedang login.
// ///
// /// `userProvider` akan secara reaktif memberikan data pengguna terbaru.
// /// Ini menggunakan `FutureProvider` karena proses mendapatkan data pengguna
// /// (terutama saat pertama kali) adalah operasi asynchronous.
// ///
// /// Cara kerjanya:
// /// 1. `ref.watch(authStateChangesProvider.future)`: Mengawasi `authStateChangesProvider`
// ///    dan menunggu hingga future-nya selesai (memberikan akun atau null).
// /// 2. Jika `account` tidak null (artinya pengguna sudah login), maka kita
// ///    mengonversinya menjadi `UserModel` menggunakan factory constructor
// ///    `UserModel.fromAppwriteUser(account)`.
// /// 3. Jika `account` adalah null (tidak ada pengguna yang login), provider ini
// ///    juga akan mengembalikan `null`.
// ///
// /// Widget di UI akan mengawasi provider ini dan bisa dengan mudah menangani
// /// ketiga state dari `AsyncValue` (data, loading, error).
// final userProvider = FutureProvider<UserModel?>((ref) async {
//   // Mengawasi provider yang memberikan status login/logout.
//   // Kita menggunakan `.future` untuk mendapatkan hasil dari StreamProvider sebagai Future.
//   final account = await ref.watch(authStateChangesProvider.future);

//   // Jika ada akun yang aktif (pengguna login)...
//   if (account != null) {
//     // ...konversi objek User dari Appwrite menjadi UserModel kita.
//     return UserModel.fromAppwriteUser(account);
//   }
  
//   // Jika tidak ada akun yang aktif, kembalikan null.
//   return null;
// });