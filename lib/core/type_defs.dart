// lib/core/type_defs.dart
import 'package:fpdart/fpdart.dart';
import 'failure.dart'; 

typedef FutureEither<T> = Future<Either<Failure, T>>;
typedef FutureEitherVoid = FutureEither<void>;