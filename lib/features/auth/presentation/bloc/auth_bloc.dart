import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hackathon_mobile/features/auth/domain/usecases/is_logged_in_usecase.dart';
import 'package:hackathon_mobile/features/auth/domain/usecases/login_usecase.dart';
import 'package:hackathon_mobile/features/auth/domain/usecases/register_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUsecase loginUsecase;
  final RegisterUsecase registerUsecase;

  final IsLoggedInUsecase isLoggedInUsecase;
  AuthBloc(
      {required this.loginUsecase,
      required this.registerUsecase,
      required this.isLoggedInUsecase})
      : super(AuthInitial()) {
    on<LoginEvent>((event, emit) async {
      final result = await loginUsecase(event.email, event.password);
      result.fold(
        (failure) => emit(AuthFailureState(message: failure.message)),
        (user) => emit(AuthLoginSuccessState()),
      );
    });
    on<RegisterEvent>((event, emit) async {
      await registerUsecase(event.name, event.email, event.password)
          .then((result) {
        result.fold(
          (failure) => emit(AuthFailureState(message: failure.message)),
          (user) => emit(AuthRegisterSuccessState()),
        );
      });
    });
    on<IsLoggedInEvent>(
      (event, emit) async {
        await isLoggedInUsecase().then((result) {
          result.fold(
            (failure) => emit(IsLoggedInFailureState()),
            (user) => emit(IsLoggedInSuccessState()),
          );
        });
      },
    );
  }
}
