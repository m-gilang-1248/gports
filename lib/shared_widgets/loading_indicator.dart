// lib/shared_widgets/loading_indicator.dart

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Enum untuk menentukan tipe loading indicator yang akan ditampilkan.
enum LoadingIndicatorType {
  list, // Untuk placeholder daftar (seperti daftar SC atau booking)
  simple, // Hanya CircularProgressIndicator di tengah
}

/// `LoadingIndicator` adalah widget serbaguna untuk menampilkan state loading
/// dengan cara yang konsisten di seluruh aplikasi.
class LoadingIndicator extends StatelessWidget {
  final LoadingIndicatorType type;

  const LoadingIndicator({
    super.key,
    this.type = LoadingIndicatorType.list, // Default ke tipe list
  });

  @override
  Widget build(BuildContext context) {
    if (type == LoadingIndicatorType.simple) {
      return const Center(child: CircularProgressIndicator());
    }

    // Jika tipe adalah list, tampilkan shimmer effect.
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: 6, // Tampilkan 6 item placeholder
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Placeholder untuk gambar
              Container(
                width: 60.0,
                height: 60.0,
                color: Colors.white,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Placeholder untuk judul
                    Container(
                      width: double.infinity,
                      height: 12.0,
                      color: Colors.white,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.0),
                    ),
                    // Placeholder untuk sub-judul
                    Container(
                      width: double.infinity,
                      height: 12.0,
                      color: Colors.white,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.0),
                    ),
                    // Placeholder untuk baris teks ketiga yang lebih pendek
                    Container(
                      width: 40.0,
                      height: 12.0,
                      color: Colors.white,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}