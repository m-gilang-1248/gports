// lib/features/3_sc_details/view/widgets/field_list_tile.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gsports/config/router/route_names.dart';
import 'package:gsports/core/models/field_model.dart';
import 'package:intl/intl.dart';

class FieldListTile extends StatelessWidget {
  final FieldModel field;

  const FieldListTile({super.key, required this.field});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Formatter untuk harga
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.goNamed(
            RouteNames.fieldDetails,
            // Perhatikan bagaimana kita mengirim DUA path parameter
            pathParameters: {
              'scId': field.centerId,
              'fieldId': field.id,
            },
          );
        },
        child: Row(
          children: [
            // Gambar Lapangan
            CachedNetworkImage(
              imageUrl: field.photosUrls.isNotEmpty ? field.photosUrls.first : '',
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => Container(
                width: 100,
                height: 100,
                color: Colors.grey.shade200,
                child: const Icon(Icons.sports_soccer_outlined, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 12),
            // Info Lapangan
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    field.name,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tipe: ${field.sportType}',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${currencyFormatter.format(field.pricePerHour)} / jam',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }
}