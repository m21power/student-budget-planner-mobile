import 'package:dartz/dartz.dart';
import 'package:hackathon_mobile/core/error/failure.dart';
import 'package:hackathon_mobile/features/auth/domain/entities/user_entities.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntities>> login(String email, String password);
  Future<Either<Failure, Unit>> register(
      String name, String email, String password);
  Future<Either<Failure, Unit>> isLoggedIn();
}
