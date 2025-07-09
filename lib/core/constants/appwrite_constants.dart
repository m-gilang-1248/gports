// lib/core/constants/appwrite_constants.dart

/// Kelas ini berisi semua konstanta yang berhubungan dengan konfigurasi Appwrite.
/// Tujuannya adalah untuk memiliki satu sumber kebenaran (Single Source of Truth)
/// untuk semua ID dan nama yang digunakan dalam interaksi dengan Appwrite.
class AppwriteConstants {
  // Kosongkan constructor agar kelas ini tidak bisa diinstansiasi.
  AppwriteConstants._();

  // --- PROJECT CONFIGURATION ---
  // ID-ID ini akan kita ambil dari file .env nantinya.
  static const String databaseId = '686d35e40002ad94db37'; // Biasanya 'default' atau ID custom
  static const String projectId = '686cc86a0023147a7fe7';
  static const String endPoint = 'https://syd.cloud.appwrite.io/v1';

  // --- COLLECTION IDs ---
  // Setiap nama variabel di bawah ini merepresentasikan satu Collection di database Appwrite kita.
  static const String usersCollection = '686d35f5000689301505';
  static const String sportCentersCollection = '686d35ff0031bc02a4d5';
  static const String fieldsCollection = '686d3606000e07c18fd4';
  static const String bookingsCollection = '686d360e00153874d84f';
  static const String blockedSlotsCollection = '686d3619002f7dab932c';

  // --- STORAGE BUCKET ID (HANYA SATU) ---
  // Karena tier gratis Appwrite Cloud hanya mengizinkan 1 bucket,
  // kita akan menggunakan satu bucket utama untuk semua file.
  static const String storageBucketId = '686d36350035bf5753d1'; // e.g., 'gsports_files'

  // --- FOLDER VIRTUAL DI DALAM BUCKET ---
  // Kita akan menggunakan path ini sebagai prefix saat membuat fileId
  // untuk mengorganisir file-file kita di dalam satu bucket.
  static const String scImagesFolderPath = 'sc_images';
  static const String fieldImagesFolderPath = 'field_images';
  static const String paymentProofsFolderPath = 'payment_proofs';
  static const String profilePicturesFolderPath = 'profile_pictures';

  // --- REALTIME CHANNELS ---
  // Helper untuk membuat channel realtime yang konsisten.
  static String bookingsChannel() {
    return 'databases.$databaseId.collections.$bookingsCollection.documents';
  }

  static String blockedSlotsChannel() {
    return 'databases.$databaseId.collections.$blockedSlotsCollection.documents';
  }
}