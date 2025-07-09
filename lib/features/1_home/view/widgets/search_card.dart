// lib/features/1_home/view/widgets/search_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gsports/features/1_home/controller/home_controller.dart';
import 'package:gsports/shared_widgets/custom_button.dart';
import 'package:gsports/shared_widgets/custom_textfield.dart';

class SearchCard extends ConsumerStatefulWidget {
  const SearchCard({super.key});

  @override
  ConsumerState<SearchCard> createState() => _SearchCardState();
}

class _SearchCardState extends ConsumerState<SearchCard> {
  final _sportController = TextEditingController();
  final _cityController = TextEditingController();

  @override
  void dispose() {
    _sportController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _onSearch() {
    ref.read(homeControllerProvider).search(
          context: context,
          city: _cityController.text,
          sport: _sportController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Temukan Lapangan Impianmu',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            // TODO: Ganti dengan Dropdown jika sudah ada data master olahraga
            CustomTextField(
              controller: _sportController,
              hintText: 'Cth: Futsal, Badminton',
              prefixIcon: Icons.sports_soccer_outlined,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _cityController,
              hintText: 'Cth: Jakarta, Bandung',
              prefixIcon: Icons.location_city_outlined,
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Cari Lapangan',
              onPressed: _onSearch,
            ),
          ],
        ),
      ),
    );
  }
}