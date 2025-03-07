import 'package:dartz/dartz.dart';
import 'package:hackathon_mobile/core/error/failure.dart';
import 'package:hackathon_mobile/features/auth/domain/repository/auth_repository.dart';

class RegisterUsecase {
  final AuthRepository authRepository;
  RegisterUsecase({required this.authRepository});
  Future<Either<Failure, Unit>> call(
      String name, String email, String password) {
    return authRepository.register(name, email, password);
  }
}
