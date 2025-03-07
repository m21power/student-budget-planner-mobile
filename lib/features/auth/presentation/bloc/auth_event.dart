part of 'auth_bloc.dart';

sealed class AuthEvent {
  const AuthEvent();
}

final class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginEvent({required this.email, required this.password});
}

final class RegisterEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;

  const RegisterEvent(
      {required this.name, required this.email, required this.password});
}

final class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

final class IsLoggedInEvent extends AuthEvent {
  const IsLoggedInEvent();
}
