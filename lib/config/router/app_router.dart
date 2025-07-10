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
import 'package:gsports/features/2_sc_list/view/sc_list_screen.dart';
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
import 'package:gsports/features/6_sc_admin/view/schedule/sc_admin_schedule_screen.dart';
import 'package:gsports/shared_widgets/bottom_nav_bar.dart';
import 'package:gsports/shared_widgets/error_display.dart';
import 'package:gsports/shared_widgets/loading_indicator.dart';

import 'route_names.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();
  
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    
    redirect: (BuildContext context, GoRouterState state) {
      final authState = ref.watch(authStateChangesProvider);
      final userState = ref.watch(userProvider);
      final currentRoute = state.matchedLocation;

      if (authState.isLoading || userState.isLoading) {
        return currentRoute == '/splash' ? null : '/splash';
      }

      final isLoggedIn = authState.valueOrNull != null;
      final isGoingToAuthPage = currentRoute == '/login' || currentRoute == '/register';
      if (!isLoggedIn) {
        return isGoingToAuthPage ? null : '/login';
      }

      final user = userState.valueOrNull;
      final isAdmin = user?.role == UserRole.scAdmin || user?.role == UserRole.superAdmin;
      if (isGoingToAuthPage || currentRoute == '/splash') {
        return isAdmin ? '/admin/dashboard' : '/home';
      }
      
      if (isAdmin && !currentRoute.startsWith('/admin')) {
        return '/admin/dashboard';
      }
      
      if (!isAdmin && currentRoute.startsWith('/admin')) {
        return '/home';
      }
      
      return null;
    },

    errorPageBuilder: (context, state) => MaterialPage(
      key: state.pageKey,
      child: ErrorDisplay(message: 'Halaman tidak ditemukan: ${state.error}'),
    ),
    
    routes: [
      GoRoute(
        path: '/splash',
        name: RouteNames.splash,
        builder: (context, state) => const Scaffold(body: LoadingIndicator(type: LoadingIndicatorType.simple)),
      ),
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
          // Pastikan extra tidak null sebelum di-cast
          if (state.extra is BookingModel) {
            final booking = state.extra as BookingModel;
            return BookingStatusScreen(booking: booking);
          }
          return const ErrorDisplay(message: 'Data booking tidak valid.');
        },
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => BottomNavBarShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: RouteNames.home, path: '/home', builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    name: RouteNames.searchResults, path: 'search',
                    builder: (context, state) {
                      final city = state.uri.queryParameters['city'] ?? '';
                      final sport = state.uri.queryParameters['sport'] ?? '';
                      return SearchResultsScreen(city: city, sport: sport);
                    },
                  ),
                  GoRoute(
                    name: RouteNames.scDetails, path: 'sc/:scId',
                    builder: (context, state) {
                      final scId = state.pathParameters['scId']!;
                      return SCDetailsScreen(scId: scId);
                    },
                    // --- RUTE BERSARANG DI BAWAH scDetails ---
                    routes: [
                      GoRoute(
                        name: RouteNames.fieldDetails, path: 'field/:fieldId',
                        builder: (context, state) {
                          final fieldId = state.pathParameters['fieldId']!;
                          return FieldDetailsScreen(fieldId: fieldId);
                        },
                      ),
                      // --- [DIEDIT] RUTE BOOKING CONFIRMATION DITAMBAHKAN DI SINI ---
                      // Path lengkapnya: /home/sc/:scId/booking
                      GoRoute(
                        name: RouteNames.bookingConfirmation,
                        path: 'booking', 
                        builder: (context, state) {
                          // Pastikan extra tidak null sebelum di-cast
                          if (state.extra is BookingConfirmationParams) {
                            final params = state.extra as BookingConfirmationParams;
                            return BookingConfirmationScreen(params: params);
                          }
                          return const ErrorDisplay(message: 'Data konfirmasi tidak valid.');
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
              GoRoute(name: RouteNames.history, path: '/history', builder: (context, state) => const BookingHistoryScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: RouteNames.profile, path: '/profile', builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    name: RouteNames.editProfile, path: 'edit',
                    builder: (context, state) {
                       if (state.extra is UserModel) {
                        final user = state.extra as UserModel;
                        return EditProfileScreen(user: user);
                      }
                      return const ErrorDisplay(message: 'Data pengguna tidak valid.');
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // Rute untuk Admin SC (Tidak ada perubahan di sini)
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
                      // Field bisa null (untuk mode tambah)
                      final field = state.extra as FieldModel?;
                      return SCAdminFieldEditScreen(field: field);
                    },
                ),
            ],
          ),
          GoRoute(
            name: RouteNames.adminBookingList,
            path: 'bookings',
            builder: (context, state) => const SCAdminBookingListScreen(),
            routes: [
                GoRoute(
                    name: RouteNames.adminBookingDetails,
                    path: 'details',
                    builder: (context, state) {
                      if (state.extra is BookingModel) {
                        final booking = state.extra as BookingModel;
                        return SCAdminBookingDetailsScreen(booking: booking);
                      }
                      return const ErrorDisplay(message: 'Data booking tidak valid.');
                    },
                ),
            ],
          ),
          GoRoute(
            name: RouteNames.adminProfile,
            path: 'profile',
            builder: (context, state) => const SCAdminProfileScreen(),
          ),
          GoRoute(
            name: RouteNames.adminSchedule,
            path: 'schedule',
            builder: (context, state) => const SCAdminScheduleScreen(),
          ),
        ],
      ),
    ],
  );
});