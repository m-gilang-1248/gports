// lib/core/failure.dart
import 'package:equatable/equatable.dart';

class Failure extends Equatable {
  final String message;
  final StackTrace stackTrace;

  const Failure({
    required this.message,
    required this.stackTrace,
  });

  @override
  List<Object> get props => [message, stackTrace];

  @override
  String toString() => 'Failure(message: $message, stackTrace: $stackTrace)';
}