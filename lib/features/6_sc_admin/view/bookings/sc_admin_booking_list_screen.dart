// lib/features/6_sc_admin/view/bookings/sc_admin_booking_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gsports/config/router/route_names.dart';
import 'package:gsports/core/models/booking_model.dart';
import 'package:gsports/core/providers/user_data_provider.dart';
import 'package:gsports/features/6_sc_admin/controller/sc_admin_bookings_controller.dart';
import 'package:gsports/shared_widgets/error_display.dart';
import 'package:gsports/shared_widgets/loading_indicator.dart';
import 'package:intl/intl.dart';
import 'package:gsports/features/0_auth/controller/auth_controller.dart';

class SCAdminBookingListScreen extends ConsumerWidget {
  const SCAdminBookingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider).value;

    if (user == null || user.assignedCenterId == null) {
      return const Scaffold(body: ErrorDisplay(message: 'Data admin tidak valid.'));
    }

    final asyncBookings = ref.watch(adminBookingsProvider(user.assignedCenterId!));

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Pemesanan')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(adminBookingsProvider(user.assignedCenterId!)),
        child: asyncBookings.when(
          loading: () => const LoadingIndicator(),
          error: (e, st) => ErrorDisplay(message: e.toString(), onRetry: () => ref.invalidate(adminBookingsProvider(user.assignedCenterId!))),
          data: (bookings) {
            if (bookings.isEmpty) {
              return const Center(child: Text('Belum ada pesanan masuk.'));
            }
            return ListView.separated(
              itemCount: bookings.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return _BookingListTile(booking: booking);
              },
            );
          },
        ),
      ),
    );
  }
}

class _BookingListTile extends StatelessWidget {
  final BookingModel booking;
  const _BookingListTile({required this.booking});

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd MMM yyyy, HH:mm');
    return ListTile(
      title: Text('Booking ID: ${booking.id.substring(0, 8)}...'),
      subtitle: Text('Oleh: User ID ${booking.playerUserId.substring(0, 8)}...'),
      trailing: Text(booking.status.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      onTap: () {
        context.goNamed(RouteNames.adminBookingDetails, extra: booking);
      },
    );
  }
}