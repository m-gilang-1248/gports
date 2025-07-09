// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gsports/config/router/app_router.dart';
import 'package:gsports/config/theme/app_theme.dart';
import 'package:gsports/core/utils/logger.dart';
// --- Impor Baru ---
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // --- PERBAIKAN: Inisialisasi data lokalisasi untuk 'id_ID' ---
  await initializeDateFormatting('id_ID', null);

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    
    logger.i("MyApp build called. Router has been initialized.");

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Gsports',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // --- PERBAIKAN: Tambahkan delegate dan locale ---
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id', 'ID'), // Mendukung Bahasa Indonesia
        // Anda bisa menambahkan locale lain di sini jika perlu
      ],
      locale: const Locale('id', 'ID'), // Set default locale

      routeInformationProvider: router.routeInformationProvider,
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
    );
  }
}