import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_event.dart';
import 'login_state.dart';
import '../services/login_service.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginService loginService;

  LoginBloc({required this.loginService}) : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
      LoginSubmitted event, Emitter<LoginState> emit) async {
    emit(LoginLoading());
    print('LoginLoading emitted');

    try {
      final response = await loginService.login(event.email, event.password);
      print('Login service returned token: ${response.token}, ID: ${response.id}');

      // Save token and userId in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', response.token);
      await prefs.setInt('userId', response.id);
      print('Token and userId saved in SharedPreferences');

      emit(LoginSuccess(token: response.token, userId: response.id));
      print('LoginSuccess emitted');
    } catch (e) {
      print('Login service failed: $e');
      emit(LoginFailure(error: e.toString()));
    }
  }
}
