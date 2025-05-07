import 'package:flutter/material.dart';
import 'package:web_app/services/login_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LoginService _loginService = LoginService();
  bool _isLoading = false;
  String? _errorMessage;

  void _handleLogin() async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    final email = _emailController.text;
    final password = _passwordController.text;

    // Simulate login attempt
    final response = await _loginService.login(email, password);

    if (_loginService.isLoggedIn()) {
      // Navigate to the home page on successful login
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Friendly error message for user
      setState(() {
        _errorMessage = 'Invalid email or password. Please try again.';
      });
    }
  } catch (e) {
    // Generic error message for unexpected errors
    setState(() {
      _errorMessage = 'Invalid email or password. Please try again.';
    });
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}


void _unfocus(BuildContext context) {
  final currentFocus = FocusScope.of(context);
  if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
    currentFocus.unfocus();
  }
}

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
    onTap: () {
      FocusScope.of(context).unfocus();
    },
    
    child: Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: 800,
                minHeight: 700,
                maxWidth: screenWidth < 800 ? 800 : screenWidth,
                maxHeight: screenHeight < 700 ? 700 : screenHeight,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: screenWidth * 0.25),
                  child: _buildLoginCard(context),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _buildLoginCard(BuildContext context) {
  return Container(
    width: 400,
    padding: const EdgeInsets.all(16.0),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.7),
      borderRadius: BorderRadius.circular(20.0),
      boxShadow: [
        BoxShadow(
          color: Colors.black45,
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          'Build Buddy',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 30),
        _buildEmailField(),
        const SizedBox(height: 16),
        _buildPasswordField(),
        const SizedBox(height: 20),
        // Show error message if available
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        if (_isLoading)
          CircularProgressIndicator()
        else
          _buildLoginButton(),
      ],
    ),
  );
}

Widget _buildEmailField() {
  return TextField(
    key: ValueKey('emailField'), 
    controller: _emailController,
    style: TextStyle(color: Colors.white),
    decoration: InputDecoration(
      hintText: 'Login',
      hintStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: Colors.black.withOpacity(0.3),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.0),
        borderSide: const BorderSide(color: Colors.white54),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.0),
        borderSide: const BorderSide(color: Colors.white54),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.0),
        borderSide: const BorderSide(color: Colors.white),
      ),
    ),
  );
}

Widget _buildPasswordField() {
  return TextField(
    key: ValueKey('passwordField'),
    controller: _passwordController,
    style: TextStyle(color: Colors.white),
    decoration: InputDecoration(
      hintText: 'Password',
      hintStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: Colors.black.withOpacity(0.3),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.0),
        borderSide: const BorderSide(color: Colors.white54),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.0),
        borderSide: const BorderSide(color: Colors.white54),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.0),
        borderSide: const BorderSide(color: Colors.white),
      ),
    ),
    obscureText: true,
  );
}

Widget _buildLoginButton() {
  return ElevatedButton(
    onPressed: _handleLogin,
    child: const Text('Log in'),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blueAccent,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
    ),
  );
}


}