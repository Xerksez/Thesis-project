import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/login/bloc/login_bloc.dart';
import 'package:mobile/shared/config/config.dart';
import '../bloc/login_event.dart';
import '../bloc/login_state.dart';
import 'widgets/login_form.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/themes/styles.dart';
import 'package:http/http.dart' as http;
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isSessionChecked = false; // Flaga, aby sprawdzić sesję tylko raz

  @override
  void initState() {
    super.initState();
    _checkUserSession();
  }

  Future<void> _checkUserSession() async {
    if (_isSessionChecked) return; // Jeśli sesja była sprawdzana, zakończ

    setState(() {
      _isSessionChecked = true; // Ustaw flagę na true, aby uniknąć wielokrotnego sprawdzania
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print("Sprawdzam sesję");

    if (token != null) {
      try {
        // Endpoint do sprawdzenia ważności tokena
        final response = await http.get(
          Uri.parse('${AppConfig.getBaseUrl()}/api/Address'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        );
        if (response.statusCode == 200) {
          // Token jest ważny
          print("Token ważny");
          Navigator.pushReplacementNamed(context, '/home');
        } else if (response.statusCode == 401) {
          // Token jest nieważny, wylogowanie
          print('[SessionCheck] Token expired or invalid. Logging out.');
          await prefs.clear();
          // Nie wywołuj `pushReplacementNamed` na ekranie logowania, aby uniknąć pętli
        } else {
          // Inny błąd
          print('[SessionCheck] Unexpected error: ${response.statusCode}');
        }
      } catch (e) {
        // Obsługa błędu sieciowego
        print('[SessionCheck] Network error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: AppStyles.backgroundDecoration,
          ),
          // Semi-transparent filter
          Container(
            color: AppStyles.filterColor.withOpacity(0.7),
          ),
          // Content with scrollable behavior
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  Padding(
                    padding: const EdgeInsets.only(top: 50, bottom: 20),
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: Image.asset('assets/logo_small.png'),
                    ),
                  ),
                  // Login Form
                  BlocListener<LoginBloc, LoginState>(
                    listener: (context, state) {
                      if (state is LoginSuccess) {
                        Navigator.pushReplacementNamed(context, '/home');
                      } else if (state is LoginFailure) {
                        // Handle specific error messages
                        String errorMessage = 'Login Failed';
                        if (state.error.contains('incorrect password')) {
                          errorMessage = 'Incorrect password. Please try again.';
                        } else if (state.error.contains('email not found')) {
                          errorMessage = 'No account found for this email.';
                        } else if (state.error.contains('invalid email')) {
                          errorMessage = 'Invalid email format.';
                        } else {
                          errorMessage = state.error;
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(errorMessage),
                            backgroundColor: const Color.fromARGB(255, 43, 42, 42),
                          ),
                        );
                      }
                    },
                    child: BlocBuilder<LoginBloc, LoginState>(
                      builder: (context, state) {
                        return LoginForm(
                          isLoading: state is LoginLoading,
                          onLogin: (email, password) {
                            context.read<LoginBloc>().add(
                                  LoginSubmitted(email: email, password: password),
                                );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
