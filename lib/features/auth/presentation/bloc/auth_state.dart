part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

final class AuthInitial extends AuthState {}

final class AuthFailureState extends AuthState {
  final String message;
  const AuthFailureState({required this.message});
  @override
  List<Object> get props => [message];
}

final class AuthLoginSuccessState extends AuthState {
  const AuthLoginSuccessState();
  @override
  List<Object> get props => [];
}

final class AuthRegisterSuccessState extends AuthState {
  const AuthRegisterSuccessState();
  @override
  List<Object> get props => [];
}

final class IsLoggedInSuccessState extends AuthState {
  const IsLoggedInSuccessState();
  @override
  List<Object> get props => [];
}

final class IsLoggedInFailureState extends AuthState {
  const IsLoggedInFailureState();
  @override
  List<Object> get props => [];
}
