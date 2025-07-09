// lib/config/router/route_names.dart

/// Kelas `RouteNames` berisi semua nama rute yang digunakan dalam aplikasi.
///
/// Menggunakan konstanta statis untuk nama rute adalah praktik terbaik karena
/// memberikan keamanan tipe (type-safety) dan mencegah kesalahan pengetikan
/// saat melakukan navigasi dengan `GoRouter`.
class RouteNames {
  // Constructor privat untuk mencegah instansiasi.
  RouteNames._();

  // --- Alur Autentikasi ---
  static const String splash = 'splash';
  static const String login = 'login';
  static const String register = 'register';

  // --- Alur Utama Pemain (Player Flow) ---
  static const String home = 'home';
  static const String searchResults = 'searchResults';
  static const String scDetails = 'scDetails';       // Detail Sports Center
  static const String fieldDetails = 'fieldDetails'; // Detail Lapangan
  
  // -- Sub-alur Booking Pemain --
  static const String bookingConfirmation = 'bookingConfirmation';
  static const String bookingStatus = 'bookingStatus';
  
  // --- Halaman dengan Navigasi Bawah (Bottom Navigation) ---
  static const String history = 'history'; // Riwayat Pemesanan
  static const String profile = 'profile'; // Profil Pemain
  
  // -- Sub-alur Profil Pemain --
  static const String editProfile = 'editProfile';

  // --- Alur Admin Sports Center (SC Admin Flow) ---
  // Rute-rute ini akan berada di bawah satu 'shell' atau rute dasar admin.
  static const String adminDashboard = 'adminDashboard';
  
  // -- Sub-alur Manajemen Admin --
  static const String adminFieldList = 'adminFieldList';     // Daftar lapangan
  static const String adminFieldEdit = 'adminFieldEdit';     // Form tambah/edit lapangan
  static const String adminBookingList = 'adminBookingList';   // Daftar booking
  static const String adminBookingDetails = 'adminBookingDetails'; // Detail booking
  static const String adminProfile = 'adminProfile';           // Edit profil SC
  static const String adminSchedule = 'adminSchedule';         // Kalender jadwal

  // --- Halaman Utility ---
  // Rute ini mungkin tidak selalu digunakan dengan `goNamed` tapi baik untuk didefinisikan.
  static const String noConnection = 'noConnection';
  static const String errorPage = 'errorPage';
}