// lib/features/3_sc_details/controller/sc_details_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart'; // <-- TAMBAHKAN IMPORT UNTUK FPDART

import 'package:gsports/core/failure.dart'; // <-- TAMBAHKAN IMPORT UNTUK FAILURE
import 'package:gsports/core/models/field_model.dart';
import 'package:gsports/core/models/sc_model.dart';
import 'package:gsports/features/3_sc_details/repository/sc_details_repository.dart';

// --- 1. View Model untuk Halaman Detail ---
class SCDetailsData {
  final SCModel scDetails;
  final List<FieldModel> fields;

  SCDetailsData({
    required this.scDetails,
    required this.fields,
  });
}

// --- 2. Provider untuk Data Detail SC ---
final scDetailsDataProvider =
    FutureProvider.autoDispose.family<SCDetailsData, String>((ref, scId) async {
  
  final scDetailsRepository = ref.watch(scDetailsRepositoryProvider);

  // Memanggil kedua method dari repository secara bersamaan.
  final results = await Future.wait([
    scDetailsRepository.getSCDetails(scId: scId),
    scDetailsRepository.getFieldsForSC(scId: scId),
  ]);

  // Type cast hasil dari Future.wait.
  // Kelas Either, Left, dan Right sekarang akan dikenali.
  final scDetailsEither = results[0] as Either<Failure, SCModel>;
  final fieldsEither = results[1] as Either<Failure, List<FieldModel>>;

  // Menggunakan pattern matching pada tuple.
  return switch ((scDetailsEither, fieldsEither)) {
    // Kasus sukses: kedua panggilan berhasil.
    (Right(value: final scDetails), Right(value: final fields)) =>
      SCDetailsData(scDetails: scDetails, fields: fields),
    
    // Kasus gagal: salah satu atau kedua panggilan gagal.
    (Left(value: final failure), _) => throw failure,
    (_, Left(value: final failure)) => throw failure,
  };
});