abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final String token;
  final int userId;

  LoginSuccess({required this.token, required this.userId});
}

class LoginFailure extends LoginState {
  final String error;

  LoginFailure({required this.error});
}
