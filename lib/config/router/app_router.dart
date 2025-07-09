// lib/config/router/app_router.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// --- Impor Model ---
import 'package:gsports/core/models/booking_model.dart';
import 'package:gsports/core/models/field_model.dart';
import 'package:gsports/core/models/user_model.dart';

// --- Impor Provider & Controller ---
import 'package:gsports/features/0_auth/controller/auth_controller.dart';

// --- Impor UI Screens ---
import 'package:gsports/features/0_auth/view/login_screen.dart';
import 'package:gsports/features/0_auth/view/register_screen.dart';
import 'package:gsports/features/1_home/view/home_screen.dart';
import 'package:gsports/features/2_sc_list/view/sc_list_screen.dart'; // Impor yang benar
import 'package:gsports/features/3_sc_details/view/field_details_screen.dart';
import 'package:gsports/features/3_sc_details/view/sc_details_screen.dart';
import 'package:gsports/features/4_booking/view/booking_confirmation_screen.dart';
import 'package:gsports/features/4_booking/view/booking_history_screen.dart';
import 'package:gsports/features/4_booking/view/booking_status_screen.dart';
import 'package:gsports/features/5_profile/view/edit_profile_screen.dart';
import 'package:gsports/features/5_profile/view/profile_screen.dart';
import 'package:gsports/features/6_sc_admin/view/bookings/sc_admin_booking_details_screen.dart';
import 'package:gsports/features/6_sc_admin/view/bookings/sc_admin_booking_list_screen.dart';
import 'package:gsports/features/6_sc_admin/view/dashboard/sc_admin_dashboard_screen.dart';
import 'package:gsports/features/6_sc_admin/view/fields/sc_admin_field_edit_screen.dart';
import 'package:gsports/features/6_sc_admin/view/fields/sc_admin_field_list_screen.dart';
import 'package:gsports/features/6_sc_admin/view/profile/sc_admin_profile_screen.dart';
import 'package:gsports/shared_widgets/bottom_nav_bar.dart';
import 'package:gsports/shared_widgets/error_display.dart';

import 'route_names.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  final rootNavigatorKey = GlobalKey<NavigatorState>();
  
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/login',
    
    redirect: (BuildContext context, GoRouterState state) {
      if (authState.isLoading || authState.hasError) return null;
      final isLoggedIn = authState.valueOrNull != null;
      final isLoggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/register';
      
      if (!isLoggedIn && !isLoggingIn) return '/login';

      if (isLoggedIn && isLoggingIn) {
        final user = ref.read(userProvider).value;
        if (user?.role == UserRole.scAdmin) return '/admin/dashboard';
        return '/home';
      }
      return null;
    },
    
    // --- PERBAIKAN 3: errorPageBuilder di level GoRouter ---
    errorPageBuilder: (context, state) => MaterialPage(
      key: state.pageKey,
      child: ErrorDisplay(message: 'Halaman tidak ditemukan: ${state.error}'),
    ),

    routes: [
      GoRoute(
        name: RouteNames.login,
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        name: RouteNames.register,
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        name: RouteNames.bookingStatus,
        path: '/booking-status',
        builder: (context, state) {
          final booking = state.extra as BookingModel;
          return BookingStatusScreen(booking: booking);
        },
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return BottomNavBarShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: RouteNames.home,
                path: '/home',
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    name: RouteNames.searchResults,
                    path: 'search',
                    builder: (context, state) {
                      final city = state.uri.queryParameters['city'] ?? '';
                      final sport = state.uri.queryParameters['sport'] ?? '';
                      return SearchResultsScreen(city: city, sport: sport);
                    },
                  ),
                  GoRoute(
                    name: RouteNames.scDetails,
                    path: 'sc/:scId',
                    builder: (context, state) {
                      final scId = state.pathParameters['scId']!;
                      return SCDetailsScreen(scId: scId);
                    },
                    routes: [
                      GoRoute(
                        name: RouteNames.fieldDetails,
                        path: 'field/:fieldId',
                        builder: (context, state) {
                          final fieldId = state.pathParameters['fieldId']!;
                          return FieldDetailsScreen(fieldId: fieldId);
                        },
                      ),
                      GoRoute(
                        name: RouteNames.bookingConfirmation,
                        path: 'booking',
                        builder: (context, state) {
                          final params = state.extra as BookingConfirmationParams;
                          return BookingConfirmationScreen(params: params);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: RouteNames.history,
                path: '/history',
                builder: (context, state) => const BookingHistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: RouteNames.profile,
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    name: RouteNames.editProfile,
                    path: 'edit', // -> /profile/edit
                    builder: (context, state) {
                      final user = state.extra as UserModel;
                      return EditProfileScreen(user: user);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        name: RouteNames.adminDashboard,
        path: '/admin/dashboard',
        builder: (context, state) => const SCAdminDashboardScreen(),
        routes: [
          GoRoute(
            name: RouteNames.adminFieldList,
            path: 'fields',
            builder: (context, state) => const SCAdminFieldListScreen(),
            routes: [
                GoRoute(
                    name: RouteNames.adminFieldEdit,
                    path: 'edit',
                    builder: (context, state) {
                      final field = state.extra as FieldModel?;
                      return SCAdminFieldEditScreen(field: field);
                    },
                ),
            ], // <-- PERBAIKAN 1: Menambahkan kurung siku penutup yang hilang
          ),
          GoRoute(
            name: RouteNames.adminBookingList,
            path: 'bookings', // -> /admin/dashboard/bookings
            builder: (context, state) => const SCAdminBookingListScreen(),
          ),
          GoRoute(
            name: RouteNames.adminBookingDetails,
            path: 'bookings/details', // -> /admin/dashboard/bookings/details
            builder: (context, state) {
              final booking = state.extra as BookingModel;
              return SCAdminBookingDetailsScreen(booking: booking);
            },
          ),
          GoRoute(
            name: RouteNames.adminProfile,
            path: 'profile', // -> /admin/dashboard/profile
            builder: (context, state) => const SCAdminProfileScreen(),
          ),
        ],
      ),
    ],
  );
});