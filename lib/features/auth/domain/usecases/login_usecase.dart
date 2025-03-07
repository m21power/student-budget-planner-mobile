import 'package:dartz/dartz.dart';
import 'package:hackathon_mobile/core/error/failure.dart';
import 'package:hackathon_mobile/features/auth/domain/entities/user_entities.dart';
import 'package:hackathon_mobile/features/auth/domain/repository/auth_repository.dart';

class LoginUsecase {
  final AuthRepository authRepository;
  LoginUsecase({required this.authRepository});
  Future<Either<Failure, UserEntities>> call(String email, String password) {
    return authRepository.login(email, password);
  }
}
