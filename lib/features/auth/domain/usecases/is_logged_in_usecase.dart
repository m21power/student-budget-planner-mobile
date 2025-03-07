import 'package:dartz/dartz.dart';
import 'package:hackathon_mobile/core/error/failure.dart';
import 'package:hackathon_mobile/features/auth/domain/repository/auth_repository.dart';

class IsLoggedInUsecase {
  final AuthRepository authRepository;
  IsLoggedInUsecase({required this.authRepository});
  Future<Either<Failure, Unit>> call() {
    return authRepository.isLoggedIn();
  }
}
